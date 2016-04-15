require 'settings'

module AIProject
  class Move
    attr_accessor :move_type, :destination
    def initialize(options)
      @move_type   = options[:move_type]
      @destination = options[:destination]
    end

    def time_costs=(value)
      @time_costs = value.round(Settings::PRECISION)
    end

    def time_costs
      return @time_costs
    end
  end
end