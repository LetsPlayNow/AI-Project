require 'settings'

module AIProject
  # Now it will be with PRECISION
  class Location
    attr_reader :x, :y
    def initialize(x, y)
      @x = x
      @y = y
    end

    def x=(value)
      @x = value.round(Settings::PRECISION)
    end

    def y=(value)
      @y = value.round(Settings::PRECISION)
    end
  end
end