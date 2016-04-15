module AIProject
  class State
    attr_reader :health, :energy
    def initialize(health, energy)
      @health = health
      @energy = energy
    end

    def health=(value)
      @health = value.round # TODO maybe there should be Settings::PRECISION but it is INT!
    end

    def energy=(value)
      @energy = value.round
    end
  end
end