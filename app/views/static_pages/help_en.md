# Help
<script src="https://cdn.rawgit.com/google/code-prettify/master/loader/run_prettify.js"></script>
<%= link_to 'Русскоязычная версия этой страницы', help_url(:lang => 'ru')%>

## Contents
* About user interface
  * Home page
    * Solo game with bot
    * Game with real players
  * Wait page
  * Game page 
  * Simulation page
  * Game Results Page
* About gaming sessions
* Game tutorial
  * Game world determinations
    * Strategy
    * Simulator (the processing system)
    * Game step (simulation step)
* The game world
  * Measurement units
* Game objects and classes
  * Player's classes
    * class Strategy
      * Example of Strategy class
  * Simulation classes
    * class Unit *(object: @my_unit)*
    * class Shell
    * class World *(object: @info)*

## Introduction
**It's highly recommended to not disable JavaScript in your browser.**

## About user interface
The site has 5 main pages:
### Home page
On this page you can start or continue 1 of 2 types of games:
#### Solo game with bot
* You can leave this game at any moment
* This game is not limited in time

#### Game with real players
* Player will be choose randomly from currently online players
* Game is limited in time (60 minutes now)
* You can't leave the game until it's end
* When time will expire you can't send code, but able to see simulation or leave game

### Wait page
On this page you will wait for other players if you choose multiplayer game.  
When other players become available, game will starts automatically.

### Game page 
Page with code editor and timer.
On this page you can write & send code.  
Last syntactically correct code will be saved in database and used for simulation.

### Simulation page
Page with visualization of simulation results.  
On this page you can see visualization of the game (battle between units).  
Or errors, if something went wrong (insecure operations, timeout of execution, runtime errors and other).  
Right now error in one of strategies will cause error in common simulation.  
So for success simulation, codes of both of players should be correct.

### Game Results Page
A page with gaming session results.
Winner will get **++** to his common score.

## About gaming sessions
Game sessions are limited in time.  
After time expire, you can not send your code to the server,
but you can see the game on the page Simulation.  
To complete the game, click on Finish game on page Game Page or Simulation.  
Then you will **not** be able to view the latest game session's simulation.  

## Game tutorial
### Game world determinations
#### Strategy
Player's class that defines behavior of the unit

#### Simulator (the processing system)
A system that performs simulation game world based on classes written by players (Strategies)

#### Game step (simulation step)
The time in which the code of all players executed exactly one time.  
At every step Simulator executes code of all strategies and processes behavior of their units.  
On each step unit can walk and cast shells (every move spend energy).

## The game world
![World map](static_pages_assets/background-xy.jpg)

* The game world is a square with a side of `World::MAP_SIZE`.
* Navigating in the world is produced by means of coordinates (x, y).
* The coordinate origin is at the upper left corner.
* The values ​​that can take the x and y lie in the range [0; World::MAP_SIZE].

### Measurement units
Units of measure received in the game world
* Game meter (g.m.) - abstract distance unit
* Game second (g.s.) - analogue of the real seconds, a uniform characteristic of time
* Game meter / game second (g.m / g.s) - speed

## Game objects and classes
Location of objects defined using the coordinates of the center.
All objects in game now are circles with center in (x,y) and radius.

*You can see shortened reference at Game Page*

### Player's classes
#### class Strategy
It contains player's code to control unit.

Simulator will call initialize method once (at start).
And then method move at every simulation step.
At every step @my_unit and @info will be updated.

Strategy execution limited by 1 second.

##### Example of Strategy class
Below you can see strategy of unit, which makes unit walk around the square and shoot to it's enemy.

```ruby
class Strategy
  def initialize
    # Initialization of main objects (@my_unit, @info)
    # Don't rename them
    @my_unit = Unit.new
    @info    = World.new
    
    # Player's code
    @count = 0
    @steps_limit = World::MAP_SIZE - 4
    @turns_count = 0
    @directions = [:right, :down, :left, :up]
  end

  # This method will be called at every simulation step (check info above)
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
    @info.get_enemy(@my_unit.id)
  end
end
```

### Simulation classes
#### class Unit *(object: @my_unit)*
![Unit](static_pages_assets/unit.png)

Unit can walk and shoot to enemy by creating directed shells.
In the game world Unit is shaped like a circle with a radius of @my_unit.radius.
At this moment, all the characteristics of all units are the same.

Unit's shoot_to consists in 2 phases:
* Summon shell for World::SHOOT_DELAY g.s.
* Then shell appears at a distance of World::SHOOT_DISTANCE from the "border" of Unit    
It means that distance between edge of Shell and edge of Unit is World::SHOOT_DISTANCE

*With a lack of manna for the shot, the call phase still happen*

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

### class Shell
![Shell](static_pages_assets/shell_dark.png)

The thing, which can be used to destroy enemies.
It causes damage only if touches unit (intersection or contact of unit and shell circles).
In a collision with a unit, the shell disappears, dealing the corresponding damage to unit (shell.damage).

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

### class World *(object: @info)*
Informational class. Contains important getters.

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