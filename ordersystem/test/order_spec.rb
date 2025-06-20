require 'rspec'
require 'money'
require 'monetize'
require_relative '../order'

RSpec.describe Order do
  describe "#initialize" do
    context "when given valid args" do
      let(:customer_name) { "Nick" }
      let(:item_name) { "Shampoo" }
      let(:price) { "$100.00" }
      let(:quantity) { 2 }
      let(:order) { Order.new(customer_name, item_name, price, quantity)}

      it "can create an order with customer_name, item_name, price, quantity" do
        expect(order.customer_name).to eq(customer_name)
        expect(order.item_name).to eq(item_name)
        expect(order.price).to be_a(Money)
        expect(order.price).to eq(Money.new(10000, :USD))
        expect(order.quantity).to eq(quantity)
      end
    end
  end
end
