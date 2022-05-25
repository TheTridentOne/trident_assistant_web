# frozen_string_literal: true

Rails.application.routes.draw do
  draw :admin

  root 'home#index'

  post :login, to: 'sessions#create'
  get :login, to: 'sessions#new'
  get :logout, to: 'sessions#destroy'

  resources :view_modals, only: :create
  resources :collections
  resources :collections, module: :collections do
    resources :tasks, only: %i[index create show]
    resources :items, only: %i[index]
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
