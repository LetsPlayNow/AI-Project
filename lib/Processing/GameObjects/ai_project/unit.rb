require 'object'
require 'state'
require 'move'

module AIProject
  # #
  # Unit is a control and information interface for player
  class Unit < Object
    attr_reader :id, :state, :location, :speed, :radius, :move_list, :max_health, :max_energy

    def initialize(options = {id: -1, state: AIProject::State.new(-1, -1), location: AIProject::Location.new(-1, -1)})
        @id       = options[:id]
        @state    = options[:state]
        @location = options[:location]

        # These 4 properties below may be useful in future
        # (if Units will be different (e.g. different radius))
        @speed  = SPEED
        @radius = RADIUS
        @max_health = MAX_HEALTH
        @max_energy = MAX_ENERGY

        @move_list = []
    end

    # note For now it's ok, because all Units are the same
    SPEED  = 1
    RADIUS = 0.5
    MAX_HEALTH = 100
    MAX_ENERGY = 100

    # # # # # # # # # # #
    # Control methods
    # They fill move_list
    def go_to(x, y)
      @move_list.push(Move.new(move_type: :go_to, destination: Location.new(x,y)))
    end
    def shoot_to(x, y)
      @move_list.push(Move.new(move_type: :shoot_to, destination: Location.new(x,y)))
    end

    # todo crop moves coordinates to field's size
    def go_left(length)
      go_to(@location.x - length, @location.y)
    end

    def go_right(length)
      go_left(-length)
    end

    def go_up(length)
      go_to(@location.x, @location.y+length)
    end

    def go_down(length)
      go_up(-length)
    end


  end


  # #
  # Unit_s used by the Simulator
  class Unit_s < Unit
    attr_writer :state, :location, :move_list, :speed, :radius, :max_health, :max_energy

    def to_unit
      Unit.new({:id => @id, :state => @state.clone, :location => @location.clone})
    end

    def to_hash
      {id:       @id,
       state:    {hp: @state.health, mp: @state.energy},
       location: {x: @location.x,    y: @location.y}}
    end
  end
end