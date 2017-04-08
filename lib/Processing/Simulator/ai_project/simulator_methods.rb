require 'helpers'
require 'settings'
require 'unit'
require 'shell'

module AIProject
  module SimulatorMethods
    module Simulation
      # Simulate Unit's moves for delta_time of time
      def move_units(delta_time)
        @move_lists.each do |id, move_list|
          # Helper variables to easier access
          unit        = @world_s.units[id]
          move        = @move_lists[id].first
          location    = unit.location
          destination = move.destination

          # For each move_type different model
          case move.move_type
            when :go_to
              # Перемещения юнита затрачивают энергию
              # todo we can remove some validations now
              distance = unit.speed * delta_time
              energy_need = World::ENERGY_PER_METER * distance
              if energy_need > unit.state.energy # TODO Dangerous comparison
                distance = unit.state.energy / World::ENERGY_PER_METER
                move.time_costs = 0 # move is finished now (unit will walk so many as he can)
              end
              unit.state.energy -= distance * World::ENERGY_PER_METER #energy_need

              unit.location = Helpers.move_point_on_distance_line(location, destination, distance)
              move.time_costs -= delta_time
            #======================================================================================
            when :shoot_to
              if (unit.state.energy < World::SHOOT_ENERGY_COSTS) # if we have no energy to shoot
                move.time_costs = 0
              else
                move.time_costs -= delta_time  # Wait for shoot
                if move.time_costs <= 0        # Is shoot ready? TODO Dangerous comparison
                  unit.state.energy -= World::SHOOT_ENERGY_COSTS
                  # Creating new shell on the distance SHOOT_DISTANCE from player
                  shell_location = Helpers.move_point_on_distance_line(location, destination, World::DISTANCE_BETWEEN_UNIT_AND_SHELL_POINTS)
                  @world_s.shells.push(Shell.new({:location => shell_location, :destination => destination.clone}))
                end
              end
          end

          @move_lists[id].shift if move.time_costs <= 0 # TODO Dangerous comparison
        end

        # Delete empty move lists
        @move_lists.delete_if { |id, move_list| move_list.empty? }
      end

      #Просимулировать снаряд на delta_time времени
      def move_shells(delta_time)
        @world_s.shells.each do |shell|
          distance = shell.speed * delta_time
          shell.location = Helpers.move_point_on_distance_line(shell.location, shell.destination, distance)
          shell.time -= delta_time
        end
      end

      #Просчет состояния игрового мира
      def process_world_state
        # Нахождение столкновений игроков со снарядами и уничтожение снарядов при таковом
        @world_s.units.each do |unit_id, unit|
          @world_s.shells.each_with_index do |shell, shell_index|

            distance_length = Helpers.line_length(unit.location, shell.location)
            shell_damaged_unit = distance_length - unit.radius - shell.radius <= 0  # TODO DANGEROUS comparison

            # TODO можно вынести в функцию
            if shell_damaged_unit
              unit.state.health -= shell.damage
              @world_s.shells.delete_at (shell_index)

              if (unit.state.health <= 0)
                @world_s.units.delete (unit_id)
                @move_lists.delete (unit_id)
                break
              end
            end
          end
        end

        # Удалить снаряды, которые долетели до своего места назначения
        @world_s.shells.delete_if { |shell| shell.time <= 0 } # TODO Dangerous comparison
      end


      # #
      # High level simulation
      def simulate_one_step
        until @move_lists.empty?
          delta_time = shortest_time_costs
          move_units  delta_time
          move_shells delta_time
          process_world_state
          make_world_snapshot
        end
      end

      def simulate
        output = {}

        while @battle_duration <= World_s::TACT_LIMIT && @world_s.units.size >= 2
          restore_units_energy
          update_strategies_fields
          get_move_lists
          validate_move_lists
          timing_move_lists
          simulate_one_step
          @battle_duration += 1
        end

        output[:options] = get_world_options
        output[:state]   = @world_states
        return output
      end
    end

    #================================================================================================
    #Просчет временных затрат
    module Timing
      #Найти время, за которое будет выполнено действие move Юнитом
      def timing_one_move(move, location, speed)
        case move.move_type
          when :go_to
            (Helpers.line_length(location, move.destination) / speed).round(Settings::PRECISION)
          when :shoot_to
            World::SHOOT_DELAY
        end
      end

      # Проставляет каждому действию в соответствие время его выполнения
      def timing_move_lists
        @move_lists.each do |id, move_list|
          location = @world_s.units[id].location
          speed    = @world_s.units[id].speed
          move_list.each { |move| move.time_costs = timing_one_move(move, location, speed) }
        end
      end

      #Найдем, сколько же времени занимает самое короткое действие
      def shortest_time_costs
        time_costs = [Settings::TIME_STEP]
        @move_lists.each_value { |move_list| time_costs.push(move_list.first.time_costs)} # Первое действие из каждого списка действий
        @world_s.shells.each   { |shell|     time_costs.push(shell.time)} # Время, оставшееся каждму из снарядов
        time_costs.delete_if   { |time_cost| time_cost.nan? || time_cost < Settings::FLOAT_PRECISION} # TODO надо бы подумать над этим и вынести куда - нибудь
        time_costs.compact.min # compact нужен затем, что .min не может найти минимум от [0.1, 0.1]
      end
    end

    #================================================================================================
    # Подготовка стратегий к Симуляции
    module PreparationToSimulation
      # Восстановить параметр "энергия" юнитам
      def restore_units_energy
        @world_s.units.each_value do |unit|
          unit.state.energy += World::ENERGY_RESTORATION
          unit.state.energy = unit.max_energy if unit.state.energy > unit.max_energy
        end
      end

      # Обновить поля +info+ и +my_unit+ каждой из стратегий "свежими" данными
      def update_strategies_fields
        @strategies.each_key do |i|
          @strategies[i].instance_variable_set( :@info, @world_s.to_World )
          @strategies[i].instance_variable_set( :@my_unit, @world_s.units[i].to_unit )
        end
      end
    end

    #================================================================================================
    # Операции со списками действий
    module MoveListsOperations
      require 'secure'
      # Сохраняет списки действий юнитов из полей стратегий в переменную @move_lists
      def get_move_lists
        @strategies.each do |id, strategy|
          strategy_modified = Timeout::timeout(1) do
            Secure.ly(:limit_cpu => 1) do
              strategy.move
              strategy
            end
          end
          @strategies[id] = strategy_modified
          @move_lists[id] = strategy_modified.instance_variable_get("@my_unit").move_list
        end
      end

      # Проверяет на корректность списки действий (и удалить некорректные)
      # * На конечную координату
      # * На возможность выстрела (того, что положение снаряда после создания на карте будет валидным)
      def validate_move_lists
        correct_xy_range = 0+1..World::MAP_SIZE-1 # TODO это может быть костыль ведь можно просто расширить вьюху на 1 ряд
        @move_lists.each do |id, move_list|
          unit = @world_s.units[id]
          location = unit.location.clone
          move_list.delete_if do |move|
            destination = move.destination
            # Проверки, специфичные для разных типов действий
            case move.move_type
              when :shoot_to
                # [VALIDATION] Перемещаем снаряд так, чтобы он не задевал стреляющего юнита
                shell_start_location = Helpers.move_point_on_distance_line(location, destination, World::DISTANCE_BETWEEN_UNIT_AND_SHELL_POINTS)
                # [VALIDATION] Перемещенный снаряд находится в пределах поля
                correct_shell_start_location = correct_xy_range.include?(shell_start_location.x) && correct_xy_range.include?(shell_start_location.y)
                # [VALIDATION] Дистанция запуска снаряда больше, чем минимально допустимое расстояние
                correct_shoot_distance = Helpers.line_length(location, destination) >= World::DISTANCE_BETWEEN_UNIT_AND_SHELL_POINTS # TODO Dangerous comparison
              when :go_to
                # [VALIDATION] Пройденная за ход дистанция должна быть > 0.001
                correct_distance_length = Helpers.line_length(location, destination) > Settings::FLOAT_PRECISION
            end

            # Проверки, общие для всех типов действий
            correct_destination = correct_xy_range.include?(destination.x) && correct_xy_range.include?(destination.y)

            # Удаляем некорректные действия
            not (((move.move_type == :shoot_to && correct_shell_start_location && correct_shoot_distance) ||
                  (move.move_type == :go_to && correct_distance_length)) &&
                  (correct_destination))
          end
        end

        #Удаляем пустые списки действий
        @move_lists.delete_if {|key, move_list| move_list.empty?}
      end
    end

    # Получаем объект стратегии из строки с кодом
    module ParseStrategies
      def get_object_from_str(str, module_name)
        prepare_strategy_to_eval(str, module_name)
      end

      # Добавить строку Strategy.new в конец строки strategy
      # Fixme уязвимость - пользователь может создавать объекты симулятора, если будет знать их имена
      def prepare_strategy_to_eval(strategy, module_name)
        strategy_module = eval "module #{module_name}\n" + strategy + "\nend\n #{module_name}::Strategy"
        Timeout::timeout(1) { Secure.ly(:limit_cpu => 1) { strategy_module.new }} # fixme Secure's timeout doens't works
      end

      # TODO вынести на уровень выше в подключаемый файл (так как нужен и в контроллере)
      def make_module_name(id)
        return 'Strategy' + id.to_s
      end
    end

    # #
    # Collect information about simulation process
    module WorldLogHelpers
      def make_world_snapshot
        @world_states.push @world_s.to_hash
      end

      def get_world_options
        {u_radius: Unit::RADIUS,
         s_radius: Shell::RADIUS,
         map_size: World::MAP_SIZE,
         winner_id: winner_id,
         players_count: players_count}
      end

      def winner_id
        units = @world_s.units
        return (units.size == 1 ? units.keys.first : nil)
      end

      def players_count # FIXME Это не будет работать после реализации концепции отмирания стратегий
        @strategies.size
      end
    end

    # #
    # Secure execution of block of code
    module SafeEval
      def windows?
        (/cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM) != nil
      end
      require 'secure'
      # TODO нужно поэкспериментировать со временем выполнения скрипта и занимаемой им памятью
      def secure_execute
        yield
        # Secure.ly(:timeout => 1, :limit_cpu => 1, :safe => 0) { yield }
        # if not windows?
        #   Secure.ly(:timeout => 2, :limit_cpu => 1, safe: 0) { yield }
        # else
        #   block.call
        # end
      end
    end
  end
end
