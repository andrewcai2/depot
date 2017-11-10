class StoreController < ApplicationController
  include ActionView::Helpers::TextHelper
  include CurrentCart
  before_action :set_cart
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
    @count_message
    if !session[:counter].nil? and session[:counter] > 5
      @count_message =  "You have been here #{pluralize(session[:counter], 'time', 'times')}!"
    end
  end
end

