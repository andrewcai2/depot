class CombineItemsInCart < ActiveRecord::Migration[5.1]
  def change
  end

  def up
    # merge multiple items for a single product in a cart
    Cart.all.each do |cart|
      sums = cart.line_items.group(:product_id).sum(:quantity)

      sums.each do |product_id, quantity|
        if quantity > 1
          #remove individual items
          cart.line_items.where(product_id: product_id).delete_all

          #replace with a single iitem
          item = cart.line_item.build(product_id: product_id)
          item.quantity = quantity
          item.save!
        end
      end
    end
  end

  def down
    # split multiple items into an individual line item for each product
    LineItem.where("quantity>1").each do |line_item|
      line_item.quantity.times do
        LineItem.create(
          cart_id: line_item.cart_id,
          product_id: line_item.product_id,
          quantity: 1
        )
      end
      # remove the line item
      line_item.destroy
    end
  end
end
