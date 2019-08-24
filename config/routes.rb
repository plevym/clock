Rails.application.routes.draw do
  get 'time_check/update'
  get '/alive', to: 'application#alive'
  resources :users do
    member do
      post 'check-time'
      get 'report'
    end
    resources :time_checks, only: [:index, :update]
  end
  post '/auth/login', to: 'authentication#login'
end
