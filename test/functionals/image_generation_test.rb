require_relative '../../lib/colorcake'
Colorcake.configure {}
def run
  files = Array(0..16)
  files.each_with_index do |file, index|
    @new_palette = []
    @old_palette = {}
    some = ''
    @finded_colors = Colorcake.extract_colors(Dir.pwd + "/fixtures/#{index}.jpg")
    # colors = create_palette(@finded_colors)
    # ap colors
    colorspace_test = ''
    @finded_colors[1].sort_by{|x| x[1][1]}.reverse_each do |color, percentage|
      # if color == '#000000' && percentage[1].round(2) <= 5
      # elsif percentage[1].round(2) >= 0.5
        colorspace_test += "<div style='background: #{color}'  >  #{percentage[1].round(2)} </div>"
      # end
    end
    some += colorspace_test
    some += "<h1 style='clear:both'>Palette</h1>"
    colors = Colorcake.create_palette(@finded_colors[1])
    # ap colors
    new_colors_test = ''
    colors.sort_by{|x| x[1][1]}.reverse_each do |color, percentage|
      # if color == '#000000' && percentage[1].round(2) <= 5
      # elsif percentage[1].round(2) >= 0.5
        new_colors_test += "<div style='background: #{color}'  >  #{percentage[1].round(2)} </div>"
      # end
    end
    some += new_colors_test
    some = "<html><head><style>div{float:left;width:70px;height:70px;line-height:70px; text-align:center; font-weight:bold; color:#fff}</style></head><body>" + some + "<img style='display:block; clear:both' src='#{index}.jpg'/></body></html>"
    #puts some
    puts 'OK'
    File.open("fixtures/photo#{file}.html", 'w') do |f|
      f.write some
    end
  end
end
run

