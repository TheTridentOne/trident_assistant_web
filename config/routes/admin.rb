# frozen_string_literal: true

require 'sidekiq/web'
require 'sidekiq/cron/web'

class AdminConstraint
  def matches?(request)
    return false if request.session[:current_user_id].blank?

    user = User.find_by(id: request.session[:current_user_id])
    user&.admin?
  end
end

# Below are the routes for admin
constraints(AdminConstraint.new) do
  namespace :admin do
    mount Sidekiq::Web, at: 'sidekiq', constraints: AdminConstraint.new

    root to: 'dashboard#index'
    resources :users, only: %i[index show]
    resources :items, only: %i[index show], param: :metahash
    resources :collections, only: %i[index show]
  end
end
