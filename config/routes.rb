Rails.application.routes.draw do
  root 'game#index', as: 'game_index'
  post 'game/action', to: 'game#action'
  post '/game/reset', to: 'game#reset', as: 'reset_game'

end
