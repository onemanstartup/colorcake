require_relative 'colorcake/version'
require_relative 'colorcake/color_util'
require_relative 'colorcake/merge_colors_methods'
require 'matrix'
require 'RMagick'
# Main class of functionality
module Colorcake
  require 'colorcake/engine' if defined?(Rails)

  class << self
    attr_accessor :base_colors, :colors_count,
      :max_numbers_of_color_in_palette,
      :white_threshold, :black_threshold,
      :delta, :cluster_colors

    def configure(&blk)
      class_eval(&blk)
      @base_colors ||= %w(660000 cc0000 ea4c88 993399 663399 304961 0066cc 66cccc 77cc33 336600 cccc33 ffcc33 fff533 ff6600 c8ad7f 996633 663300 000000 999999 cccccc ffffff)
      @cluster_colors ||= {
        '660000' => '660000',
        'cc0000' => 'cc0000', 'ce454c' => 'cc0000',
        'ea4c88' => 'ea4c88',
        '993399' => '993399',
        '663399' => '663399',
        '304961' => '304961', '405672' => '304961',
        '0066cc' => '0066cc', '1a3672' => '0066cc', '333399' => '0066cc', '0099cc' => '0066cc',
        '66cccc' => '66cccc',
        '77cc33' => '77cc33',
        '336600' => '336600',
        'cccc33' => 'cccc33', '999900' => 'cccc33',
        'ffcc33' => 'ffcc33',
        'fff533' => 'fff533', 'efd848' => 'fff533',
        'ff6600' => 'ff6600',
        'c8ad7f' => 'c8ad7f', 'ccad37' => 'c8ad7f', 'e0d3ba' => 'c8ad7f',
        '996633' => '996633',
        '663300' => '663300',
        '000000' => '000000', '2e2929' => '000000',
        '999999' => '999999', '7e8896' => '999999', '636363' => '999999',
        'cccccc' => 'cccccc', 'afb5ab' => 'cccccc',
        'ffffff' => 'ffffff', 'dde2e2' => 'ffffff', 'edefeb' => 'ffffff', 'ffe6e6' => '',  'ffe6e6' => 'ffffff', 'd5ccc3' => 'ffffff',
        'f6fce3' => 'ffffff',
        'e1f4fa' => 'ffffff',
        'e5e1fa' => 'ffffff',
        'fbe2f1' => 'ffffff',
        'fffae6' => 'ffffff',
        'ede7cf' => 'ffffff',
        'cae0e7' => 'ffffff',
        'ede1cf' => 'ffffff',
        'cae0e7' => 'ffffff',
        'cad3d5' => 'ffffff'
      }
      @colors_count ||= 60
      @max_numbers_of_color_in_palette ||= 5
      @white_threshold ||= 55_000
      @black_threshold ||= 2000
      @delta ||= 2.5
    end
  end

  @new_palette = []

  def self.extract_colors(src, colorspace = ::Magick::RGBColorspace)
    @new_palette = []
    colors = {}
    colors_hex = {}
    palette = compute_palette(src, @colors_count)
    palette = color_quantity_in_image(palette)
    @new_palette = []
    @new_palette = remove_common_color_from_palette(palette, @delta)
    (0..@new_palette.length - 1).each do |i|
      c = @new_palette[i][0].to_s.split(',').map { |x| x[/\d+/] }
      closest_color = closest_color_to(compute_b(c))
      percentage = @new_palette[i][1][1]
      colors_hex['#' + c.join('')] = @new_palette[i][1]

      # If we have colors defined in database
      if defined? SearchColor
        id = SearchColor.find_or_create_by_color(closest_color[0]).id
      else
        id = @base_colors.index(closest_color[0])
      end

      colors[id] ||= {}
      colors[id][:search_color_id] ||= id
      colors[id][:search_factor] ||= []
      colors[id][:search_factor] << percentage
      colors[id][:distance] ||= []
      colors[id][:hex] ||= c.join('')
      colors[id][:original_color] ||= []
      colors[id][:original_color] << {('#' + c.join('')) => @new_palette[i][1]}
      colors[id][:hex_of_base] ||= @base_colors[id] if id
      colors[id][:distance] = closest_color[1] if colors[id][:distance] == []
    end

    colors.each_with_index do |fac, index|
      colors[fac[0]][:search_factor] = generate_factor(fac[1][:search_factor])
    end
    # Disable when not working with DB
    # [colors, colors_hex]
    colors.delete_if {|k,v| colors[k][:search_factor] < 1}
    [colors, colors_hex]
  end

  def self.create_palette(colors)
    return colors if colors.length == @max_numbers_of_color_in_palette
    if colors.length > @max_numbers_of_color_in_palette
      colors = slim_palette(colors)
      create_palette(colors)
    else
      colors = expand_palette(colors)
      create_palette(colors)
    end
  end

  private

  def self.compute_b(c)
    c.pop
    [c[0], c[1], c[2]].map do |s|
      s = s.to_i
      s = s / 257 if s / 255 > 0 # not all ImageMagicks are created equal....
    end
  end

  def self.closest_color_to(b)
    closest_colors = {}
    @cluster_colors.each do |extended_color, base_color|
      extended_color_hex = ColorUtil.rgb_number_from_string(extended_color)
      delta = ColorUtil.delta_e(ColorUtil.rgb_to_lab(extended_color_hex), ColorUtil.rgb_to_lab(b))
      closest_colors[extended_color] = delta
    end
    closest_color = closest_colors.sort_by { |a, d| d }.first
    if @cluster_colors[closest_color[0]]
      closest_color = [@cluster_colors[closest_color[0]],
                       ColorUtil.delta_e(ColorUtil.rgb_to_lab(ColorUtil.rgb_number_from_string(@cluster_colors[closest_color[0]])),
                                         ColorUtil.rgb_to_lab(ColorUtil.rgb_number_from_string(closest_color[0]))) ]
    end
    closest_color
  end

  def self.color_quantity_in_image(palette)
    sum_of_pixels_percent = sum_of_hash(palette).to_f / 100
    palette.each do |k, v|
      palette[k] = [v, v / sum_of_pixels_percent]
    end
    palette
  end

  def self.compute_palette(src_of_image, colors_count)
    image = ::Magick::ImageList.new(src_of_image)
    image = image.quantize(colors_count, Magick::YIQColorspace)
    palette = image.color_histogram # .sort {|a, b| b[1] <=> a[1]}
    image.destroy!
    palette
  end

  # Algorithm defines color preferabbility amongst others
  # (for now it is only sum of place percentage)
  def self.generate_factor(array_of_vars)
    array_of_vars.reduce(:+).to_i
  end

  # Use Magick::HSLColorspace or Magick::SRGBColorspace
  def self.remove_common_color_from_palette(palette, delta, colorspace = Magick::YIQColorspace)
    common_colors = []
    new_palette = []
    palette.each_with_index do |s, index|
      common_colors[index] = []
      palette.each do |color|
        if calculate_new_delta(s, color, delta) < delta
          common_colors[index] << color
        end
      end
      new_palette << common_colors[index].first
    end
    new_palette
  end

  def self.calculate_new_delta(s, color, delta)
    sr = normalize_color s[0].red
    sb = normalize_color s[0].blue
    sg = normalize_color s[0].green
    cr = normalize_color color[0].red
    cb = normalize_color color[0].blue
    cg = normalize_color color[0].green
    new_delta =  ColorUtil.delta_e(ColorUtil.rgb_to_lab([sr, sb, sg]),
                                   ColorUtil.rgb_to_lab([cr, cb, cg]))
  end

  def self.normalize_color(color)
    ColorUtil.normalize(color)
  end

  # flog 29.5
  # Rare: If generated palette have very small colors, expand that to look more nicer
  def self.expand_palette(colors)
    col_array = colors.to_a
    rgb_color_1 = ColorUtil.rgb_from_string(col_array[0][0])
    if col_array.length == 1
      rgb_color_2 = [rgb_color_1[0] + rand(0..10), rgb_color_1[1] + rand(0..20), rgb_color_1[2] + rand(0..30)]
    else
      rgb_color_2 = ColorUtil.rgb_from_string(col_array[-1][0])
    end

    rgb =  ColorUtil.average_rgb(rgb_color_1, rgb_color_2)
    colors.merge!(ColorUtil.rgb_to_string(rgb) => [1, 2])
  end

  def self.slim_palette(colors)
    col_array = colors.to_a
    matrix = Matrix.build(col_array.length, col_array.length) do |row, col|
      rgb_color_1 = ColorUtil.rgb_from_string(col_array[row][0])
      rgb_color_2 = ColorUtil.rgb_from_string(col_array[col][0])
      diff = ColorUtil.delta_e(ColorUtil.rgb_to_lab(rgb_color_1), ColorUtil.rgb_to_lab(rgb_color_2))
      if diff == 0
        100_000
      else
        diff
      end
    end
    colors_position = find_position_in_matrix_of_closest_color(matrix)
    closest_colors = [colors.to_a[colors_position[0]], colors.to_a[colors_position[1]]]
    merge_result = MergeColorsMethods.lab_merge(closest_colors)
    colors.merge!(merge_result[0])
    colors.delete(merge_result[1])
    colors
  end

  def self.find_position_in_matrix_of_closest_color(matrix)
    matrix_array = matrix.to_a
    minimum = matrix_array.flatten.min
    [i = matrix_array.index { |x| x.include? minimum }, matrix_array[i].index(minimum)]
  end

  def self.sum_of_hash(hash)
    s = 0
    hash.each_value { |v| s += v }
    s
  end

end
