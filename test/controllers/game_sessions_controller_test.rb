require 'test_helper'

class GameSessionsControllerTest < ActionController::TestCase
  setup do
    # @game_session = game_sessions(:one)
  end

  test "start game" do
    # Неавторизованный
    get :start_game
    assert_response :redirect, "Should get sign_in page"

    # Авторизованный
    user = User.first
    sign_in(user)
    get :start_game
    assert_response :success, "Should get start page"

    # Уже есть игра
    game = GameSession.create
    player = Player.create(user_id: user.id, game_session_id: game.id)

    get :start_game
    assert_redirected_to :game_page, "Should continue game"
  end


  test "game page" do
  end

  test "send code" do
    user = User.first
    sign_in(user)

    game = GameSession.create
    player = Player.create(user_id: user.id, game_session_id: game.id)

    # Отправить корректный код
    default_code = player.code
    new_code = "class Strategy \n end"
    post :set_code, player_code: new_code
    assert_not_equal(user.player.code, default_code, "Code must be changed")

    # Отправить некорректный код
    invalid_code = "class"
    player_code = user.player.code
    post :set_code, player_code: invalid_code
    assert_equal(user.player.code, player_code, "Code must not be changed")

    # Игра была завершена
    finish_game_session(game)

    post :set_code, player_code: new_code
    assert_response :error
  end

  test "get code" do
    user = User.first
    game = GameSession.create
    player = Player.create(user_id: user.id, game_session_id: game.id)

    sign_in(user)
    get :get_code
    assert_response :success

    assert_equal(@response.body, player.code)

    # Игра была завершена
    finish_game_session(game)
    get :get_code
    assert_response :success
  end


  test "finish game" do
    game = GameSession.create
    users = [User.first, User.second]
    players = users.map { |user| Player.create(user_id: user.id, game_session_id: game.id) }

    # Попытка покинуть незавершившуюся игру
    sign_in(User.first)
    get :finish_game
    assert_response :error, "Should not finish game unitl time is not over"

    # Попытка покинуть завершившуюся игру
    finish_game_session(game)

    get :finish_game
    assert_response :success, "Successfully finish game"

    get :game_page
    assert_response :missing, "Game was finished"
  end

  test "simulation" do
    game = GameSession.create
    users = User.first

    players = users.map { |user| Player.create(user_id: user.id, game_session_id: game.id) }

    sign_in(users.first)
    get :simulation
    assert_response :success

    finish_game_session(game)
    get :simulation
    assert_response :success

    get :finish_game
    assert_response :success

    # try to get simulation when leaved game
    get :simulation
    assert_response :missing # maybe there should be error
  end


  private
  def finish_game_session(game)
    game.created_at -= GameSession.game_duration
    game.save
  end
end
