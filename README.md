# AI - Project
![One of game sessions](https://habrastorage.org/files/725/56e/b15/72556eb1580f45b1bc969e5d93ff84ea.gif)

> Everyone can write it's own AI. This is one of the main ideas of this site.  
Worldwide conducted a very interesting competition, commonly referred as [Code Game Challenge](https://habrahabr.ru/post/270953/).  
Most of them are held on various programming competitions, like [ACM ICPC](http://icpc.baylor.edu/).  
They consist in writing the logic of conduct for player-controlled unit that exists in the game world.  
Remember your favorite game.  
What if you could program the behavior of your character,   
and then see how it behaves under the control of your code?  
Interesting, isn't it?  
On this website you can do something similar, and from anywhere, anytime.

This Rails app allows you to participate in [Code Game Challenge](https://habrahabr.ru/post/270953/) compititions.  
You can play with other players or train with bots.   
App contains many interesting WEB techiques and features (check below).

## Lexicon
**Strategy**  
Player's class that defines behavior of your unit (in out case unit is a wizard)

**Simulator (the processing system)**  
A system that performs simulation of game world based on classes written by players (Strategies)

**Game step (simulation step)**  
The time in which the code of all players executed exactly one time.  
At every step Simulator executes code of all strategies and processes behavior of their units.  
On each step unit can walk and cast shells (every move spend energy).

## Features 
### Game Sessions 
Scallable implementation of game sessions.

* Recruit players from the lobby
* Game Sessions can be limited in time
* In the end of game session you still able so see game visualization

### My own Simulator 
Process game world states and players strategies (code which controlls your unit).
* Expandable tiny game engine
  * Can be added many things like new skills for units, new game objects, limitations & so on
* Secure execution of players strategies classes
* Support strategies written in Ruby
* Output is json file
* Expandable visualizer exists (app/assets/javascripts/visualizer)

## Interesting Techniques
* Number of static pages are written in Markdown
* Device gem
* Secure player's code evaluation
* Bootstrapped views
* Custom 404 pages
* Heroku workaround for Hobby price plan (DB errors)

## Steps to get the application up and running
### Ruby version  
In developing was used Ruby 2.2.4

### System dependencies  
Linux systems (due to `secure` gem)

### Configuration  
1) Create database for needed environment (prod or dev)  
`rake db:schema:load`
2) Precompile assets  
`rake assets:clean && rake assets:precompile`

For production you will need also add keys in `config/secrets.yml` and `initializers/devise.rb`

### How to run the test suite
Minitest used as Rails test engine.  
Use `rake test` to run all tests.

### Deployment instructions
This app was deployed on Heroku: 
https://ai-project-new.herokuapp.com/

It uses Hobby pricing plan on Heroku.
#### Heroku Hobby pricing plan issues
Sometimes PostgresDB closing it's connections.  
One workaround there - is to rescue these moments and reconnect.  
This way is implemented in simulation action in GameSession controller.