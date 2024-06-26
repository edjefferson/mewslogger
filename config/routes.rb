Rails.application.routes.draw do
  devise_for :admins
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  root "mewses#index"

  resources :mewses , :path => :mews

  get 'all_mews' => 'mewses#all_mews'

  get 'visited' => 'mewses#visited'

  post 'update_mews' => 'mewses#update'
  post 'togglevisited' => 'mewses#toggle_visited'
  post 'update_notes' => 'mewses#update_notes'
  post 'imageupload' => 'mewses#upload_image'

  post 'update_mews_lat_lng' => 'mewses#update_mews_lat_lng'
end
