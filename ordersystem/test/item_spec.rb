require 'rspec'
require 'money'
require 'monetize'
require_relative '../item'

RSpec.describe Item do
    let(:name) { "Hairbrush" }
    let(:price) { "$2.50" }
    let(:quantity) { 10 }
    let(:item) { Item.new(name, price, quantity) }

    describe "#initialize" do
        context "when given valid args" do
            it "sets name, price, quantity correctly" do
                expect(item.name).to eq(name)
                expect(item.price).to be_a(Money)
                expect(item.price.cents).to eq(250)
                expect(item.price.currency.iso_code).to eq("USD")
                expect(item.quantity).to eq(10)
            end
        end
    end

    describe "#add_stock" do
        it "increases quantity by the given amount" do
            expect { item.add_stock(5) }.to change { item.quantity }.from(10).to(15)
        end

        it "works when adding zero stock (no change)" do
            expect { item.add_stock(0) }.not_to change { item.quantity }
        end

        context "when trying to add negative quantities" do
            it "doesn't work" do
                expect { item.add_stock(-3) }.not_to change { item.quantity }
            end

            it "doesn't work when adding negative quantities greater than available" do
                expect { item.add_stock(-30) }.not_to change { item.quantity }
            end
        end
    end

    describe "#enough_stock?" do
        context "when requested quantity is greater than or equal to available stock" do
            it "returns true" do
                expect(item.enough_stock?(5)).to be true
                expect(item.enough_stock?(10)).to be true
            end
        end

        context "when requested quantity is less than to available stock" do
            it "returns false" do
                expect(item.enough_stock?(15)).to be false
            end
        end

        it "returns false when 0 quantity input" do
            expect(item.enough_stock?(0)).to be false
        end

    end

  describe "#remove_stock" do
    it "decreases quantity by the given amount" do
      expect { item.remove_stock(4) }.to change { item.quantity }.from(10).to(6)
    end

    it "allows removing exactly all available stock" do
      expect { item.remove_stock(10) }.to change { item.quantity }.from(10).to(0)
    end

    it "allows negative removal (increases stock)" do
      expect { item.remove_stock(-2) }.not_to change { item.quantity }
    end
  end

  context "multiple add and remove stock" do
    it "correctly handles a sequence of add and remove operations" do
      expect(item.quantity).to eq(10)

      item.add_stock(5)
      expect(item.quantity).to eq(15)

      item.remove_stock(7)
      expect(item.quantity).to eq(8)

      expect(item.enough_stock?(8)).to be true
      expect(item.enough_stock?(9)).to be false

      item.add_stock(2)
      expect(item.quantity).to eq(10)

      item.remove_stock(10)
      expect(item.quantity).to eq(0)
      expect(item.enough_stock?(1)).to be false
      expect(item.enough_stock?(0)).to be false
    end
  end
end
