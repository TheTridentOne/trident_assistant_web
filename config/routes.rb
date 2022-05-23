# frozen_string_literal: true

Rails.application.routes.draw do
  draw :admin

  root 'home#index'

  post :login, to: 'sessions#create'
  get :login, to: 'sessions#new'
  get :logout, to: 'sessions#destroy'

  resources :view_modals, only: :create
  resources :collections do
    resources :tasks

    resources :items, only: %i[index] do
      post :withdraw
      post :deposit
    end
    resources :orders, only: %i[index]
  end

  post :sync_collections, to: 'collections#sync'

  post :sync_items, to: 'items#sync'
end
