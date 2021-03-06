<script src="https://cdn.rawgit.com/google/code-prettify/master/loader/run_prettify.js"></script>
# Справка
> [English version of this page](help?lang=en)

## Содержание
* Введение
* О пользовательском интерфейсе
  * Home page
    * Одиночная игра с ботом
    * Игра с реальными игроками
  * Wait page
  * Game page 
  * Simulation page
  * Game Results Page
* Об игровых сессиях
* Туториал по игровому миру
  * Определения игрового мира
    * Strategy
    * Simulator (обрабатывающая система)
    * Game step (шаг Simulator'а)
* Об игровом мире
  * Единицы измерения
  * Игровые объекты и классы
    * Классы игрока
    * class Strategy
      * Пример класса Strategy
  * Классы Симулятора
    * class Unit *(object: @my_unit)*
    * class Shell
    * class World *(object: @info)*

## Введение
**Настоятельно рекоментуется не отключать JavaScript в вашем браузере.**

## О пользовательском интерфейсе
На этом сайте можно выделить 5 главных страниц:
### Home page
На этой странице вы можете начать игру одного из двух типов:
#### Одиночная игра с ботом
* Вы можете покинуть ее в любой момент
* Эта игра не ограничена по времени

#### Игра с реальными игроками
* Игрок будет выбран случайно из других игроков в лобби игры (см ниже)
* Игра ограничена по времени (60 минут на данный момент)  
* Вы не можете покинуть игру, пока она не завершится
* When time will expire you can't send code, but able to see simulation or leave game

### Wait page
На этой странице вы будете ожидать других игроков, если вы выбрали мультиплеер.  
Когда в лобби появятся еще свободные игроки, игра начнется автоматически.

### Game page 
Содержит редактор кода и таймер отсчета времени до конца игровой сессии.  
На этой странице вы можете редактировать и отправлять код.    
Последний отправленный синтаксически верный код будет сохранен в базе данных и использован в симуляции.

### Simulation page
Страница с визуализацией игры.  
На ней вы можете увидеть сражение юнитов.  
Или ошибки, если что - то пошло не так (insecure operations, timeout of execution, runtime errors и другие)    
На данный момент ошибка в одной из стратегий вызовет ошибку в общей симуляции.  
Так что для успешной симуляции код обоих игроков должен быть корректным.

### Game Results Page
Страница с результатами игры.
Победитель получает **++** к своему общему счету побед.


## Об игровых сессиях
Игровые сессии ограничены по времени.  
По истечении времени вы не сможете отсылать новый код на сервер, но  
вы сможете сколько угодно раз просматривать симуляцию на странице Simulation.    
Чтобы закончить игру, нажмите кнопку Finish game на страницах Game Page или Simulation.    
Затем вы **не** сможете видеть симуляцию последней игровой сессии.  

## Туториал по игровому миру
### Определения игрового мира
#### Strategy
Класс игрока, которые определяет поведение юнита.

#### Simulator (обрабатывающая система)
Система, которая выполняет симуляцию игрового мира, основываясь на классах стратегий, написанных игроками (Strategy)

#### Game step (шаг Simulator'а)
Время, за которое код каждого из игроков будет выполнен ровно один раз.  
На каждом шаге Simulator выполняет код всех стратегий и рассчитывает поведение подконтрольных им юнитов.  
На каждом шагу Юнит может перемещаться и создавать Снаряды (любое из этих действий тратит энергию).

## Об игровом мире
![World map](static_pages_assets/background-xy.jpg)

* Игровой мир это квадрат со стороной размера `World::MAP_SIZE`.
* Ориентирование по миру производится с использованием координат (x, y).
* Центр системы координат находится в левом верхнем углу.
* Значения, которые могут принимать x и y лежат в интервале [0; World::MAP_SIZE].

### Единицы измерения
Единицы измерения, принятые в игровом мире:

* Game meter (g.m.) - абстрактная единица измерения расстояния
* Game second (g.s.) - аналог секунд, принятых в реальном мире. Непрерывная величина.
* Game meter / game second (g.m / g.s) - скорость

## Игровые объекты и классы
Местоположение игровых объектов задается координатами их центров.  
Все игровые объекты на данный момент представляют из себя окружности с центром в (x,y) и радиусом.

*Вы всегда можете увидеть сокращенную справку на Game Page*

### Классы игрока
#### class Strategy
Содержит код игрока, контролирующий поведение юнита.

Simulator вызовет метод initialize один раз (в начале симуляции).  
Затем метод move вызывается каждый simulation step.  
Перед очередным шагом симуляции поля @my_unit и @info стратегии будут обновлены.

**Время выполнения стратегии ограничено одной секундой.**

##### Пример класса Strategy
Ниже вы можете видеть стратегию, которая "кружит" юнита по квадрату и заставляет его запускать снаряды во врага.

```ruby
class Strategy
  def initialize
    # Инициализация главных объектов (@my_unit, @info)
    # Не переименовывайте их
    @my_unit = Unit.new
    @info    = World.new
    
    # Код игрока
    @count = 0
    @steps_limit = World::MAP_SIZE - 4
    @turns_count = 0
    @directions = [:right, :down, :left, :up]
  end

  # Этот метод будет вызываться на каждом шаге симуляции (см информацию выше)
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

### Классы Симулятора
#### class Unit *(object: @my_unit)*
![Unit](static_pages_assets/unit.png)

Unit может ходить и стрелять во врагов направленными снарядами.  
В игровом мире Unit представляет из себя окружность радиусом @my_unit.radius.  
На данный момент все характеристики всех юнитов одинаковы.

Unit's *shoot to* состоит из 2 фаз:

* Призыва снаряда с задержкой World::SHOOT_DELAY g.s.
* Затем снаряд появляется на расстоянии `World::SHOOT_DISTANCE` от "края" Unit  
  * Т.е. `World::SHOOT_DISTANCE` - расстояние между краем Shell и краем Unit. 

**Если у юнита недостаточно энергии для "выстрела", фаза призыва все равно будет произведена**

```ruby
class Unit
  # Поля класса для чтения
  @id # может быть использован для получения  инорфмации о юнитах соперников (см описание World)
  @state.health # Здорове юнита. Если оно станет <= 0 ваш юнит погибнет
  @state.energy # Энергия юнита. Может быть потрачена на создание Shell или перемещения
  
  @location # где центр юнита (точка)
  @location.x 
  @location.y 
  
  @speed # игровой метр / игрокая секунда
  @radius # радиус юнита в игровых метрах
  @max_health # максимульно возможное количество здоровья юнита
  @max_energy # максимально возможное количество энергии юнита
  
  # сказать юниту идти в точку (x, y)
  # на каждый пройденный метр расходуется World::ENERGY_PER_METER энергии
  def go_to(x,y) 
  end
  
  # Создать Shell, летящий в (x, y)
  # вызывает задержку в World::SHOOT_DELAY игровых секунд до появления снаряда
  def shoot_to(x,y)
  end
  
  # идти влево на расстояние 'length' вдоль оси x
  def go_left(length)
  end
  
  # идти вправо на расстояние 'length' вдоль оси x
  def go_right(length)
  end
  
  # идти вверх на расстояние 'length' вдоль оси y
  def go_up(length)
  end
  
  # идти вниз на расстояние 'length' вдоль оси y
  def go_down(length)
  end
end
```

### class Shell
![Shell](static_pages_assets/shell_dark.png)

Штука, при помощи которой юниты уничтожают врагов.  
Наносит урон лишь если касается юнита (пересечение или контакт между окружностями юнитов).  
При столкновении с юнитом снаряд исчезает, нанося юниту соответствующий урон (shell.damage).

```ruby
class Shell
  @location # где снаряд находится в днный момент
  @location.x
  @location.y
  
  @destination # куда он летит
  @destination.x
  @destination.y
  
  @speed # игровой метр / игровая секунда
  @damage # сколько здоровья потеряет юнит, когда в него попадет снаряд
  @radius # радиус снаряда в игровых метрах
end
```

### class World *(object: @info)*
Информационный класс. Содержит важные getters.

```ruby
class World
  # получить список соперников для игрока с id 'my_id'
  # применение: @info.get_enemies(@my_unit.id)
  def get_enemies( my_id ) 
  end
  
  # получить случайного юнита соперника для игрока с id 'my_id'
  # применение: @info.get_enemies(@my_unit.id)
  def get_enemy( my_id )
  end
    
  # получить список всех снарядов
  def get_shells
  end
end

# World constants
# размер стороны карты (карта представляет из себя квадрат)
World::MAP_SIZE 
# Сколько энергии потратит Unit на призыв Shell
World::SHOOT_ENERGY_COST 
# Сколько энергии юнит потратит на преодоление 1 игрового метра
World::ENERGY_PER_METER 
# сколько энергии будет восстановлено на следющем игровом такте
World::ENERGY_RESTORATION 
# Расстояние между "краем" юнита и "краем" его снаряда
World::SHOOT_DISTANCE 
# задержка между призывом и кастом Shell в игровых секундах
World::SHOOT_DELAY 
# расстояние между центрами unit и shell при создании снаряда
World::DISTANCE_BETWEEN_UNIT_AND_SHELL_POINTS 
```