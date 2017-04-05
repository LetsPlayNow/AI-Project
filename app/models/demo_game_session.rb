class DemoGameSession < GameSession
  def time_remaining
    0
  end

  def is_active?
    true
  end
end
