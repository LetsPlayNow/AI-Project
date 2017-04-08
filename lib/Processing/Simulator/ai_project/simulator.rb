require 'world_s'
require 'simulator_methods'

=begin
* TODO {in} settings
* {in} codes = {|id| => code}
* {out} world_state (Unit(id, x, y, hp, mp), Shell(x,y))
* {out} options (u_radius, s_radius, map_size, winner_id)
=end

module AIProject
  AIProject::Move # todo this constant is not loading by default and it causes error
  class Simulator
    attr_accessor :strategies

    def initialize(codes)
      @ids = codes.keys
      @world_s = World_s.new(@ids)

      @strategies = {}
      codes.each { |id, code| @strategies[id] = get_object_from_str(code, make_module_name(id)) }
      @move_lists = {}

      # Выходные данные симулятора
      @world_states  = []
      @battle_duration = 0
      make_world_snapshot
    end

    include SimulatorMethods::Simulation
    include SimulatorMethods::Timing
    include SimulatorMethods::PreparationToSimulation
    include SimulatorMethods::MoveListsOperations
    include SimulatorMethods::ParseStrategies
    include SimulatorMethods::WorldLogHelpers
    include SimulatorMethods::SafeEval
  end
end
