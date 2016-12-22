require 'test_helper'

module GameTestHelper
  # Returns array of hashes-pairs, which seems like (user : remember_token)
  # It's needed to test multiple sign in
  def get_users_with_tokens
    users_with_tokens = []
    users = User.all
    users.each do |user|
      users_with_tokens.push({token: sign_in(user), user: user })
    end

    users_with_tokens
  end

  def change_session_by new_token
    cookies[:remember_token] = new_token
  end

  def sample_user
    User.first
  end

  def make_fake_game_with_one_player
    @user = User.first
    sign_in @user
    @game = GameSession.create
    @player = Player.create(user_id: user.id, game_session_id: game.id)
  end

  def make_game
    GameSession.create
  end

  def add_user_to_game(game, user)
    Player.create(user_id: user.id, game_session_id: game.id)
  end
end

class GameTest < ActionDispatch::IntegrationTest
  include GameTestHelper

  test "should create game session for many players" do
    users_info = get_users_with_tokens
    request_count = 0

    users_info.each do |user_token_pair|
      change_session_by user_token_pair[:token]
      get '/start_game'

      request_count += 1
      player_will_wait = request_count % GameSession.players_count == 0
      if player_will_wait
        assert_redirected_to({controller: :game_sessions, action: :game_page}, "Redirect to game page awaits")
      end
    end
  end

  test "should save correct code" do
    previous_code = @user.player.code
    make_fake_game_with_one_player
    code = "class Strategy\n end"
    post :code
    current_code = user.player.code
  end

  test "should not save uncorrect code" do
    previous_code = @user.player.code
    make_fake_game_with_one_player
    code = "class Strategy"
    post :code
    current_code = user.player.code
  end

  test "should correct simulation" do
    # add many users to game
    game = make_game
    users = User.all
    # TODO Not all users should be here
    users.each do |user|
      add_user_to_game(game, user)
    end

    # get request to simulation page
    users.each do |user|
      sign_in user
      get simulation_url
    end

    assert_redirected_to(:controller => :game_sessions, :action => :simulation)
  end

  test "should player finish game" do

  end

  test "should destroy game session" do

  end

  test "should deactivate game session" do

  end

  test "should player finish game and start new game" do

  end
end
