require 'method_profiler'
require 'benchmark'
module Coll
  def self.to_hsv(r,g,b)
    red, green, blue = [r, g, b].collect {|x| x / 255.0}
    max = [red, green, blue].max
    min = [red, green, blue].min

    if min == max
      hue = 0
    elsif max == red
      hue = 60 * ((green - blue) / (max - min))
    elsif max == green
      hue = 60 * ((blue - red) / (max - min)) + 120
    elsif max == blue
      hue = 60 * ((red - green) / (max - min)) + 240
    end

    saturation = (max == 0) ? 0 : (max - min) / max
    [hue % 360, saturation, max]
  end

  def self.rgb_to_hsv(r,g,b)
    r = r / 255.0
    g = g / 255.0
    b = b / 255.0
    max = [r, g, b].max
    min = [r, g, b].min
    delta = max - min
    v = max * 100

    if (max != 0.0)
      s = delta / max * 100
    else
      s = 0.0
    end

    if (s == 0.0)
      h = 0.0
    else
      if (r == max)
        h = (g - b) / delta
      elsif (g == max)
        h = 2 + (b - r) / delta
      elsif (b == max)
        h = 4 + (r - g) / delta
      end

      h *= 60.0

      if (h < 0)
        h += 360.0
      end
    end
    {:h => h, :s => s, :v => v}
    # returns h in the range of 0..360 deg
    # s 0...100
    # v 0...100
  end

  def rgb_to_lab
  end

  def rgb_to_yuv
  end

  def rgb_to_yuv_2
  end

  def to_hsl
  end

  def rgb_to_hcl
  end
end

def run
  iterations = 100_000

  Coll.to_hsv(211,45,20)
  Benchmark.bm do |bm|
    # joining an array of strings
    bm.report do
      iterations.times do
        Coll.rgb_to_hsv(211,45,20)
      end
    end

    # using string interpolation
    bm.report do
      iterations.times do
        Coll.to_hsv(211,45,20)
      end
    end
  end
end
profiler = MethodProfiler.observe(Coll)
run
puts profiler.report
