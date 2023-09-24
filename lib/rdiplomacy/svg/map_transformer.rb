# frozen_string_literal: true

module RDiplomacy
  module Svg
    class MapTransformer < InlineSvg::TransformPipeline::Transformations::Transformation
      def transform(doc)
        with_svg(doc) do |svg|
          svg['game-name'] = value.name
        end
      end
    end
  end
end
