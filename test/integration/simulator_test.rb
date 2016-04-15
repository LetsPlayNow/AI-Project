require 'test_helper'

module TestData1
  def self.get_codes
    codes = {}
    codes[1] = "
class Strategy
  def initialize
    @my_unit = Unit.new
    @info    = World.new
  end

  def move
    @my_unit.shoot_to(6, 6)
  end
end"

  codes[2] = "
class Strategy
  def initialize
    @my_unit = Unit.new
    @info    = World.new
  end

  def move
  end
end
"
  codes[11] = "
class Strategy
  def initialize
    @my_unit = Unit.new
    @info    = World.new
  end

  def move
  end
end
"
    return codes
  end
end


class SimulatorTest < ActionDispatch::IntegrationTest
  test "simulator_should_simulate_correctly" do
    codes = TestData1.get_codes
    simulator = AIProject::Simulator.new(codes)
    result = simulator.simulate
    assert result[:errors].nil?
  end
end
