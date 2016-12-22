require 'test_helper'

class GameSessionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  test "is active" do
    game = GameSession.create

    assert_equal(true, game.is_active?, "Created game is active")

    game.created_at -= GameSession.game_duration
    game.save

    assert_equal(false, game.is_active?, "Created game is active")
  end

  test "has_players" do
    game = GameSession.create
    user = User.first

    player = Player.create(game_session_id: game.id, user_id: user.id)
    assert_equal(true, game.has_players?, "Should have active players")

    player.is_in_game = false
    player.save
    assert_equal(false, game.has_players?, "Should have active players")

    game.players.delete(player)
    assert_equal(false, game.has_players?, "Should have active players")
  end
end
