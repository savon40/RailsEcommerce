class AddOrderToProductItems < ActiveRecord::Migration[5.0]
  def change
    add_reference :product_items, :order, index: true
  end
end
