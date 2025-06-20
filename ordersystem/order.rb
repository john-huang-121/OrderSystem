require 'money'
require 'monetize'

class Order
    attr_reader :customer_name, :item_name, :price, :quantity

    def initialize(customer_name, item_name, price, quantity)
        @customer_name = customer_name
        @item_name = item_name
        @price = price.to_money
        @quantity = quantity
    end
end