# -*- encoding : utf-8 -*-
# Add colors functions to model
module Colorable
  extend ActiveSupport::Concern
  included do
    attr_accessor :modified_palette

    has_many :colors, as: :colorable
    has_many :search_colors, through: :colors

    attr_accessor :modified_palette
    accepts_nested_attributes_for :colors, update_only: true

    after_create :process_colors

    scope :by_color, -> colors {
      if !colors.blank?
        col = SearchColor.where('color in (?)', colors).pluck(:id)
        col_in = col.join(',')
        joins("inner join(select colorable_id, sum(distance) as dist, sum(search_factor) as search_factor
              from colors
              where search_color_id IN (#{col_in}) AND search_factor > 2 AND colorable_type = '#{self.base_class.name}'
              group by colorable_id having COUNT(colorable_id) = #{col.length})
              as matched on #{self.name.tableize}.id = matched.colorable_id").order('search_factor').reorder("search_factor DESC, dist DESC, #{self.name.tableize}.id DESC")
      end
    }
    def process_colors
      generate_colors
    end

    def generate_colors
      if image_path_for_color_generator && File.exists?(image_path_for_color_generator)
        if untouched_palette?
          colors.destroy_all
          @finded_colors = Colorcake.extract_colors(image_path_for_color_generator)
          @finded_colors[0].each do |color|
            colors.create(search_color_id: color[1][:search_color_id], search_factor: color[1][:search_factor], distance: color[1][:distance])
          end
          generate_palette(@finded_colors[1])
        else
          generate_palette_from_active
        end
      end
    end

    # Generate palette if colors already generated
    # Gives bad results
    def s_generate_palette
      colors_hex = {}
        Color.where(:colorable_id => self.id, :colorable_type => self.class.superclass).each do |color|
          colors_hex['#' + SearchColor.find(color.search_color_id).color] = [color.distance]
        end
      self.palette = Colorcake.create_palette(colors_hex).keys.join(',')
      self.save
    end

    # Generate palette if colors already generated
    def generate_palette_from_active
      begin
        if image_path_for_color_generator && File.exists?(image_path_for_color_generator)
          # find original colors because we don't store them
          @finded_colors = Colorcake.extract_colors(image_path_for_color_generator)
        end
        # store here original colors in right format
        coll = []
        colors.where(active: true).pluck(:id).each do |id|
          color = Color.find(id)
          @finded_colors.first.each do |k, v|
            if v[:search_color_id] == color.search_color_id
              coll << v[:original_color]
            end
          end
        end
        colors_for_palette = coll.inject({}) { |s, o| s.merge(o[0]) }
        generate_palette(colors_for_palette)
      rescue => e
        puts "#{e.inspect}"
        errors[:base] << e.message
      end
    end

  private

    def untouched_palette?
      colors.where(active: false).count == 0
    end

    # colors is for example {"#333300" => [1,2]}
    def generate_palette(colors)
      begin
        self.palette = Colorcake.create_palette(colors).keys.join(',')
        self.modified_palette = nil
        save
      rescue => e
          puts "ERROR!!! #{e.message}"
      end
    end

  end
end

