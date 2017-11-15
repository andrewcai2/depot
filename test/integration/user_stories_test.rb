require 'test_helper'

class UserStoriesTest < ActionDispatch::IntegrationTest
  fixtures :products
  include ActiveJob::TestHelper
  
  test "buying a product" do
    start_order_count = Order.count
    ruby_book = products(:ruby)

    # A user goes to the store index page
    get "/"
    assert_response :success
    assert_select 'h1', "The Catalog"

    # He selects a product, adding it to his cart
    post '/line_items', params: { product_id: ruby_book.id }, xhr: true
    assert_response :success

    cart = Cart.find(session[:cart_id])
    assert_equal 1, cart.line_items.size
    assert_equal ruby_book, cart.line_items[0].product

    # He then checks out
    get "/orders/new"
    assert_response :success
    assert_select 'legend', 'Please enter your details'

    perform_enqueued_jobs do
      post "/orders", params: {
        order: {
          name: "Dave Thomas",
          address: "123 The Street",
          email: "dave@example.com",
          pay_type: "Check"
        }
      }

      follow_redirect!

      assert_response :success
      assert_select 'h1', "The Catalog"
      cart = Cart.find(session[:cart_id])
      assert_equal 0, cart.line_items.size

      assert_equal start_order_count + 1, Order.count
      order = Order.last
      assert_equal "Dave Thomas", order.name
      assert_equal "123 The Street", order.address
      assert_equal "dave@example.com", order.email
      assert_equal "Check", order.pay_type

      assert_equal 1, order.line_items.size
      line_item = order.line_items[0]
      assert_equal ruby_book, line_item.product

      # He then receives an email confirmation
      mail = ActionMailer::Base.deliveries.last
      assert_equal ["dave@example.com"], mail.to
      assert_equal 'Andrew Cai <depot@example.org>', mail[:from].value
      assert_equal "Pragmatic Store Order Confirmation", mail.subject
    end
  end
end
