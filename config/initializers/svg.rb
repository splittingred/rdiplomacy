# frozen_string_literal: true

require 'rdiplomacy/svg/map_transformer'

InlineSvg.configure do |config|
  config.add_custom_transformation(attribute: :map, transform: RDiplomacy::Svg::MapTransformer)
end
