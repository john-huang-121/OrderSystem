require 'money'
require 'monetize'

class Item
    attr_reader :name, :price
    attr_accessor :quantity

    def initialize(name, price, quantity)
        @name = name
        @price = price.to_money
        @quantity = quantity
    end

    def add_stock(quantity)
        return false if quantity < 0
        @quantity += quantity
        true
    end
    
    def enough_stock?(quantity)
        return false if quantity == 0
        @quantity - quantity >= 0
    end
    
    def remove_stock(quantity)
        return false if quantity > @quantity || quantity < 0
        @quantity -= quantity
        true
    end
end