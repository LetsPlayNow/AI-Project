class User < ActiveRecord::Base
  has_many :players
  has_many :game_sessions, through: :players

  VALID_NAME_REGEX = /\A[A-Za-z\d_]+\z/
  validates :name, uniqueness: true, presence: true, format: {with: VALID_NAME_REGEX}, length: {maximum: 50}

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+\.[a-z]+\z/i
  validates :email, presence: true, format: {with: VALID_EMAIL_REGEX}, uniqueness: { case_sensitive: false }

  has_secure_password #'bcrypt', '3.1.9'
  validates :password, length: { minimum: 6 } #, if: :create_action

  before_save { self.email = email.downcase }
  before_create :create_remember_token

  def User.new_remember_token
    SecureRandom.urlsafe_base64
  end

  def User.encrypt(token)
    Digest::SHA1.hexdigest(token.to_s)
  end

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

  private
    def create_remember_token
      self.remember_token = User.encrypt(User.new_remember_token)
    end
end
