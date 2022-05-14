# frozen_string_literal: true

Rails.application.routes.draw do
  root 'home#index'

  post :login, to: 'sessions#create'
  get :logout, to: 'sessions#destroy'
end
