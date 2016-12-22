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

  def self.other_players_count
    GameSession.players_count - 1
  end

  def is_empty?
    !has_players?
  end

  # rewrite this
  def has_players?
    players(true).any? { |player| player.is_in_game }
  end

  def winner
    if winner_id.present?
      User.find(winner_id)
    else
      nil
    end
  end

  def is_active?
    @is_active = time_remaining > 0
  end

  # Returns remaining time in seconds
  def time_remaining
    time_lasts = end_time - Time.now
    if time_lasts < 0
      time_lasts = 0
    end

    return time_lasts
  end

  private
    def end_time
      self.created_at.to_time + GameSession.game_duration
    end
end
