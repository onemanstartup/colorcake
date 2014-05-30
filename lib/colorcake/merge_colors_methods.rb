module MergeColorsMethods
  # Shitty method
  # hsl_sl_merge

  # Very good
  # hcl_cl_merge very good too

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
  # luminance_merge
end

