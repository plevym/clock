Rails.application.routes.draw do
  get '/alive', to: 'application#alive'
  resources :users do
    member do
      post 'check-time'
      get 'report'
    end
  end
  post '/auth/login', to: 'authentication#login'
end
