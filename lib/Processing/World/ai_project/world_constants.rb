require 'shell' # TODO can be deleted
require 'unit'

# #
# Player can use these constants
# Example: World::MAP_SIZE
module AIProject
  module WorldConstants
    MAP_SIZE = 10 # Карта - квадрат со стороной MAP_SIZE
    TACT_LIMIT = 20 # Максимальное число тактов симулятора
    SHOOT_ENERGY_COSTS = 50 # Затраты энергии на выстрел
    ENERGY_PER_METER = 50 # Затраты энергии на прохождение одного игрового метра
    ENERGY_RESTORATION = 100 # Восстановление энергии за 1 такт
    SHOOT_DISTANCE = 0.2 # Расстояние от игрока до создаваемого им снаряда
    SHOOT_DELAY = 1.0 # Задержка в игровых секундах до выстрела

    # Расстояне между "центрами" игрока и создаваемого им снаряда
    DISTANCE_BETWEEN_UNIT_AND_SHELL_POINTS = AIProject::Unit::RADIUS + AIProject::Shell::RADIUS + SHOOT_DISTANCE
  end
end
