require 'world'

# World_s used by only the Simulator
module AIProject
  class World_s < World
    attr_accessor :units, :shells

    def initialize(ids)
      # Initialize units with defaut values
      @units = {}
      units_location = [Location.new(1, 9),
                        Location.new(9, 1),
                        Location.new(9, 9),
                        Location.new(1, 1)]
      unit_state     = AIProject::State.new(Unit::MAX_HEALTH, Unit::MAX_ENERGY)

      index = 0
      ids.each do |id|
        @units[id] = Unit_s.new(id: id, state: unit_state.clone, location: units_location[index])
        index += 1
      end

      # Initialize shells
      @shells = []
    end

    # —оздать копию мира дл€ стратегии игрока (она будет записана в переменную info стратегии)
    def to_World
      return World.new({:units => @units, :shells => @shells})
    end


    # ¬ таком виде хран€тс€ "снапшоты" игрового мира
    def to_hash
      units  = []
      shells = []
      @units.each_value { |unit|   units.push  unit.to_hash}
      @shells.each      { |shell| shells.push shell.to_hash}

      return {units: units, shells: shells}
    end
  end
end
