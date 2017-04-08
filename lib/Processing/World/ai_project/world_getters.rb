module WorldGetters
  # #
  # TODO пока не можем получить my_id (это можно исправить костылем в get_move_lists)
  # NOTE get_own_units не нужен, так как у игрока всегда есть копия своего юнита (my_unit)
  # Allows to get all enemies of player with id +my_id+
  def get_enemies( my_id )
    enemies = []
    @units.each { |id, unit_s| enemies.push( unit_s.to_unit ) if ( id != my_id ) }
    enemies # TODO можно ли убрать это дублирование кода?
  end

  # returns random enemy
  def get_enemy( my_id )
    enemies = get_enemies( my_id )
    enemy = enemies.sample
    enemies.delete enemy
    enemy
  end

  def get_shells
    shells = []
    @shells.each do |shell|
      shells.push(ShellState.new(shell.location.clone, shell.destination.clone,
                                 shell.speed, shell.damage, shell.radius))
    end
    shells
  end
end