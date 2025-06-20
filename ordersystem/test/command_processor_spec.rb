# spec/command_processor_spec.rb
require 'rspec'
require 'money'
require 'monetize'

require_relative '../command_processor'
require_relative '../item'
require_relative '../order'
require_relative '../customer'
require_relative '../store'

RSpec.describe CommandProcessor do
    before(:all) do
        Money.default_currency = Money::Currency.new("USD")
        Money.rounding_mode   = BigDecimal::ROUND_HALF_EVEN
        Money.locale_backend  = nil
        I18n.enforce_available_locales = false
    end

    let(:store_double) { instance_double("Store") }
    let(:processor) { CommandProcessor.new(store_double) }
    let(:register) { "register" }
    let(:checkin) { "checkin" }
    let(:order) { "order" }
    let(:item_1) { "roller" }
    let(:price_1) { "$12.34" }
    let(:person_1) { "alice" }

    describe "#initialize" do
        it "stores the provided store object" do
            expect(processor.store).to eq(store_double)
        end
    end

    describe "#process" do
        context "when command is 'register'" do
            it "calls store.register with item_name, price as Money, and quantity as integer" do
                fields = [register, item_1, price_1, "5"]

                money_price = price_1.to_money
    
                expect(store_double).to receive(:register).with(item_1, money_price, 5)
                processor.process(fields)
            end
        end

        context "when command is 'checkin'" do
            it "calls store.checkin with customer_name (actually item_name) and quantity as integer" do
                fields = [checkin, item_1, "7"]

                expect(store_double).to receive(:checkin).with(item_1, 7)
                processor.process(fields)
            end
        end

        context "when command is 'order'" do
            it "calls store.order with customer_name, item_name, and quantity as integer" do
                fields = [order, person_1, item_1, "3"]

                expect(store_double).to receive(:order).with(person_1, item_1, 3)
                processor.process(fields)
            end
        end

        context "when command is unrecognized" do
            it "warns and does not call any store method" do
            fields = ["unknown", person_1, price_1]

            expect(store_double).not_to receive(:register)
            expect(store_double).not_to receive(:checkin)
            expect(store_double).not_to receive(:order)

            expect { processor.process(fields) }.to output(/Skipping unrecognized commmand: unknown/).to_stderr
            end
        end
    end

    describe "#generate_report" do
        it "delegates to store.generate_report and returns its result" do
            fake_report = ["alice: n/a", "bob: widget - $5.00 | Average Order Value: $5.00"]

            expect(store_double).to receive(:generate_report).and_return(fake_report)
            expect(processor.generate_report).to eq(fake_report)
        end
    end
end
