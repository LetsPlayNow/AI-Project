class DemoGameSession < GameSession
  # todo override players method and create sample players which will not be in database
  def time_remaining
    0
  end

  def is_active?
    true
  end
end
