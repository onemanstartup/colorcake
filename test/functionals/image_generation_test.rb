require_relative '../../lib/colorcake'
require 'method_profiler'

Colorcake.configure {}
def run
  files = Array(0..13)
  files.each_with_index do |file, index|
    puts "image - #{index}"
    @new_palette = []
    @old_palette = {}
    some = '<div id="colors">'
    some += "<h1 style='clear:both'>Original Colors</h1>"
    @finded_colors = Colorcake.extract_colors(Dir.pwd + "/fixtures/#{index}.jpg")
    # colors = create_palette(@finded_colors)
    # ap colors
    colorspace_test = ''
    @finded_colors[1].each do |color, percentage|
      # puts color.inspect
      # puts percentage.inspect
      # if color == '#000000' && percentage[1].round(2) <= 5
      # elsif percentage[1].round(2) >= 0.5
        colorspace_test += "<div style='background: #{color}'></div>"
      # end
    end
    some += colorspace_test
    some += "<h1 style='clear:both'>Search Colors</h1>"


    colorspace_test = ""

    @finded_colors[0].each do |color|
      if color[1][:hex_of_base] == 'ffffff'
        colorspace_test += "<div style='background: ##{color[1][:hex_of_base]};color:#333; border:1px solid red'>#{color[1][:search_factor]}</div>"
      else
        colorspace_test += "<div style='background: ##{color[1][:hex_of_base]};color:#fff;' >  #{color[1][:search_factor]} </div>"
      end
    end
    some += colorspace_test
    some += "<h1 style='clear:both'>Palette Colors(original 5 most contrast and colorful colors)</h1>"

    colors = Colorcake.create_palette(@finded_colors[1])
    # # ap colors
    new_colors_test = ''
     colors.sort_by{|x| x[1][1]}.reverse_each do |color, percentage|
       new_colors_test += "<div style='background: #{color};color:#fff;'  >  #{percentage[1].round(2)} </div>"
     end
    some += new_colors_test
    some = "<html><head><style>h1{font-size:16px}#colors{float:left; width: 50%}*{box-sizing:border-box}div{float:left;width:70px;height:70px;line-height:70px; text-align:center; font-weight:bold; font-family: Helvetica, Arial}</style></head><body>" + some + "</div><div id='image'><img style='display:block; clear:both' src='#{index}.jpg'/></div></body></html>"
    #puts some
    puts 'OK'
    File.open("fixtures/photo#{file}.html", 'w') do |f|
      f.write some
    end
  end
end
profiler = MethodProfiler.observe(Colorcake)
run
puts profiler.report
