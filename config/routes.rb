Rails.application.routes.draw do
  devise_for :users
  get '/profile', to: 'users#show', as: :user_profile
  root to: 'static_pages#home'

  # Static pages
  get '/home',                to: 'static_pages#home'
  get '/about',               to: 'static_pages#about'
  get '/help',                to: 'static_pages#help'
  get '/about',               to: 'static_pages#about'
  get '/support_project',     to: 'static_pages#support_project'
  #get '/funny_tutorial',     to: 'static_pages#funny_tutorial'

  # GameSessions
  get '/start_game', to: 'game_sessions#start_game', as: :start_game
  get    '/waiting_status',   to: 'game_sessions#start_game'
  post   '/cancel_waiting',   to: 'game_sessions#cancel_waiting'
  get '/game_page', to: 'game_sessions#game_page', as: :game_page
  post   '/code',             to: 'game_sessions#set_code'
  get    '/code',             to: 'game_sessions#get_code'
  get '/simulation', to: 'game_sessions#simulation', as: :simulation
  post '/finish_game', to: 'game_sessions#finish_game', as: :finish_game
  get '/demonstration', to: 'game_sessions#demonstration', as: :demonstration
  get '/404', to: 'application#render_404'


end
