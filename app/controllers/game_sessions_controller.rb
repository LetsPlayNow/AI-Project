class GameSessionsController < ApplicationController
  include GameSessionsHelper::SyntaxErrors
  include GameSessionsHelper::Simulation

  before_filter :authenticate_user!
  before_filter :preset_variables
  before_filter :check_has_game,       except: [:start_game, :cancel_waiting, :demonstration]
  before_filter :check_has_no_game,    only:    :demonstration
  before_filter :check_game_is_active, only: :set_code
  before_filter :check_game_is_ended,  only:    :finish_game
  before_filter :reset_cache,          only:   [:game_page,  :simulation]
  after_action  :destroy,              only:    :finish_game

  # Идентификаторы ожидающих игры пользователей
  # TODO store it in database
  @@ids_if_waiting = Array.new # TODO change to self.ids_of_waiting

  # Периодически спрашивает, готова ли игра
  # Если игра готова, редирректит на страницу создания / входа игровой сессии
  # +@user+: current_user
  # TODO split it into 2 methods (create_game, continue_game)
  # TODO game session duration should be modifayable (and has default value)
  # TODO Тогда ты сможешь без костылей сделать игровую сессию укороченной длины
  # FIXME is_has_game может быть фильтром для этого экшена, который редиректит на игровую страницу, если игрок уже в игре
  def start_game
    respond_to do |format|
      if game_ready?
        find_or_create_game_session
        format.html { redirect_to :action => :game_page and return }
      else
        format.html { render :start_game and return }
      end

      # TODO вынести это в отдельный экшн
      format.json { render json: { :game_ready => game_ready?, :players_count => @@ids_if_waiting.size }}
    end
  end

  # Удаляет идентификатор игрока из @@ids_of_waiting_players в случае,
  # если тот покинул страницу ожидания
  # +@user+: current_user
  def cancel_waiting
    @@ids_if_waiting.delete @user.id
    head :no_content and return
  end


  # Страница редактором кода и базовыми ссылками
  # +@user+: user
  # +@game+: current_user.game
  def game_page
  end

  # Принимает код игрока, проверяет его на ошибки и сохраняет в БД
  # +@game+: current_user.game
  # +@user+: current_user
  def set_code
    @player_code = params[:player_code]

    errors = syntax_errors(@player_code)
    if syntax_ok? errors
      @user.player.update_attribute(:code, @player_code)
      errors = 'Syntax OK'
    end

    render json: {:errors => errors}
  end

  # Возвращает код игрока
  # +@user+: current_user
  def get_code
    render json: @user.player.code
  end

  # Симуляция
  # +@game+: current_user.game
  def simulation
    codes = {}
    @game.players(true).each { |player| codes[player.user_id] = player.code }

    remove_previous_strategies_definitions
    begin
      # fixme как квариант, можно хранить симулятор в переменной и делать refresh
      @simulator_output = AIProject::Simulator.new(codes).simulate
    rescue RuntimeError, NameError => e
      @simulator_output = {errors: e.message}
    end

    if @simulator_output[:errors].nil?
      @game.update_attribute(:winner_id, @simulator_output[:options][:winner_id])
    end
    add_players_info_in @simulator_output

    respond_to do |format|
      format.html
      format.json {render json: @simulator_output and return}
    end
  end

  # Выводит результаты игры для игрока при выходе
  # Удаляет игровую сессию, когда все игроки вышли
  # +@user+: current_user
  # +@game+: current_user.game
  def finish_game
    @user.player.update_attribute(:is_in_game, false)
    # TODO destroy players
    # after that destroy game session
  end

  # Game with fake players
  # User can easily leave it and start other game
  # TODO user can't send code when game is finished
  def demonstration
    # TODO create fake user for this player
    # Maybe constant for User table
    # Create game with user and fake user (where to store it's strategy?)
    @game = GameSession.create
    @player = Player.create(user_id: @user.id, game_session_id: @game.id)
    fake_players = []
    GameSession.other_players_count.times do |i|
      # TODO we need create module with Strategies samples in lib
      # TODO store class as file (it will be executable) and read it as string to here
      code = "class Strategy\n  def initialize\n    @my_unit = Unit.new\n    @info    = World.new\n  end\n\n  def move\n    # Write logic here\n  end\nend"
      fake_players.append(Player.create(game_session_id: @game.id, code: code)) # fixme there should not be collisions with real user ids
    end
    redirect_to :game_page
    # todo we can simulate one times and after that show user cycled battle animation
  end

  private
    def game_ready?
      unless @@ids_if_waiting.include? @user.id
        @@ids_if_waiting.push @user.id
      end

      enough_players  = @@ids_if_waiting.size >= GameSession.players_count
      game_is_created = @user.game.present?

      enough_players || game_is_created
    end

  # Если игра для нас уже создана, переходим на игровую страницу
  # Если игра для нас не создана, создаем ее
    def find_or_create_game_session
      @@ids_if_waiting.delete @user.id
      @game = @user.game

      if @game.nil?
        # Создаем игрвую сессию
        @game = GameSession.create # fixme задержка до завершения этого экшена вычитается из времени игровой сессии

        # Выбираем игроков
        other_players = [@user.id]
        GameSession.other_players_count.times do
          next_user_id = @@ids_if_waiting.sample
          other_players.push next_user_id
          @@ids_if_waiting.delete next_user_id
        end

        # Создаем игроков
        other_players.each do |user_id|
          Player.create(user_id: user_id, game_session_id: @game.id)
        end
      end
    end

    def increment_winner_statistic
      if @game.winner.present?
        @game.winner.increment(:wins_count).save
      end
    end

  # it was a part of finish_game action,
  # but it caused an interesting behaviour:
  # @game.users.each doent's work due to  @game was destroyed
  # but if i did @users = @game.users before that,
  # finish_game.html.erb searched users in database (not in @users)
    def destroy
      if @game.is_empty?
        increment_winner_statistic
        @game.destroy
      end
    end

  # FILTERS
  # ==================================================================================
    def check_has_game
      @game = @user.game
      not_found if @game.nil?
    end

  # Player has game already
  def check_has_no_game
    @game = @user.game
    redirect_to action: :start_game if @game.present?
  end

  # В неактивной игре игроки не имеют права отправлять код
  def check_game_is_active
    head 500 unless @game.is_active?
  end

  # Нельзя покидать игру до ее завершения
  def check_game_is_ended
    head 500 if @game.is_active?
  end

  # Нужно, чтобы браузер не забывал брать свежие данные о симуляции у сервера (а не лез за ними в хэш)
  def reset_cache
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end

  # todo fixme
  def preset_variables
    @user = current_user
  end
end