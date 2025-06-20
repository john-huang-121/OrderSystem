# spec/store_spec.rb
require 'rspec'
require 'money'
require 'monetize'
require_relative '../item'
require_relative '../order'
require_relative '../customer'
require_relative '../store'

RSpec.describe Store do
    before(:all) do
        Money.default_currency = Money::Currency.new("USD")
        Money.rounding_mode   = BigDecimal::ROUND_HALF_EVEN
        Money.locale_backend  = nil
        I18n.enforce_available_locales = false
    end

    let(:store) { Store.new }
    let(:item_1) { "book" }
    let(:item_2) { "pen" }
    let(:price_1) { "$10.00" }
    let(:price_2) { "$2.00" }

    describe "#initialize" do
        it "starts with empty items and customers hashes" do
            expect(store.items).to eq({})
            expect(store.customers).to eq({})
        end
    end

    describe "#register" do
        it "creates a new Item with the given name, price, and default quantity 0" do
            store.register(item_1, price_1)

            expect(store.items).to have_key(item_1)

            item = store.items[item_1]

            expect(item).to be_a(Item)
            expect(item.name).to eq(item_1)
            expect(item.price).to be_a(Money)
            expect(item.price.cents).to eq(1000)
            expect(item.quantity).to eq(0)
        end

        it "allows specifying an initial stock quantity" do
            store.register(item_2, price_2, 5)

            pen = store.items[item_2]

            expect(pen.quantity).to eq(5)
        end

        it "doesn't overwrite an existing item if the same name is registered again" do
            status_1 = store.register(item_1, price_1)
            old_item = store.items[item_1]

            status_2 = store.register(item_1, price_2)

            expect(status_1).to eq(true)
            expect(status_2).to eq(false)
            expect(old_item.price.cents).to eq(1000)
        end
    end

    describe "#checkin" do
        context "when the item exists" do
            before do
                store.register(item_1, price_1, 2)
            end

            it "adds stock to the existing item and returns true" do
                result = store.checkin(item_1, 3)

                expect(result).to be(true)
                expect(store.items[item_1].quantity).to eq(5)
            end

            it "allows checkin with zero quantity (no change)" do
                result = store.checkin(item_1, 0)

                expect(result).to be(true)
                expect(store.items[item_1].quantity).to eq(2)
            end

            it "doesn't allow negative checkin" do
                result = store.checkin(item_1, -1)

                expect(result).to be(false)
                expect(store.items[item_1].quantity).to eq(2)
            end
        end

        context "when the item does not exist" do
            let(:nonexistent) { "nonexistent" }

            it "raises an ArgumentError" do
                expect { store.checkin(nonexistent, 5)}
                    .to raise_error(ArgumentError, /Cannot check in #{nonexistent}/)
            end
        end
    end

    describe "#order" do
        before do
            store.register(item_1, price_1, 5)
            store.register(item_2, price_2, 2)
        end

        context "when the item does not exist" do
            let(:nonexistent) { "nonexistent" }
            let(:person_1) { "bob" }

            it "returns false and creates a customer with no orders" do
                result = store.order(person_1, nonexistent, 1)

                expect(result).to be false
                expect(store.customers).to have_key(person_1)
    
                customer = store.customers[person_1]

                expect(customer).to be_a(Customer)
                expect(customer.no_orders?).to be true
            end
        end

        context "when there is insufficient stock" do
            let(:alice) { "alice" }
            it "returns false, does not deduct stock, but still creates customer" do
                expect(store.items[item_2].quantity).to eq(2)

                result = store.order(alice, item_2, 3)

                expect(result).to be false
                expect(store.items[item_2].quantity).to eq(2)
                expect(store.customers).to have_key(alice)
                expect(store.customers[alice].no_orders?).to be(true)
            end
        end

        context "when there is sufficient stock" do
            let(:carol) { "carol" }
            it "returns true, deducts stock, and records the order in customer history" do
                expect(store.items[item_1].quantity).to eq(5)
                expect(store.customers).not_to have_key(carol)

                result = store.order(carol, item_1, 2)
                expect(result).to be(true)

                expect(store.items[item_1].quantity).to eq(3)

                expect(store.customers).to have_key(carol)
                customer = store.customers[carol]
                expect(customer.no_orders?).to be false

                orders_for_mug = customer.order_history[item_1]
                expect(orders_for_mug).to be_an(Array)
                expect(orders_for_mug.size).to eq(1)
            end
        end

        context "multiple orders by same customer and different items" do
            let(:dan) { "dan" }
            before do
                store.order(dan, item_1, 1)
                store.order(dan, item_2, 1)
                store.order(dan, item_1, 2)
            end

            it "accumulates multiple orders in the customer's order_history" do
                customer = store.customers[dan]

                expect(customer.order_history[item_1].size).to eq(2)
                expect(customer.order_history[item_2].size).to eq(1)
            end

            it "deducts stock correctly across multiple orders" do
                expect(store.items[item_1].quantity).to eq(2)
                expect(store.items[item_2].quantity).to eq(1) 
            end
        end
    end

    describe "#generate_report" do
        before do
            store.register(item_2, "1.00", 10)
            store.register(item_1, "3.00", 5)

            store.order("emma", item_2, 20)

            store.order("frank", item_2, 2)
            store.order("frank", item_1, 1)
        end

        it "returns an array of report lines" do
            report = store.generate_report
            expect(report).to be_an(Array)
            expect(report.size).to eq(2)
        end

        it "reports 'n/a' for customers with no successful orders" do
            report = store.generate_report
            emma_line = report.find { |line| line.start_with?("emma:") }
            expect(emma_line).to include("n/a")
            expect(emma_line).to eq("emma: n/a")
        end

        it "reports item spending and average spend for customers with orders" do
            report = store.generate_report
            frank_line = report.find { |line| line.start_with?("frank:") }

            expect(frank_line).to include("#{item_2} - $2.00")
            expect(frank_line).to include("#{item_1} - $3.00")
            expect(frank_line).to include("Average Order Value: $2.50")
        end
    end
end
