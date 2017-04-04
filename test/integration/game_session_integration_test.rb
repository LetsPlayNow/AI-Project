require 'test_helper'

class GameSessionIntegrationTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  # test "the truth" do
  #   assert true
  # end

  test "simulation" do
    game = GameSession.create
    users = [User.first, User.second]
    players = users.map { |user| Player.create(user_id: user.id, game_session_id: game.id) }

    sign_in(users.first)
    get simulation_path
    assert_response :success

    finish_game_session(game)
    get simulation_path
    assert_response :success

    post finish_game_path
    assert_response :success

    # try to get simulation when leaved game
    get simulation_path
    assert_response :missing # maybe there should be error

    # second played tries simulation when game is over
    # seems like multiuser test does not works
    sign_in(users.second)
    get simulation_path
    assert_response :success
  end

  private
  def finish_game_session(game)
    game.created_at -= GameSession.game_duration
    game.save
  end
end
