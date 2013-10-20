# TODO: Removing background if needed
module Pxls
  class Pixelator
    def initialize(img_location)
      @image = Magick::ImageList.new(img_location)
    end

    def get_colors(n=6, remove_bg=true)
        n += 1
        image = remove_bg ? remove_bg(n) : reduce_size(100, 100)
        q = image.quantize(n)
        histogram = q.color_histogram
        pixels = to_pixels(histogram.keys)
        pixels.sort
        pixels.delete('black')
        return pixels
    end

    def to_pixels(colors)
      colors_out = Array.new
      colors.each do |pixel|
        colors_out << to_hex(pixel)
      end
      return colors_out
    end

    def to_hex(pixel)
      pixel.to_color(Magick::AllCompliance, false, 8)
    end

    def reduce_size(width, height)
      @image.change_geometry!("#{width}x#{height}") { |cols, rows, img| img.resize_to_fit!(cols, rows) }
    end

    def remove_bg(nc, fuzz=20)
      image = reduce_size(100, 100)
      image = image.border(1, 1, image.pixel_color(0,0))
      image = image.quantize(nc+4)
      image.fuzz = "#{fuzz}%"
      a = image.color_floodfill(0, 0, image.pixel_color(0,0))
      a = a.matte_floodfill(0,0)
    end
  end
end

# TODO: Text color on image
# Returns an appropriate text color (either black or white) based on
# the brightness of this color. The +threshold+ specifies the brightness
# cutoff point.
def text_color(threshold=0.6, formula=:standard)
  brightness(formula) > threshold ? Colorist::Color.new(0x000000) : Colorist::Color.new(0xffffff)
end

# TODO: modify brightness of color

    # Returns the perceived brightness of the provided color on a
    # scale of 0.0 to 1.0 based on the formula provided. The formulas
    # available are:
    #
    # * <tt>:w3c</tt> - <tt>((r * 299 + g * 587 + b * 114) / 1000 / 255</tt>
    # * <tt>:standard</tt> - <tt>sqrt(0.241 * r^2 + 0.691 * g^2 + 0.068 * b^2) / 255</tt>
    def brightness(formula=:w3c)
      case formula
        when :standard
          Math.sqrt(0.241 * r**2 + 0.691 * g**2 + 0.068 * b**2) / 255
        when :w3c
          ((r * 299 + g * 587 + b * 114) / 255000.0)
      end
    end

    # Converts the current color to grayscale using the brightness
    # formula provided. See #brightness for a description of the
    # available formulas.
    def to_grayscale(formula=:w3c)
      b = brightness(formula)
      Color.from_rgb(255 * b, 255 * b, 255 * b)
    end


    # Returns the opposite of the current color.
    def invert
      Color.from_rgb(255 - r, 255 - g, 255 - b)
    end

    # Contrast this color with another color using the provided formula. The
    # available formulas are:
    #
    # * <tt>:w3c</tt> - <tt>(max(r1 r2) - min(r1 r2)) + (max(g1 g2) - min(g1 g2)) + (max(b1 b2) - min(b1 b2))</tt>
    def contrast_with(other_color, formula=:w3c)
      other_color = Color.from(other_color)
      case formula
        when :w3c
          (([self.r, other_color.r].max - [self.r, other_color.r].min) +
          ([self.g, other_color.g].max - [self.g, other_color.g].min) +
          ([self.b, other_color.b].max - [self.b, other_color.b].min)) / 765.0
      end
    end


    # Returns an array of the hue, saturation and value of the color.
    # Hue will range from 0-359, hue and saturation will be between 0 and 1.

    def to_hsv
      red, green, blue = *[r, g, b].collect {|x| x / 255.0}
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


    # Colorspaces
    # There are five major models, that sub-divide into others, which are: CIE, RGB, YUV, HSL/HSV, and CMYK
    # CIE
    #
    # CIE 1931 XYZ
    # The first attempt to produce a color space based on measurements of human color perception and it is the basis for almost all other color spaces
    #
    # CIELUV
    # A modification of "CIE 1931 XYZ" to display color differences more conveniently. The CIELUV space is especially useful for additive mixtures of lights, due to its linear addition properties
    #
    # CIELAB
    # The intention of CIELAB (or L*a*b* or Lab) is to produce a color space that is more perceptually linear than other color spaces.
    # Perceptually linear means that a change of the same amount in a color value should produce a change of about the same visual importance.
    # CIELAB has almost entirely replaced an alternative related Lab color space "Hunter Lab". This space is commonly used for surface colors, but not for mixtures of (transmitted) light
    #
    # CIEUVW
    # With the co-efficients thus selected, the color difference in CIEUVW is simply the Euclidean distance:
    #
    # RGB
    #
    # sRGB
    # sRGB is intended as a common color space for the creation of images for viewing on the Internet and World Wide Web (WWW), the resultant color space chosen using a gamma of 2.2,
    # the average response to linear voltage levels of CRT displays at that time
    #
    #
