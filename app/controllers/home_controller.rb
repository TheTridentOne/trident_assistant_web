# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    redirect_to collections_path
  end
end
