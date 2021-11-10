# [AI - Project](https://ai-project-new.herokuapp.com/)
![One of game sessions](https://user-images.githubusercontent.com/9571479/140824280-6b2bd837-032d-477e-9ecb-f63f84460039.gif)

> Everyone can write their own AI. It is one of the main ideas of this website.  
[Code Game Challenge](https://habrahabr.ru/post/270953/) is a very interesting competition conducted worldwide in many different forms.  
Most of them are held as side events at various programming competitions, like [ACM ICPC](http://icpc.baylor.edu/).  
They consist in writing the logic for a player-controlled unit that performs some actions in the game world.  
Remember your favorite game.  
What if you could program the behavior of your character,   
and then see how it behaves under your code's control?  
Interesting, isn't it?  
On this website, you can do something similar, and from anywhere, anytime.

This Rails app allows you to participate in [Code Game Challenge](https://habrahabr.ru/post/270953/) competitions.  
You can play with other players or train with bots.   
The app contains many interesting WEB techniques and features (check the list below).

## Lexicon
**Strategy**  
Player's class that defines the behavior of your unit (in our case, a wizard)

**Simulator (the processing system)**  
A system that performs a simulation of a game world based on classes written by players (Strategies)

**Game step (simulation step)**  
It is a world simulation resolution.
At every step, Simulator executes the code of all strategies and processes behavior of their units.  
During this process, units can issue commands to walk and cast shells (each move costs some energy to perform).

## Features 
### Game Sessions 
Scallable implementation of game sessions.

* Recruit players from the lobby
* Game Sessions can be limited in time
* You can see the game visualization at any moment

### My Simulator 
The Simulator processes the game world state and players' strategies code, which control your unit.  
Main features of the Simulator are:
* Expandable tiny game engine
  * You can add many things, like new skills for units, new game objects, new constraints & so on
* Secure execution of players strategies classes
* Support for strategies written in Ruby
* Output is a JSON file
* You can visualize output with (app/assets/javascripts/visualizer)

## Interesting Techniques
* Number of static pages are written in Markdown
* Device gem
* Secure player's code evaluation
* Bootstrapped views
* Custom 404 pages
* Heroku workaround for Hobby price plan (DB errors)
* Online code editor for strategies

## Steps to get the application running
### Ruby version  
Ruby 2.2.4

### System dependencies  
Linux systems (due to `secure` gem)

### Configuration  
1) Create database for required environment (prod or dev)  
`rake db:schema:load`
2) Precompile assets  
`rake assets:clean && rake assets:precompile`

For production, you will also need to add the keys to `config/secrets.yml` and `initializers/devise.rb`

### How to run the test suite
Tests use `Minitest` library.  
Use `rake test` to run all tests.

### Deployment instructions
The app is deployed on Heroku with 'Hobby' plan:   
https://ai-project-new.herokuapp.com/

#### Heroku Hobby pricing plan issues
Sometimes PostgresDB closes connections.  
One workaround here is to `rescue` these moments and reconnect.  
This technique is implemented in simulation action in the GameSession controller.
