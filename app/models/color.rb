# Keep colors for search
class Color < ActiveRecord::Base
  attr_accessible :search_color_id, :search_factor, :distance, :active

  belongs_to :colorable, polymorphic: true
  belongs_to :search_color
end
