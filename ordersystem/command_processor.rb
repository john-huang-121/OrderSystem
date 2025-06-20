class CommandProcessor
    attr_reader :store

    def initialize(store)
        @store = store
    end

    def generate_report
        @store.generate_report
    end

    def process(fields)
        command = fields[0]

        case command
        when "register"
            _, item_name, price, quantity = fields
            @store.register(item_name, price.to_money, quantity.to_i)
        when "checkin"
            _, customer_name, quantity = fields
            @store.checkin(customer_name, quantity.to_i)
        when "order"
            _, customer_name, item_name, quantity = fields
            @store.order(customer_name, item_name, quantity.to_i)
        else
            warn "Warning: Skipping unrecognized commmand: #{command}."
        end
    end
end