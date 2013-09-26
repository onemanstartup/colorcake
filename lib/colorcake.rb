require "colorcake/version"
require "colorcake/color_util"
require "colorcake/merge_colors_methods"
require 'matrix'
require 'rmagick'

module Colorcake
  require 'colorcake/engine' if defined?(Rails)
  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end

  class Configuration
    attr_accessor :base_colors, :colors_count, :max_numbers_of_color_in_palette, :white_threshold, :black_threshold, :fcmp_distance_value

    def initialize
      @base_colors ||= %w(660000 cc0000 ea4c88 993399 663399 0066cc 66cccc 77cc33 336600 cccc33 ffcc33 ff6600 c8ad7f 996633 663300 000000 999999 cccccc ffffff)
      @colors_count ||= 32
      @max_numbers_of_color_in_palette ||= 5
      @white_threshold ||= 50000
      @black_threshold ||= 1500
      @fcmp_distance_value ||= 7000
    end
  end

  @new_palette = []
  @old_palette = {}

  def self.extract_colors(src, colorspace=::Magick::RGBColorspace)
    @new_palette = []
    @old_palette = {}
    image = ::Magick::ImageList.new(src)
    colors = {}
    colors_hex = {}
    image = image.white_threshold(configuration.white_threshold).black_threshold(configuration.black_threshold)
    image = image.quantize(configuration.colors_count, Magick::SRGBColorspace)
    palette = image.color_histogram #.sort {|a, b| b[1] <=> a[1]}
    image.destroy!
    sum_of_pixels = sum_of_hash(palette)
    palette.each do |k,v|
      palette[k] = [v, v/(sum_of_pixels.to_f/100)]
    end
    @old_palette = palette
    @new_palette = []
    # Use Magick::HSLColorspace or Magick::SRGBColorspace
    remove_common_color_from_palette(palette, Magick::RGBColorspace)

    (0..@new_palette.length-1).each do |i|
      c = @new_palette[i][0].to_s.split(',').map {|x| x[/\d+/]}
      c.pop
      c[0], c[1], c[2] = [c[0], c[1], c[2]].map { |s|
        s = s.to_i
        if s / 255 > 0 # not all ImageMagicks are created equal....
          s = s / 257
        end
        s = s.to_s(16)
        if s.size == 1
          '0' + s
        else
          s
        end
      }
      b = c.join('').scan(/../).map {|color| color.to_i(16)}
      distances = {}
      configuration.base_colors.each do |color_20|
        c20 = color_20.scan(/../).map {|color| color.to_i(16)}
        distances[color_20] = ColorUtil.distance_rgb( c20, b )

        # ColorUtil.distance_hcl( ColorUtil.rgb_to_hcl( c16[0], c16[1], c16[2] ) , ColorUtil.rgb_to_hcl( b[0], b[1], b[2] ))
      end
      distances = distances.sort_by {|a,d| d}
      distance = distances.first
      # colors['#' + c.join('')] = {r:b[0] , g:b[1] , b:b[2], hex_28: distance[0], distance_to_28: distance[1], hex:c.join('')} # @new_palette[i][1]
      # colors['#' + c.join('')] = {search_color_id: SearchColor.find_by_color(distance[0]).id,
      #                             search_factor: distance[1]
      # } # @new_palette[i][1]
      percentage = @new_palette[i][1][1]
      colors_hex['#' + c.join('')] = @new_palette[i][1]

      # Disable when not working with Database
      #id = SearchColor.where(color:distance[0]).first.id
      id = configuration.base_colors.index(c.join(''))
      colors[id] ||= {}
      colors[id][:search_color_id] ||= id
      colors[id][:search_factor] ||= []
      colors[id][:search_factor] << percentage
      colors[id][:distance] ||= []
      colors[id][:hex] ||= c.join('')
      if colors[id][:distance] == []
        colors[id][:distance] = distance[1]
      end
    end

    colors.each_with_index do |fac, index|
      colors[fac[0]][:search_factor] = generate_factor(fac[1][:search_factor])
    end
    # Disable when not working with DB
    # [colors, colors_hex]
    [colors, colors_hex]
  end

  def self.create_palette(colors)
    if colors.length > configuration.max_numbers_of_color_in_palette
      colors = slim_palette(colors)
      create_palette(colors)
    elsif colors.length == configuration.max_numbers_of_color_in_palette
      return colors
    else
    end
  end

  private

  # Algorithm defines color preferabbility amongst others (for now it is only sum of place percentage)
  def self.generate_factor(array_of_vars)
    array_of_vars.inject{|sum, n| sum + n}.to_i
  end

  def self.remove_common_color_from_palette(palette, colorspace)
    common_colors = []
    palette.each_with_index do |s, index|
      common_colors[index] = []
      if index < palette.length - 1
        palette.each do |color|
          if s[0].fcmp(color[0], configuration.fcmp_distance_value, colorspace)
            common_colors[index] << color
            common_colors[index] << s
            common_colors[index].uniq!

            if common_colors[index].first[1][1] && common_colors[index].first[1][1] != color[1][1]
              common_colors[index].first[1][1] += color[1][1]
            elsif common_colors[index].first[1][1] == color[1][1]
              common_colors[index].first[1][1] = color[1][1]
            else
            end
          end
        end
        common_colors[index].uniq!
        @new_palette << common_colors[index].first
        common_colors[index].each_with_index do |col, ind|
          if ind != 0
            @old_palette.tap { |hs| hs.delete(col[0]) }
          end
        end
      else
      end
    end
  end

  def self.slim_palette(colors)
    col_array = colors.to_a
    matrix = Matrix.build(col_array.length, col_array.length) do |row, col|
      rgb_color_1 = ColorUtil.rgb_from_string(col_array[row][0])
      rgb_color_2 = ColorUtil.rgb_from_string(col_array[col][0])
      pixel_1 = [rgb_color_1[0], rgb_color_1[1], rgb_color_1[2]]
      pixel_2 = [rgb_color_2[0], rgb_color_2[1], rgb_color_2[2]]
      diff = ColorUtil.euclid_distance_rgb(pixel_1, pixel_2)
      # c1 = ColorUtil.rgb_to_hcl(rgb_color_1[0], rgb_color_1[1], rgb_color_1[2])
      # c2 = ColorUtil.rgb_to_hcl(rgb_color_2[0], rgb_color_2[1], rgb_color_2[2])
      # diff = ColorUtil.distance_hcl(c1, c2)
      if diff == 0
        100000
      else
        diff
      end
    end
    colors_position = find_position_in_matrix_of_closest_color(matrix)
    closest_colors = [colors.to_a[colors_position[0]], colors.to_a[colors_position[1]]]
    merge_result = MergeColorsMethods.hcl_cl_merge(closest_colors)
    colors.merge!(merge_result[0])
    colors.delete(merge_result[1])
    colors
  end

  def self.find_position_in_matrix_of_closest_color(matrix)
    matrix_array = matrix.to_a
    minimum = matrix_array.flatten.min
    [i = matrix_array.index{|x| x.include? minimum}, matrix_array[i].index(minimum)]
  end

  def self.sum_of_hash(hash)
    s = 0
    hash.each_value { |v| s += v }
    s
  end

end
