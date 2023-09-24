# frozen_string_literal: true

module Maps
  class Configuration
    class Coast
      attr_reader :name, :abbr, :adjacent, :display

      def initialize(yml)
        @name = yml['name'].to_s
        @abbr = yml['abbr'].to_s.downcase
        @adjacent = yml.fetch('adjacent', {}) # TODO: make a class
        @display = yml.fetch('display', {}) # TODO: make a class
      end

      def coast?
        true
      end

      def inland?
        false
      end

      def sea?
        false
      end

      def unit_x
        @display['unit']['x'].to_i
      end

      def unit_y
        @display['unit']['y'].to_i
      end

      def dislodged_unit_x
        @display['dislodged_unit']['x'].to_i
      end

      def dislodged_unit_y
        @display['dislodged_unit']['y'].to_i
      end

      def adjacent_coasts
        @adjacent.fetch('coast', [])
      end

      def adjacent_seas
        @adjacent.fetch('sea', [])
      end

      def adjacent_land
        @adjacent.fetch('land', [])
      end
    end

    class Territory
      attr_reader :name, :abbr, :type, :adjacent, :display, :coasts

      def initialize(yml)
        @name = yml['name'].to_s
        @abbr = yml['abbr'].to_s.downcase
        @type = yml['type'].to_s
        @coasts = {}
        yml.fetch('coasts', {}).each do |c|
          @coasts[c['abbr'].to_s.downcase] = Coast.new(c)
        end
        @adjacent = yml.fetch('adjacent', {}) # TODO: make a class
        @display = yml.fetch('display', {}) # TODO: make a class
      end

      def coast?
        @type == 'coast'
      end

      def inland?
        @type == 'land'
      end

      def sea?
        @type == 'sea'
      end

      def unit_x
        @display['unit']['x'].to_i
      end

      def unit_y
        @display['unit']['y'].to_i
      end

      def dislodged_unit_x
        @display['dislodged_unit']['x'].to_i
      end

      def dislodged_unit_y
        @display['dislodged_unit']['y'].to_i
      end

      def adjacent_coasts
        @adjacent.fetch('coast', [])
      end

      def adjacent_seas
        @adjacent.fetch('sea', [])
      end

      def adjacent_land
        @adjacent.fetch('land', [])
      end
    end

    class UnitType
      # @!attribute [r] height
      #   @return [Integer]
      attr_reader :height
      # @!attribute [r] width
      #   @return [Integer]
      attr_reader :width
      # @!attribute [r] type
      #   @return [String]
      attr_reader :type

      TYPE_ARMY = 'army'
      TYPE_FLEET = 'fleet'

      def initialize(type, yml)
        @type = type.to_s.downcase
        @width = yml['width'].to_i
        @height = yml['height'].to_i
      end

      ##
      # @return [String]
      #
      def xlink_href
        "##{@type.capitalize}"
      end
    end

    # @!attribute [r] territories
    #   @return [Hash<Symbol,Territory>]
    attr_reader :territories
    # @!attribute [r] unit_types
    #   @return [Hash<Symbol,UnitType>]
    attr_reader :unit_types

    ##
    # @param [String] variant_name
    # @return [self]
    #
    def initialize(variant_name = 'classic')
      @yml = YAML.safe_load_file(Rails.root + "app/configuration/maps/#{variant_name}.yml")
      @territories = {}
      @unit_types = {
        army: UnitType.new(UnitType::TYPE_ARMY, @yml['unit_types']['army']),
        fleet: UnitType.new(UnitType::TYPE_FLEET, @yml['unit_types']['fleet'])
      }
      @yml['territories'].each { |x| @territories[x['abbr'].to_sym] = Territory.new(x) }
      super()
    end

    ##
    # Returns the unit type for the given abbreviation
    # @param [String] abbr
    # @return [UnitType]
    #
    def unit_type(abbr)
      @unit_types[abbr.to_s.downcase.to_sym]
    end

    def territory(abbr)
      @territories[abbr.to_s.downcase.to_sym]
    end

    def unit_x(abbr, coast: nil)
      t = territory(abbr)
      if coast.present? && coast.to_s != '0' && t.coast?
        t.coasts[coast].unit_x
      else
        t.unit_x
      end
    end

    def unit_y(abbr, coast: nil)
      t = territory(abbr)
      if coast.present? && coast.to_s != '0' && t.coast?
        t.coasts[coast].unit_y
      else
        t.unit_y
      end
    end
  end
end
