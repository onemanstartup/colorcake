namespace :colorcake do
  # TODO: Make to take argument for which model is regenerate colors
  desc "Regenerate Colors"
  task regenerate_colors: :environment do
    puts 'Colorcake is regenerate colors...'
    count = total = 0
    Photo.find_each do |photo|
      print "Processing Photo#{photo.id}... "
      begin
        photo.image.recreate_versions!
        photo.save
        count += 1
        puts "OK"
      rescue => e
        puts "FAIL (#{ e.message })"
        puts e.backtrace
      end
      total += 1
    end
    puts "Processed: #{count} of #{total}."
  end
end
