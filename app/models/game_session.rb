class GameSession < ActiveRecord::Base
  has_many :players, dependent: :nullify
  has_many :users, through: :players

  # GameSession duration in seconds
  def self.game_duration
    5.minutes
  end

  def self.players_count
    2
  end

  # ����� ������� � �������� ������ (����� ����)
  def self.other_players_count
    GameSession.players_count - 1
  end

  def is_empty?
    !has_players?
  end

  # rewrite this
  def has_players?
    # players(true).all { |player| player.is_in_game}
    has_players = false
    players(true).each do |player|
      has_players ||= player.is_in_game
    end
    has_players
  end

  def winner
    winner_id && User.find(winner_id)
  end

  def is_active?
    @is_active ||= time_remaining > 0 # TODO test it
  end

  def time_remaining
    to_end = (end_time - Time.now).round
    (to_end < 0) ? 0 : to_end
  end

  private
    def end_time
      self.created_at.to_time + GameSession.game_duration
    end
end
