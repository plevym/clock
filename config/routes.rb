Rails.application.routes.draw do
  get '/alive', to: 'application#alive'
end
