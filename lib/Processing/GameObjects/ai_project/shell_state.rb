require 'object'
require 'helpers'
require 'settings'

module AIProject
  class ShellState
    attr_reader :location, :destination, :speed, :damage, :radius
    def initialize(location, destination, speed, damage, radius)
      @location = location
      @destination = destination
      @speed = speed
      @damage = damage
      @radius = radius
    end
  end
end
