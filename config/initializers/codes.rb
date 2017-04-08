# While now there will be stored some good codes for bots
# it's not a good technique
module Codes
  CIRCLE = "
class Strategy
  def initialize
    @my_unit = Unit.new
    @info    = World.new
    @count = 0
    @steps_limit = World::MAP_SIZE - 4
    @turns_count = 0
    @directions = [:left, :up, :right, :down]  # [:right, :down, :left, :up]
  end

  def move
    @count += 1
    if @count == @steps_limit
      @turns_count += 1
      @count = 0
    end

    if @turns_count == 4
      @turns_count = 0
      @steps_limit -= 1
      @steps_limit = 0 if @steps_limit < 0
    end

    step(@directions[@turns_count])
    shoot_to_enemy
  end

  def step(direction)
    len = 1
    case direction
    when :up
      @my_unit.go_up(len)
    when :down
      @my_unit.go_down(len)
    when :left
      @my_unit.go_left(len)
    when :right
      @my_unit.go_right(len)
    end
  end

  def shoot_to_enemy()
    enemy = @info.get_enemy(@my_unit.id)
    @my_unit.shoot_to(enemy.location.x, enemy.location.y)
  end

  def get_enemy
    return @info.get_enemy(@my_unit.id)
  end
end
  "
end