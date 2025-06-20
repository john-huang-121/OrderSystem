require_relative 'customer'
require_relative 'item'
require 'money'
require 'monetize'

class Store
    attr_reader :items, :customers

    def initialize()
        @items = {}
        @customers = {}
    end

    def register(item_name, price, quantity = 0)
        return false if @items[item_name]
        @items[item_name] = Item.new(item_name, price, quantity)
        true
    end

    def checkin(item_name, quantity)
        return false if quantity < 0
        item = @items[item_name]

        raise ArgumentError, "Cannot check in #{item_name}. It does not exist in the system." unless item
        
        item.add_stock(quantity)

        true;
    end

    def order(customer_name, item_name, quantity)
        customer = (@customers[customer_name] ||= Customer.new(customer_name))
        item = @items[item_name] || nil

        return false if item.nil? || !item.enough_stock?(quantity)

        order = Order.new(customer.name, item.name, item.price, quantity)
        customer.add_order(order)

        item.remove_stock(quantity)

        true;
    end

    def generate_report
        report = []

        # sort alpabetically by name?
        @customers.each_value do |customer|
            report << "#{customer.name}: #{customer.no_orders? ? 'n/a' : "#{customer.items_spend_report} | #{customer.average_spend_report}"}"
        end

        report
    end
end