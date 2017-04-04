class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  has_many :players
  has_many :game_sessions, through: :players

  # Get user's current game
  def game
    player && player.game_session(true) # TODO @game ||= player.game_session
  end

  # Get user's active player
  def player
    players(true).where(is_in_game: true).first
  end

  def in_game?
    player && player.is_in_game
  end

  def name
    # todo slice name from email
    "chappy"
  end
end