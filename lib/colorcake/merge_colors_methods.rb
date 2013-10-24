
module MergeColorsMethods
# Shitty method
  def self.hsl_sl_merge(colors)
    c1 = ColorUtil.rgb_from_string(colors[0][0])
    c2 = ColorUtil.rgb_from_string(colors[1][0])
    c1 = ColorUtil.to_hsl(c1[0], c1[1], c1[2])
    c2 = ColorUtil.to_hsl(c2[0], c2[1], c2[2])
    colors[0][1] << c1[1] + c1[2]
    colors[1][1] << c2[1] + c2[2]
    color = colors.max_by do |el|
      el[1][2]
    end
    min_color = colors.min_by do |el|
      el[1][2]
    end
    color[1][1] = colors.inject {|sum, n| sum[1][1] + n[1][1]}
    [{color[0] => color[1]}, min_color[0]]
  end

# Very good
  def self.hcl_cl_merge(colors)
    c1 = ColorUtil.rgb_from_string(colors[0][0])
    c2 = ColorUtil.rgb_from_string(colors[1][0])
    c1 = ColorUtil.rgb_to_hcl(c1[0], c1[1], c1[2])
    c2 = ColorUtil.rgb_to_hcl(c2[0], c2[1], c2[2])
    colors[0][1] << c1[1] #+ c1[1]
    colors[1][1] << c2[1] #+ c2[1]
    color = colors.max_by do |el|
      el[1][1]
    end
    min_color = colors.min_by do |el|
      el[1][1]
    end
    color[1][1] = colors.inject {|sum, n| sum[1][1] + n[1][1]}
    [{color[0] => color[1]}, min_color[0]]
  end
  def self.lab_merge(colors)
    c1 = ColorUtil.rgb_from_string(colors[0][0])
    c2 = ColorUtil.rgb_from_string(colors[1][0])
    c1 = ColorUtil.rgb_to_lab([c1[0], c1[1], c1[2]])
    c2 = ColorUtil.rgb_to_lab([c2[0], c2[1], c2[2]])
    # colors[0][1] << ColorUtil.delta_e(c1, c2, :cie76)
 # c1[1] #+ c1[1]
    color = colors.max_by do |el|
      el[1][1]
    end
    min_color = colors.min_by do |el|
      el[1][0]
    end
    color[1][0] = colors.inject {|sum, n| sum[1][0] + n[1][0]}
    [{color[0] => color[1]}, min_color[0]]
  end
# Ok method when you don't need small, bright, contrasted objects to be merged in palette
def self.percentage_merge(colors)
  color = colors.max_by do |el|
    el[1][1]
  end
  min_color = colors.min_by do |el|
    el[1][1]
  end
  color[1][1] = colors.inject {|sum, n| sum[1][1] + n[1][1]}
  [{color[0] => color[1]}, min_color[0]]
end

# Shitty but with violet
  def self.luminance_merge(colors)
    c1 = ColorUtil.rgb_from_string(colors[0][0])
    c2 = ColorUtil.rgb_from_string(colors[1][0])
    colors[0][1] << (0.299*c1[0] + 0.587*c1[1]+ 0.114*c1[2])
    colors[1][1] << (0.299*c2[0] + 0.587*c2[1]+ 0.114*c2[2])
    color = colors.max_by do |el|
      el[1][2]
    end
    min_color = colors.min_by do |el|
      el[1][2]
    end
    color[1][1] = colors.inject {|sum, n| sum[1][1] + n[1][1]}
    [{color[0] => color[1]}, min_color[0]]
  end

# Pretty much the same as luminance, cause it's very likely the same algorithm
  def self.intensity_merge(colors)
    c1 = ColorUtil.rgb_from_string(colors[0][0])
    c2 = ColorUtil.rgb_from_string(colors[1][0])
    colors[0][1] << Magick::Pixel.new(c1[0], c1[1], c1[2] ).intensity
    colors[1][1] << Magick::Pixel.new(c2[0], c2[1], c2[2] ).intensity
    color = colors.max_by do |el|
      el[1][2]
    end
    min_color = colors.min_by do |el|
      el[1][2]
    end
    color[1][1] = colors.inject {|sum, n| sum[1][1] + n[1][1]}
    [{color[0] => color[1]}, min_color[0]]
  end
end

