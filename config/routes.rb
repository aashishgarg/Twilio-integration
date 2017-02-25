Rails.application.routes.draw do
  devise_for :users, controllers: {registrations: 'users/registrations'},
             :skip => [:sessions, :registrations, :passwords, :confirmations]

  devise_scope :user do
    post '/sign-up' => 'users/registrations#create'
    put '/update_my_profile' => 'users/registrations#update'
  end

  post '/register_mobile', to: 'messages#register_mobile', as: 'register_mobile'
  post '/new_auth_token', to: 'users#new_auth_token', as: 'new_auth_token'
end
