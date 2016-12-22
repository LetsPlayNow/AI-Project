require 'test_helper'

=begin
get    '/start_game',       to: 'game_sessions#start_game'
  get    '/waiting_status',   to: 'game_sessions#start_game'
  post   '/cancel_waiting',   to: 'game_sessions#cancel_waiting'
  get    '/game_page',        to: 'game_sessions#game_page'
  post   '/code',             to: 'game_sessions#set_code'
  get    '/code',             to: 'game_sessions#get_code'
  get    '/simulation',       to: 'game_sessions#simulation'
  get    '/finish_game',      to: 'game_sessions#finish_game'
  get '/demonstration', to: 'game_sessions#demonstration'
=end

class GameSessionsControllerTest < ActionController::TestCase
  setup do
    # @game_session = game_sessions(:one)
  end


  # Will be saved state between these test methods
  # Tests for filters
  test "check signed in" do
    sign_in User.first # TODO fixture
    get '/start_game'
    assert_resonse :success
    post '/cancel_waiting'
    assert_response :success
  end

  # test "check has game" do
  #   if current_user && current_user.game.nil?
  #     assert_response :missing
  #   end
  # end
  #
  # test "check has no game" do
  #   if current_user && current_user.game.present?
  #     assert_redirected_to :start_game
  #   end
  # end
  #
  # test "check_game_is_active" do
  #
  # end
  #
  # test "check game is active" do
  #
  #
  # end
  #
  # test "check_game_is_ended" do
  #
  # end


  test "start game" do
    get :start_game

    # Авторизованный, неавторизованный. TODO Это можно вынести в один тест, в котором лишь это и будет проверяться (для каждого из фильтров по одному)
    # Есть игра, нет игры
    # Активная игра или нет
    # 1 игрок, 2 игрока
  end

  test "waiting_status" do

  end

  test "game page" do
    # Авторизованный, неавторизованный
    # Есть игра или нет игры
    # Активная игра или нет
  end

  test "should send code" do

  end

  test "should get code" do

  end

  test "should show simulation" do
    # Correct code and uncorrect code
  end

  test "finish game" do
    # Should finish game correctly

  end

  # TODO Is it correct to check many situations in one test?
  # TODO See how cool guys test their cool apps

=begin Tests generated via scaffolding
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:game_sessions)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create game_session" do
    assert_difference('GameSession.count') do
      post :create, game_session: {  }
    end

    assert_redirected_to game_session_path(assigns(:game_session))
  end

  test "should show game_session" do
    get :show, id: @game_session
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @game_session
    assert_response :success
  end

  test "should update game_session" do
    patch :update, id: @game_session, game_session: {  }
    assert_redirected_to game_session_path(assigns(:game_session))
  end

  test "should destroy game_session" do
    assert_difference('GameSession.count', -1) do
      delete :destroy, id: @game_session
    end

    assert_redirected_to game_sessions_path
  end
=end
end
