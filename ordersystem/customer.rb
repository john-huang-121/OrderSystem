require_relative 'order'
require 'money'
require 'monetize'

class Customer
    attr_reader :name, :order_history

    def initialize(name)
        @name = name
        @order_history = {}
    end

    def add_order(order)
        item_name = order.item_name

        if @order_history[item_name]
            @order_history[item_name].push(order)
        else
            @order_history[item_name] = [order]
        end

        return true
    end

    def no_orders?
        @order_history.size == 0
    end

    def items_spend
        @order_history.map do |item_name, orders_arr|
            # can use money-collection for faster sum performance
            purchase_total = orders_arr.map {|order| order.price * order.quantity}.sum

            [item_name, purchase_total]
        end
    end

    def items_spend_report
        items_spend_arr = items_spend.map do |item_name, purchase_total|
            "#{item_name} - #{purchase_total.format(thousands_separator: ",")}"
        end

        return items_spend_arr.join(', ')
    end

    def average_spend
        items_count = @order_history.size

        return nil if items_count == 0

        total = items_spend.reduce(Money.new(0)) {|sum, (_, purchase_total)| sum + purchase_total}
        average = total / items_count

        return average
    end

    def average_spend_report
        return "Average Order Value: #{average_spend.format(thousands_separator: ",")}"
    end
end