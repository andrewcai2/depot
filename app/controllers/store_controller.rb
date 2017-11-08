class StoreController < ApplicationController
  after_action :increment_counter, only: [:index]

  def increment_counter 
    if session[:counter].nil?
      session[:counter] = 0
    else 
      session[:counter] += 1
    end
  end 
  
  def index
    @products = Product.order(:title)
  end
end

