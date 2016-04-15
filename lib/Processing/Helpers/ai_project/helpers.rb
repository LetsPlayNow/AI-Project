require 'location'
require 'settings'

module AIProject
  class Helpers
    # Возвращает длину отрезка, соединяющего точки а и b
    def self.line_length(a, b)
      (((b.x - a.x)**2 + (b.y - a.y)**2)**0.5).round(Settings::PRECISION)
    end

  # Возвращает точку, сдвинутую на distance на отрезке, соединяющем location и destination
    def self.move_point_on_distance_line(location, destination, distance)
      movement_point = Location.new(0, 0)
      distance_length = Helpers.line_length(location, destination)
      movement_point.x = (location.x + distance * (destination.x - location.x) / distance_length).round(Settings::PRECISION)
      movement_point.y = (location.y + distance * (destination.y - location.y) / distance_length).round(Settings::PRECISION)
      return movement_point
    end
  end
end

