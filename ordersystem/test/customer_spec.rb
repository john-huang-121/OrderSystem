require 'rspec'
require 'money'
require 'monetize'
require_relative '../customer'
require_relative '../order'

RSpec.describe Customer do
    before(:all) do
        Money.default_currency = Money::Currency.new("USD")
        Money.rounding_mode   = BigDecimal::ROUND_HALF_EVEN
        Money.locale_backend  = nil
        I18n.enforce_available_locales = false
    end

    let(:customer_name) { "Alice" }
    let(:customer) { Customer.new(customer_name) }
    let(:item_1) { "broom" }
    let(:item_2) { "comb" }
    let(:price_1) { "$2.50" }
    let(:price_2) { "$5.00" }
    let(:order_1) { Order.new(customer_name, item_1, price_1, 3) }
    let(:order_2) { Order.new(customer_name, item_1, price_1, 2) }
    let(:order_3) { Order.new(customer_name, item_2, price_2, 1) }

    describe "#initialize" do
        it "sets the name correctly" do
            expect(customer.name).to eq(customer_name)
        end

        it "starts with an empty order_history" do
            expect(customer.no_orders?).to be true
            expect(customer.order_history).to be_empty
        end
    end

    describe "#add_order" do
        context "when first order for an item_name" do
            it "creates a new array under that item_name key" do
                expect(customer.order_history).to_not have_key(item_1)

                customer.add_order(order_1)

                expect(customer.order_history).to have_key(item_1)
                expect(customer.order_history[item_1]).to eq([order_1])
            end
        end

        context "when adding multiple orders for the same item_name" do
            it "appends to the existing array for that item_name" do
                customer.add_order(order_1)
                customer.add_order(order_2)

                expect(customer.order_history[item_1]).to match_array([order_1, order_2])
            end
        end

        context "when adding orders for different item_names" do
            it "creates separate keys for each item_name" do
                customer.add_order(order_1)
                customer.add_order(order_3)

                expect(customer.order_history[item_1]).to eq([order_1])
                expect(customer.order_history[item_2]).to eq([order_3])
            end
        end
    end

    describe "#no_orders?" do
        it "returns true if no orders have been added" do
            expect(customer.no_orders?).to be true
        end

        it "returns false once at least one order is added" do
            customer.add_order(order_1)

            expect(customer.no_orders?).to be false
        end
    end

    describe "#items_spend" do
        it "returns an empty array when no orders" do
            expect(customer.items_spend).to eq([])
        end

        context "with multiple orders" do
            before do
                customer.add_order(order_1)
                customer.add_order(order_2)
                customer.add_order(order_3)
            end

            it "returns an array of [item_name, total_spent] pairs with correct sums" do
                spend = customer.items_spend

                expect(spend).to include(
                    [item_1, Money.from_amount(12.50)],
                    [item_2, Money.from_amount(5.00)]
                )

                expect(spend.size).to eq(2)
            end
        end
    end

    describe "#items_spend_report" do
        context "when no orders" do
            it "returns an empty string" do
                expect(customer.items_spend_report).to eq("")
            end
        end

        context "with orders present" do
            before do
                customer.add_order(order_1)
                customer.add_order(order_3)
            end

            it "formats each item as 'item - $xx,xxx.xx' and joins with commas" do
                report = customer.items_spend_report

                expect(report).to include("#{item_1} - $7.50")
                expect(report).to include("#{item_2} - #{price_2}")
                expect(report).to include(", ")
            end
        end
    end

    describe "#average_spend" do
        context "when no orders" do
            it "returns nil" do
                expect(customer.average_spend).to be_nil
            end
        end

        context "with orders" do
            before do
                customer.add_order(order_1)
                customer.add_order(order_2)
                customer.add_order(order_3)
            end

            it "calculates average per distinct item_name key" do
                avg = customer.average_spend
                expect(avg).to be_a(Money)
                expect(avg.cents).to eq(875)
            end
        end
    end

    describe "#average_spend_report" do
        context "with orders" do
            before do
                customer.add_order(order_1)
                customer.add_order(order_2)
                customer.add_order(order_3)
            end

            it "returns string 'Average Order Value: $xx,xxx.xx'" do
                report = customer.average_spend_report
                expect(report).to eq("Average Order Value: $8.75")
            end
        end
    end
end
