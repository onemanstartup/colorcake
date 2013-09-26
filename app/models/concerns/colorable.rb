# -*- encoding : utf-8 -*-
module Colorable
  extend ActiveSupport::Concern
  included do
    has_many :colors, as: :colorable
    has_many :search_colors, through: :colors
    after_create :generate_colors
    after_create :generate_palette
    scope :by_color, -> colors {
      if !colors.blank?
        col = SearchColor.where('color in (?)', colors).pluck(:id)
        col_in = col.join(',')
        joins("inner join(select colorable_id, sum(search_factor) as search_factor
              from colors
              where search_color_id IN (#{col_in}) AND search_factor > 5
              group by colorable_id having COUNT(colorable_id) = #{col.length})
              as matched on #{self.name.tableize}.id = matched.colorable_id").order('search_factor').reorder("search_factor DESC, #{self.name.tableize}.id DESC")
      end
    }
    def generate_colors
      if !image.nil? && File.exists?(image_path_for_color_generator)
        colors.destroy_all
        @finded_colors = Colorcake.extract_colors(image_path_for_color_generator)
        @finded_colors[0].each do |color|
          colors.create(search_color_id: color[1][:search_color_id], search_factor: color[1][:search_factor], distance: color[1][:distance])
        end
      end
    end

    # Generate palette if colors already generated
    def s_generate_palette
      colors_hex = {}
        Color.where(:colorable_id => self.id, :colorable_type => self.class.superclass).each do |color|
          colors_hex['#' + SearchColor.find(color.search_color_id).color] = [color.distance]
        end
      self.palette = Colorcake.create_palette(colors_hex).keys.join(',')
      self.save
    end

  private

    # Generate palette and saves after generate_colors
    def generate_palette
      begin
        self.palette = Colorcake.create_palette(@finded_colors[1]).keys.join(',')
        self.save
      rescue => e
        puts "ERROR!!! #{e.message}"
      end
    end
  end
end


