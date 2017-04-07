module GameSessionsHelper
  module SyntaxErrors
    # Возвращает то, что было записано в поток $stderr за время выполнения блока
    def capture_stderr
      previous_stderr = $stderr
      $stderr = StringIO.new
      yield # There are code is executed
      errors = $stderr.string
      $stderr = previous_stderr

      errors
    end

    # Перенаправляем поток ошибок в переменную
    # И пытаемся скомпилировать код игрока
    # Возвращаем то, что было записано в поток
    def syntax_errors( code )
      errors = capture_stderr do
        begin
          RubyVM::InstructionSequence.compile( code )
        rescue SyntaxError
        end
      end
    end

    def syntax_ok?( error_messages )
      error_messages.empty?
    end
  end

  module Simulation
    # Simulation helpers
    # После того, как объект первой удачной стратегии будет создан
    # Эта удачная копия будет существовать сколько угодно времени
    # И последующие оппытки переопределить эту стратегию ни к чему не приведут
    # +@game+ :: game ids
    def remove_previous_strategies_definitions
      @game.user_ids.each { |id| ActiveSupport::Dependencies::remove_constant(get_strategy_constant id) }
    end

    def get_strategy_constant(id)
      # strategy = AIProject::SimulatorMethods::ParseStrategies::Strategy#{player.id}::Strategy.new
      # Why Constant path so big i don't know
      user_const = "AIProject::SimulatorMethods::ParseStrategies::Strategy#{id.to_s}::Strategy".safe_constantize
      if (defined? user_const) == "constant"
        Object.send(:remove_const, user_const)
      end
      "AIProject::SimulatorMethods::ParseStrategies::Strategy#{id.to_s}::Strategy"
    end

    def add_players_info_in(simulator_output)
      simulator_output[:users_info] = {}
      @game.users(true).each do |user|
        simulator_output[:users_info][user.id] = { :name => user.name }
      end
    end
  end
end