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

  def self.rgb_number_from_string(string)
    string.scan(/../).map { |color| color.to_i(16) }
  end

  def self.distance_rgb_strings(rgb1, rgb2)
    distance_rgb(
      rgb_number_from_string(rgb1),
      rgb_number_from_string(rgb2))
  end

  def self.distance_rgb(rgb1, rgb2)
    (100) * Math.sqrt(( ( (rgb1[0] - rgb2[0])**2 +
                         (  rgb1[1] - rgb2[1])**2 +
                         (rgb1[2] - rgb2[2])**2)).abs)
  end

  def self.euclid_distance_rgb(rgb1, rgb2)
    d = 0
    (0..rgb1.length-1).each do |i|
      d += (rgb1[i] - rgb2[i]) * (rgb1[i] - rgb2[i])
    end
    Math.sqrt(d)
  end

  def self.rgb_to_hcl(rgb)
    r, g, b = *rgb
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


  def self.rgb_to_yuv_2(rgb)
    y  =  (0.257 * rgb[0]) + (0.504 * rgb[1]) + (0.098 * rgb[2]) + 16
    # Cr
    v =   (0.439 * rgb[0]) - (0.368 * rgb[1]) - (0.071 * rgb[2]) + 128
    # Cb
    u =  -(0.148 * rgb[0]) - (0.291 * rgb[1]) + (0.439 * rgb[2]) + 128
    [y,v,u]
  end

  def self.rgb_to_yuv(rgb)
    y  =  (0.299 * rgb[0]) + (0.587 * rgb[1]) + (0.114 * rgb[2])
    # Cr
    v =   (rgb[2] - y)*0.565
    # Cb
    u =   (rgb[0] - y)*0.713
    [y,v,u]
  end

  def self.delta_e(one, other, method=:cie2k)
    # http://en.wikipedia.org/wiki/Color_difference
    # http://www.brucelindbloom.com/iPhone/ColorDiff.html
    l1, a1, b1 = one[0], one[1], one[2]
    l2, a2, b2 = other[0], other[1], other[2]
    c1, c2 = lab_chroma(one[1], one[2]), lab_chroma(other[1], other[2])
    h1 = lab_hue(one[1], one[2])#h2 = lab_hue(other[1], other[2])
    dl = l2 - l1
    da = a1 - a2
    db = b1 - b2
    dc = c1 - c2
    dh2 = da**2 + db**2 - dc**2
    return 10000 if dh2 < 0
    dh = Math::sqrt(dh2)
    case method
    when :density
      dl.abs
    when :cie76
      Math::sqrt(dl**2 + da**2 + db**2)
    when :cie94
      kl, k1, k2 = 1, 0.045, 0.015
      Math::sqrt(
        (dl / kl)**2 +
        (dc / (1 + k1*c1))**2 +
        (dh / (1 + k2*c2)**2)
      )
    when :cmclc
      l, c = 2, 1
      sl = (l1 < 16) ?
        0.511 :
        0.040975 * l1 / (1 + 0.01765 * l1)
      sc = 0.0638 * c1 / (1 + 0.0131 * c1) + 0.638
      f = Math::sqrt(
        (c1 ** 4) / ((c1 ** 4) + 1900)
      )
      t = (h1 >= 164 && h1 <= 345) ?
        0.56 + (0.2 * Math.cos(deg2rad(h1 + 168))).abs :
        0.36 + (0.4 * Math.cos(deg2rad(h1 + 35))).abs
      sh = sc * ((f * t) + 1 - f)
      Math::sqrt(
        (dl / (l * sl)) ** 2 +
        (dc / (c * sc)) ** 2 +
        (dh / sh) ** 2
      )
    when :cie2k
      pow25_7 = 25**7
      k_L = 1.0
      k_C = 1.0
      k_H = 1.0
      c1 = Math.sqrt(a1**2 + b1**2)
      c2 = Math.sqrt(a2**2 + b2**2)
      c_avg = (c1 + c2) / 2
      g = 0.5 * (1 - Math.sqrt(c_avg**7 / (c_avg**7 + pow25_7)))
      l1_ = l1
      a1_ = (1 + g) * a1
      b1_ = b1
      l2_ = l2
      a2_ = (1 + g) * a2
      b2_ = b2
      c1_ = Math.sqrt(a1_**2 + b1_**2)
      c2_ = Math.sqrt(a2_**2 + b2_**2)
      if a1_ == 0 and b1_ == 0
        h1_ = 0
      else
        if b1_ >= 0
          pl = 0
        else
          pl = 360.0
        end
        h1_ = rad2deg(Math.atan2(b1_, a1_)) + pl
      end
      if a2_ == 0 and b2_ == 0
        h2_ = 0
      else
        if b2_ >= 0
          pl = 0
        else
          pl = 360.0
        end
        h2_ = rad2deg(Math.atan2(b2_, a2_)) + pl
      end

      if h2_ - h1_ > 180
        dh_cond = 1.0
      else
        if h2_ - h1_ < -180
          dh_cond = 2.0
        else
          dh_cond = 0
        end
      end

      if dh_cond == 0
        dh_ = h2_ - h1_
      else
        if dh_cond == 1
          dh_ = h2_ - h1_ - 360.0
        else
          dh_ = h2_ + 360.0 - h1_
        end
      end

      dl_ = l2_ - l1_
      dl = dl_
      dc_ = c2_ - c1_
      dc = dc_
      dh_ = 2 * Math.sqrt(c1_ * c2_) * Math.sin(deg2rad(dh_ / 2.0))
      dh = dh_
      l__avg = (l1_+ l2_) / 2
      c__avg = (c1_+ c2_) / 2
      if c1_ * c2_ == 0
        h__avg_cond = 3.0
      else
        if (h2_ - h1_).abs <= 180
          h__avg_cond = 0
        else
          if h2_ + h1_ < 360
            h__avg_cond = 1.0
          else
            h__avg_cond = 2.0
          end
        end
      end

      if h__avg_cond == 3
        h__avg = h1_ + h2_
      else
        if h__avg_cond == 0
          h__avg = (h1_+ h2_) / 2
        else
          if h__avg_cond == 1
            h__avg = (h1_+ h2_) / 2 + 180.0
          else
            h__avg = (h1_+ h2_) / 2 - 180.0
          end
        end
      end
      ab = (l__avg - 50.0)**2  # (L'_ave-50)^2
      s_l = 1 + 0.015 * ab / Math.sqrt(20.0 + ab)
      s_c = 1 + 0.045 * c__avg
      t = (1 - 0.17 * Math.cos(deg2rad(h__avg - 30.0)) + 0.24 * Math.cos(deg2rad(2.0 * h__avg)) + 0.32 * Math.cos(deg2rad(3.0 * h__avg + 6.0)) - 0.2 * Math.cos(deg2rad(4 * h__avg - 63.0)))
      s_h = 1 + 0.015 * c__avg * t
      dtheta = 30.0 * Math.exp(-1 * ((h__avg - 275.0) / 25.0)**2)
      r_c = 2.0 * Math.sqrt(c__avg**7 / (c__avg**7 + pow25_7))
      r_t = -Math.sin(deg2rad(2.0 * dtheta)) * r_c
      aj = dl_ / s_l / k_L  # dL' / k_L / S_L
      ak = dc_ / s_c / k_C  # dC' / k_C / S_C
      al = dh_ / s_h / k_H  # dH' / k_H / S_H
      Math.sqrt(aj**2 + ak**2 + al**2 + r_t * ak * al)
    else
      raise "Unknown deltaE method: #{method.inspect}"
    end
  end


  X_D65 = 0.9504
  Y_D65 = 1.0
  Z_D65 = 1.0888


  def self.rgb_to_lab_bad(rgb)
    f_x = function_lab(rgb[0] / X_D65)
    f_y = function_lab(rgb[1] / Y_D65)
    f_z = function_lab(rgb[2] / Z_D65)

    l = 116 * f_y - 16
    a = 500 * ( f_x - f_y )
    b = 200 * ( f_y - f_z )

    [l, a, b]
  end

  def self.rgb_to_lab(rgb)
    r, g, b = normalize(rgb[0]),normalize(rgb[1]),normalize(rgb[2])

    x =  0.436052025 * r + 0.385081593 * g + 0.143087414 * b
    y =  0.222491598 * r + 0.71688606  * g + 0.060621486 * b
    z =  0.013929122 * r + 0.097097002 * g + 0.71418547  * b

    xr = x / 0.964221
    yr = y
    zr = z / 0.825211

    eps = 216.0 / 24389
    k = 24389.0 / 27

    fx = xr > eps ? xr ** (1.0 / 3) : (k * xr + 16) / 116
    fy = yr > eps ? yr ** (1.0 / 3) : (k * yr + 16) / 116
    fz = zr > eps ? zr ** (1.0 / 3) : (k * zr + 16) / 116

    l = ((116 * fy) - 16) #2.55 *
    a = 500 * (fx - fy)
    b = 200 * (fy - fz)

    [l.round, a.round, b.round]
  end
  private

  def self.normalize(v)
    v /= 255.0
    if v <= 0.04045
      v / 12
    else
      ( (v + 0.055) / 1.055) ** 2.4
    end
  end


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

  def self.lab_chroma(a,b)
    # http://www.brucelindbloom.com/Eqn_Lab_to_LCH.html
    Math::sqrt((a * a) + (b * b))
  end

  def self.lab_hue(a, b)
    # http://www.brucelindbloom.com/Eqn_Lab_to_LCH.html
    if a == 0 && b == 0
      0
    else
      rad2deg(Math::atan2(b, a)) % 360
    end
  end

  def self.function_lab(t)
    if t > 0.008856
      t ** ( 1 / 3.0 )
    else
      7.787 * t + ( 4 / 29.0 )
    end
  end

end
