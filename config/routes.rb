# frozen_string_literal: true

Rails.application.routes.draw do
  draw :admin

  # health check for render.com
  get 'healthz', to: 'healthz#index', as: :healthz

  root 'home#index'

  post :login, to: 'sessions#create'
  get :login, to: 'sessions#new'
  get :logout, to: 'sessions#destroy'

  resources :view_modals, only: :create
  resources :collections do
    post :list
  end
  resources :collections, module: :collections do
    resources :tasks, only: %i[index show] do
      post :cancel
      post :start_process
    end

    resources :ask_order_tasks, only: :create
    resources :auction_order_tasks, only: :create
    resources :cancel_order_tasks, only: :create
    resources :fill_order_tasks, only: :create

    resources :deposit_nft_tasks, only: :create
    resources :transfer_nft_tasks, only: :create
    resources :withdraw_nft_tasks, only: :create
    resources :mint_nft_tasks, only: :create

    resources :generate_nft_tasks, only: :create

    resources :items
    post :bulk_destroy_items, to: 'items#bulk_destroy'

    resources :orders, only: %i[index]
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
