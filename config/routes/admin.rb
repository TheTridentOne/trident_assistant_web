# frozen_string_literal: true

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
    mount GoodJob::Engine, at: 'good_job', constraints: AdminConstraint.new

    resources :users, only: %i[index show]
    resources :collections, only: %i[index show]
    resources :items, only: %i[index show]
    resources :orders, only: %i[index show]
    resources :tasks, only: %i[index show]

    root to: 'collections#index'
  end
end
