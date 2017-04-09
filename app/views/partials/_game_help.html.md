# class Unit *(object: @my_unit)*
```ruby
class Unit
  # Class read only fields
  @id # can be used to access enemies (check World description)
  @state.health # Health of unit. If it become <= 0 your unit is dead
  @state.energy # Energy of unit. Can be spent for shooting and moving
  
  @location # where is unit's center (point)
  @location.x 
  @location.y 
  
  @speed # game meter / game second
  @radius # radius of unit in game meters
  @max_health # maximum health of unit
  @max_energy # maximum energy of unit
  
  # say unit go to point (x, y)
  # this spends World::ENERGY_PER_METER amount of energy
  def go_to(x,y) 
  end
  
  # cast spell to point (x, y)
  # causes delay World::SHOOT_DELAY before shell appearance
  def shoot_to(x,y)
  end
  
  # go left for length along the x axis
  def go_left(length)
  end
  
  # go right for length along the x axis
  def go_right(length)
  end
  
  # go up for length along the y axis
  def go_up(length)
  end
  
  # go down for length along the y axis
  def go_down(length)
  end
end
```

# class Shell
```ruby
class Shell
  @location # where is shell now
  @location.x
  @location.y
  
  @destination # where does it fly
  @destination.x
  @destination.y
  
  @speed # game meter / game second
  @damage # how many health will lost unit when touch shell
  @radius # radius of shell in game meters
end
```

# class World *(object: @info)*
```ruby
class World
  # get array of enemies of unit with id 'my_id'
  # usage: @info.get_enemies(@my_unit.id)
  def get_enemies( my_id ) 
  end
  
  # get random enemy of unit with id 'my_id'
  # usage: @info.get_enemies(@my_unit.id)
  def get_enemy( my_id )
  end
    
  # get list of all shells
  def get_shells
  end
end

# World constants
# size of map side (map is square)
World::MAP_SIZE 
# how many energy will spend unit, when cast shell
World::SHOOT_ENERGY_COST 
# how many energy unit will spend to walk for game meter
World::ENERGY_PER_METER 
# how many energy will be added on next simulation step
World::ENERGY_RESTORATION 
# distance between unit's borders and his shell when shell creation
World::SHOOT_DISTANCE 
# delay between summoning and casting spell in game seconds
World::SHOOT_DELAY 
# distance between unit and shell centers on his shell creation
World::DISTANCE_BETWEEN_UNIT_AND_SHELL_POINTS 
```