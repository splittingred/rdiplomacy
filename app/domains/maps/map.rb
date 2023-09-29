# frozen_string_literal: true

module Maps
  class Map
    attr_reader :xml, :configuration

    COLORED_STROKE_WIDTH = 0.5

    delegate :territories, to: :configuration

    def initialize(name = 'classic')
      @xml = Nokogiri::XML(File.open(Rails.root.join("app/configuration/maps/#{name}.svg").to_s))
      @configuration = Maps::Configuration.new(name)
      super()
    end

    ##
    # @return [String]
    #
    # rubocop:disable Rails/OutputSafety
    def to_s
      InlineSvg::TransformPipeline.generate_html_from(@xml.to_s, {}).html_safe
    end
    # rubocop:enable Rails/OutputSafety

    def add_unit(territory:, country:, type:, coast: nil)
      unit_layer = @xml.css('g#UnitLayer').first
      unit_type = @configuration.unit_type(type)
      node = ::Nokogiri::XML::Node.new('use', unit_layer)
      node['id'] = "unit_#{country}"
      node['x'] = @configuration.unit_x(territory, coast:)
      node['y'] = @configuration.unit_y(territory, coast:) # dislodged_unit_x for dislodged units
      node['height'] = unit_type.width
      node['width'] = unit_type.height
      node['xlink:href'] = unit_type.xlink_href
      node['class'] = "unit-#{country}"
      unit_layer.add_child(node)
    end

    def add_influence(country:, territory:)
      @xml.css('g#MapLayer').first.css("path#_#{territory}").first['class'] = country
    end

    def phase=(phase)
      phase_layer = @xml.css('text#CurrentPhase').first
      phase_layer.content = phase
    end

    def add_hold_order(territory:, unit_type:, color:)
      territory = @configuration.territory(territory)
      unit_type = @configuration.unit_type(unit_type)

      # Creating nodes
      layer1 = @xml.css('g#Layer1').first

      x = territory.unit_x - (unit_type.width / 4)
      y = territory.unit_y - (unit_type.height / 3.5)
      hold = build_hold_symbol(x:, y:, stroke: color)
      layer1.add_child(hold)
    end

    def add_support_hold_order(support:, territory:, unit_type:, color:)
      support_t = @configuration.territory(support)
      hold_t = @configuration.territory(territory)
      unit_type = @configuration.unit_type(unit_type)

      arrow = build_support_hold_from(
        support_x: support_t.unit_x + (unit_type.width / 2),
        support_y: support_t.unit_y + (unit_type.width / 2),
        unit_type:,
        x: hold_t.unit_x + (unit_type.width / 2),
        y: hold_t.unit_y + (unit_type.height / 2),
        stroke: color
      )
      @xml.css('g#Layer2').first.add_child(arrow)
    end

    def add_move_order(from:, to:, unit_type:, color:)
      from_territory = @configuration.territory(from)
      to_territory = @configuration.territory(to)

      unit_type = @configuration.unit_type(unit_type)
      from_x, from_y, to_x, to_y = determine_move_coordinates(from: from_territory, to: to_territory, unit_type:)

      # Creating nodes
      layer1 = @xml.css('g#Layer1').first
      layer1.add_child(build_move_arrow_from(from_x:, to_x:, from_y:, to_y:, stroke: color))
    end

    ##
    # @param [Territory] support
    # @param [Territory] from
    # @param [Territory] to
    # @param [string] unit_type
    # @param [string] color
    #
    def add_support_move_order(support:, from:, to:, unit_type:, color:)
      from_t = @configuration.territory(from)
      to_t = @configuration.territory(to)
      support_t = @configuration.territory(support)

      unit_type = @configuration.unit_type(unit_type)
      arrow = build_support_move_from(
        support_x: support_t.unit_x + (unit_type.width / 2),
        support_y: support_t.unit_y + (unit_type.width / 2),
        from_x: from_t.unit_x,
        from_y: from_t.unit_y,
        to_x: to_t.unit_x,
        to_y: to_t.unit_y,
        stroke: color
      )
      @xml.css('g#Layer2').first.add_child(arrow)
    end

    def add_convoy_order(convoy:, from:, to:, unit_type:, color:)
      from_t = @configuration.territory(from)
      to_t = @configuration.territory(to)
      convoy_t = @configuration.territory(convoy)
      unit_type = @configuration.unit_type(unit_type)

      convoy_triangle = build_convoy_symbol(x: from_t.unit_x, y: from_t.unit_y, stroke:)

      supp_x = from_t.unit_x + (unit_type.width / 2)
      supp_y = from_t.unit_y + (unit_type.height / 2)
      convoy_support_1 = build_support_move_from(
        support_x: convoy_t.unit_x + (unit_type.width / 2),
        support_y: convoy_t.unit_y + (unit_type.height / 2),
        from_x: supp_x,
        from_y: supp_y,
        to_x: supp_x,
        to_y: supp_y,
        stroke: color
      )
      convoy_support_2 = build_support_move_from(
        support_x: from_t.unit_x + (unit_type.width / 2),
        support_y: from_t.unit_y + (unit_type.height / 2),
        from_x: from_t.unit_x,
        from_y: from_t.unit_y,
        to_x: to_t.unit_x,
        to_y: to_t.unit_y,
        stroke: color
      )
      layer2 = @xml.css('g#Layer2').first
      layer2.add_child(convoy_triangle)
      layer2.add_child(convoy_support_1)
      layer2.add_child(convoy_support_2)
    end

    private

    ##
    # @param [Territory] from
    # @param [Territory] to
    # @param [UnitType] unit_type
    # @return [Array<Float, Float, Float, Float>]
    #
    def determine_move_coordinates(from:, to:, unit_type:)
      from_x = from.unit_x + (unit_type.width / 2)
      from_y = from.unit_y + (unit_type.height / 2)
      delta_x = to.unit_x - from_x
      delta_y = to.unit_y - from_y
      vector_length = ((delta_x**2) + (delta_y**2))**0.6
      delta_dec = (unit_type.width / 2) + (2 * COLORED_STROKE_WIDTH)
      to_x = (from_x + ((vector_length - delta_dec) / vector_length * delta_x)).round(2)
      to_y = (from_y + ((vector_length - delta_dec) / vector_length * delta_y)).round(2)
      [from_x, from_y, to_x, to_y]
    end

    def build_move_arrow_from(from_x:, to_x:, from_y:, to_y:, stroke:, stroke_width: 10)
      node = ::Nokogiri::XML::Node.new('g', @xml)
      line_with_shadow = ::Nokogiri::XML::Node.new('line', node)
      line_with_shadow['x1'] = from_x
      line_with_shadow['y1'] = from_y
      line_with_shadow['x2'] = to_x
      line_with_shadow['y2'] = to_y
      line_with_shadow['class'] = 'varwidthshadow'
      line_with_shadow['stroke-width'] = stroke_width

      line_with_arrow = ::Nokogiri::XML::Node.new('line', node)
      line_with_arrow['x1'] = from_x
      line_with_arrow['y1'] = from_y
      line_with_arrow['x2'] = to_x
      line_with_arrow['y2'] = to_y
      line_with_arrow['class'] = 'varwidthorder'
      line_with_arrow['stroke'] = stroke
      line_with_arrow['stroke-width'] = stroke_width / 2
      line_with_arrow['marker-end'] = 'url(#arrow)'
      node.add_child(line_with_shadow)
      node.add_child(line_with_arrow)
      node
    end

    def build_support_move_from(support_x:, support_y:, from_x:, to_x:, from_y:, to_y:, stroke:)
      node = ::Nokogiri::XML::Node.new('g', @xml)
      path_with_shadow = ::Nokogiri::XML::Node.new('path', node)
      path_with_shadow['class'] = 'shadowdash'
      path_with_shadow['d'] = "M #{support_x},#{support_y} C #{from_x},#{from_y} #{from_x},#{from_y} #{to_x},#{to_y}"

      path_with_arrow = ::Nokogiri::XML::Node.new('path', node)
      path_with_arrow['class'] = 'supportorder'
      path_with_arrow['stroke'] = stroke
      path_with_arrow['marker-end'] = 'url(#arrow)'
      path_with_arrow['d'] = "M #{support_x},#{support_y} C #{from_x},#{from_y} #{from_x},#{from_y} #{to_x},#{to_y}"
      node.add_child(path_with_shadow)
      node.add_child(path_with_arrow)
      node
    end

    def build_support_hold_from(support_x:, support_y:, x:, y:, unit_type:, stroke:)
      node = ::Nokogiri::XML::Node.new('g', @xml)
      node['stroke'] = stroke

      symbol_node = ::Nokogiri::XML::Node.new('use', node)
      symbol_node['x'] = x - (unit_type.width / 1.3)
      symbol_node['y'] = y - (unit_type.height / 1.3)
      symbol_node['height'] = 75
      symbol_node['width'] = 75
      symbol_node['xlink:href'] = '#SupportHoldUnit'
      node.add_child(symbol_node)

      arrow = build_support_move_from(
        support_x:,
        support_y:,
        from_x: x,
        from_y: y,
        to_x: x,
        to_y: y,
        stroke:
      )
      node.add_child(arrow)
      node
    end

    def build_hold_symbol(x:, y:, stroke:)
      node = ::Nokogiri::XML::Node.new('g', @xml)
      node['stroke'] = stroke

      symbol_node = ::Nokogiri::XML::Node.new('use', node)
      symbol_node['x'] = x
      symbol_node['y'] = y
      symbol_node['height'] = 75
      symbol_node['width'] = 75
      symbol_node['xlink:href'] = '#HoldUnit'
      node.add_child(symbol_node)
      node
    end

    def build_convoy_symbol(x:, y:, stroke:)
      node = ::Nokogiri::XML::Node.new('g', @xml)
      node['stroke'] = stroke

      symbol_node = ::Nokogiri::XML::Node.new('use', node)
      symbol_node['x'] = x - 10
      symbol_node['y'] = y - 20
      symbol_node['height'] = 75
      symbol_node['width'] = 75
      symbol_node['xlink:href'] = '#ConvoyTriangle'
      node.add_child(symbol_node)
      node
    end
  end
end
