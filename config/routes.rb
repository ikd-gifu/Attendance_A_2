Rails.application.routes.draw do

  root 'static_pages#top'
  get '/signup', to: 'users#new'

  get    '/login', to: 'sessions#new'
  post   '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

  get   '/edit_system_info', to: 'bases#edit_system_info'

  resources :bases

  resources :users do
    collection {post :import} #csvインポート用ルーティング
    member do
      get 'edit_basic_info'
      patch 'update_basic_info'
      get 'attendances/edit_one_month'
      patch 'attendances/update_one_month'
      get 'users_at_work'
      get 'attendances/edit_one_day_overtime_application'
      patch 'attendances/update_one_day_overtime_application'
      get 'attendances/edit_overtime_application_notification'
      patch 'attendances/update_overtime_application_notification'
    end
    resources :attendances, only: :update
  end
end