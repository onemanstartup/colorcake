module ColorUtil
  PIP2 = Math::PI / 2
  GAMMA = 3
  Y0    = 100
  Ah_inc = 0.16
  Al = 1.4456

  def self.rgb_from_string(string)
    color = []
    oc = 0
    string.each_char do |c|
      if (c != "#")
        if oc == 0
          oc = c
        else
          color << (oc+c).hex
          oc = 0
        end
      end
    end
    color
  end

  def self.distance_rgb( rgb1, rgb2 )
    (100)*Math.sqrt(( ( (rgb1[0]-rgb2[0])**2 +
                       (rgb1[1]-rgb2[1])**2 +
                       (rgb1[2]-rgb2[2])**2 ) ).abs)
  end

  def self.euclid_distance_rgb( rgb1, rgb2 )
    d = 0
    (0..rgb1.length-1).each do |i|
      d += (rgb1[i] - rgb2[i]) * (rgb1[i] - rgb2[i])
    end
    Math.sqrt(d)
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

  def self.rgb_to_hcl(r,g,b)
    rg = r - g
    gb = g - b
    br = b - r

    max = [r, g, b].max
    min = [r, g, b].min
    return [ 0, 0, 0 ] if max == 0
    alpha = ( min / max ) / Y0;
    q = Math.exp(alpha * GAMMA)

    l = ( q * max + ( 1 - q ) * min ) / 2
    c = q * ( rg.abs + gb.abs + br.abs ) / 3
    h = rad2deg( atan( gb, rg ) )

    # The paper uses 180, not 90, but using 180 gives
    # red the same HCL value as green...
    #   Alternative A
    #    $H = 90 + $H         if $rg <  0 && $gb >= 0;
    #    $H = $H - 90         if $rg <  0 && $gb <  0;
    #   Alternative B
    #    $H = 2 * $H / 3      if $rg >= 0 && $gb >= 0;
    #    $H = 4 * $H / 3      if $rg >= 0 && $gb <  0;
    #    $H = 90 + 4 * $H / 3 if $rg <  0 && $gb >= 0;
    #    $H = 3 * $H / 4 - 90 if $rg <  0 && $gb <  0;
    #   From http://w3.uqo.ca/missaoui/Publications/TRColorSpace.zip
    if rg >= 0 && gb >= 0
      h = 2 * h / 3
    end
    if rg >= 0 && gb <  0
      h = 4 * h / 3
    end
    if rg <  0 && gb >= 0
      h = 180 + 4 * h / 3
    end
    if rg <  0 && gb <  0
      h = 2 * h / 3 - 180
    end
    [ h, c, l ]
  end

  def self.distance_hcl( hcl1, hcl2 )
    ah = (hcl1[0] - hcl2[0]).abs + Ah_inc
    dl = (hcl1[2] - hcl2[2]).abs
    dh = (hcl1[0] - hcl2[0]).abs
    # here it used to use <x> ** 2 to compute squares, but this causes
    # some rounding problems
    aldl = Al * dl
    a = aldl * aldl + ah * (hcl1[1] * hcl1[1] + hcl2[2] * hcl1[2] - 2 * hcl1[1] * hcl1[2] * Math.cos( deg2rad( dh ) ))
    a = a.abs
    Math.sqrt(a)

  end

  def self.to_hsl(r,g,b)
    var_R = ( r / 255 )                     # RGB from 0 to 255
    var_G = ( g / 255 )
    var_B = ( b / 255 )

    var_Min = [var_R, var_G, var_B].min    # Min. value of RGB
    var_Max = [var_R, var_G, var_B].max    # Max. value of RGB
    del_Max = var_Max - var_Min             # Delta RGB value

    l = ( var_Max + var_Min ) / 2

    if ( del_Max == 0 )                     # This is a gray, no chroma...
      h = 0                                # HSL results from 0 to 1
      s = 0
    else                                    # hromatic data...
      if ( l < 0.5 )
        s = del_Max / ( var_Max + var_Min )
      else
        s = del_Max / ( 2 - var_Max - var_Min )
      end
      del_R = ( ( ( var_Max - var_R ) / 6 ) + ( del_Max / 2 ) ) / del_Max
      del_G = ( ( ( var_Max - var_G ) / 6 ) + ( del_Max / 2 ) ) / del_Max
      del_B = ( ( ( var_Max - var_B ) / 6 ) + ( del_Max / 2 ) ) / del_Max

      if      ( var_R == var_Max )
        h = del_B - del_G
      elsif ( var_G == var_Max )
        h = ( 1 / 3 ) + del_R - del_B
      elsif ( var_B == var_Max )
        h = ( 2 / 3 ) + del_G - del_R
      end
      if ( h < 0 )
        h += 1
      end
      if ( h > 1 )
        h -= 1
      end
    end
  end

  private

  def self.rad2deg(r)
    (r/Math::PI)*180
  end

  def self.deg2rad(d)
    (d/180.0)*Math::PI
  end

  def self.atan(x, y)
    return y < 0 ? -PIP2 : PIP2 if x == 0
    Math.atan(y/x)
  end
end

