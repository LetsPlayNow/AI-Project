require_relative 'simulator'

codes = {}
codes[1] = "
class Strategy
  def initialize
    @my_unit = Unit.new
    @info    = World.new
  end

  def move
    @my_unit.shoot_to(6, 6)
  end
end"

codes[2] = "
class Strategy
  def initialize
    @my_unit = Unit.new
    @info    = World.new
  end

  def move
  end
end
"
codes[11] = "
class Strategy
  def initialize
    @my_unit = Unit.new
    @info    = World.new
  end

  def move
  end
end
"

result = AIProject::Simulator.new(codes).simulate
p result

# Нужно подгрузить симулятор. Из каждой папки