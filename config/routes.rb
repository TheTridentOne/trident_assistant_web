# frozen_string_literal: true

Rails.application.routes.draw do
  draw :admin

  # health check for render.com
  get 'healthz', to: 'healthz#index', as: :healthz
  post 'authorize_trident', to: 'home#authorize_trident', as: :authorize_trident

  root 'home#index'

  post :login, to: 'sessions#create'
  get :login, to: 'sessions#new'
  get :logout, to: 'sessions#destroy'

  resources :view_modals, only: :create

  resources :collections do
    post :list
    match :attach, via: %i[put patch]
  end

  resources :collections, module: :collections do
    resources :mint_nft_tasks, only: %i[new create]
    resources :generate_nft_tasks, only: :create

    resources :items, except: :index
    post :bulk_destroy_items, to: 'items#bulk_destroy'

    resources :orders, only: %i[index]

    resources :attachments, only: %i[index new destroy]
  end

  resources :ask_order_tasks, only: %i[new create]
  resources :auction_order_tasks, only: %i[new create]
  resources :cancel_order_tasks, only: %i[new create]
  resources :fill_order_tasks, only: %i[new create]

  resources :deposit_nft_tasks, only: %i[new create]
  resources :transfer_nft_tasks, only: %i[new create]
  resources :withdraw_nft_tasks, only: %i[new create]

  resources :items, only: %i[index]
  resources :orders, only: %i[index]
  resources :tasks, only: %i[index show create] do
    post :cancel
    post :start_process
  end

  resource :wallet, only: %i[show] do
    get :items
    get :assets
    get :snapshots
    post :transfer
  end

  post :sync_collections, to: 'collections#sync'

  post :sync_items, to: 'items#sync'
end
