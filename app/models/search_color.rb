class SearchColor < ActiveRecord::Base
  HEXES_28 = %w(660000 990000 cc0000 cc3333 ea4c88 993399 663399 333399 0066cc 0099cc 66cccc 77cc33 669900 336600 666600 999900 cccc33 ffff00 ffcc33 ff9900 ff6600 cc6633 996633 663300 000000 999999 cccccc ffffff)
  HEXES_20 = %w(660000 cc0000 ea4c88 993399 663399 0066cc 66cccc 77cc33 336600 cccc33 ffcc33 ff6600 c8ad7f 996633 663300 000000 999999 cccccc ffffff)
  has_many :colors
  has_many :fotkas, through: :colors, source: :colorable, source_type: 'Fotka'
  # has_many :products, through: :colors, source: :colorable, source_type: 'Product'
end
