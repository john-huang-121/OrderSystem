## Problem Statement

# Code Challenge

We'd like you to write a bit of code. We tried to keep the problem statement minimal so it shouldn't take too much time.

If you have any questions please send us an email. If the problem statement doesn't specify something, you can make any decision that you want. Your code will not be evaluated on its ability to handle anything that wasn't mentioned in the problem statement. You do not need to persist any data to disk.

Please include a README with your submission describing your approach to solving the problem. Do not include your name or any personally identifiable information in your readme.

We're looking for a solution that is representative of code that you would write on a real project, including tests. You can complete this at your convenience — there isn't a specific deadline for it.

You're welcome to use tools like large language models (e.g., ChatGPT) to assist you as you would in a real-world setting. However, the expectation is that these tools are used as a supplement to your own thinking—not to generate the full solution on your behalf.

When finished please upload your code to a secret Gist on Github and send us the link.

## Problem Statement

Lets write some code to track how much customers spent with us and available inventory in our warehouse.

The code will process an input file. You can either choose to accept the input via stdin (e.g. if you're using Ruby cat input.txt | ruby yourcode.rb), or as a file name given on the command line (e.g. ruby yourcode.rb input.txt). You can use any programming language that you want. Please choose a language that allows you to best demonstrate your programming ability.

Each line in the input file will start with a command. There are three possible commands.

The first command is `register`, which will register a product and it's price with our system.

`register hats $20.50`

The second command is `checkin`, which will checkin a quantity of a product into our warehouse.

`checkin hats 100`

The third command is `order`, which will place an order from a customer. It takes a customer name, a product, and a quantity as arguments.

`order kate hats 20`

Ignore any orders for products that either are not in the warehouse or we do not have enough of to fulfill the order.

Please generate a report showing how much each customer spent on each product along with their average order value. An example input and output set is below.

## Example Input

```
register hats $20.50
register socks $3.45
register keychain $5.57
checkin hats 100
order kate hats 20
checkin socks 30
order dan socks 35
order kate socks 10
```

## Example Output

```
Dan: n/a
Kate: hats - $410.00, socks - $34.50 | Average Order Value: $222.25

## Approach

For this problem on maintaining an inventory store, I envisioned the possible touch points for an inventory system as if it's a real production rails project, including realistic libraries that I have worked with that deal with finances and testing. From the problem description I determined that there had to be a Store, Customers, Items, and Orders as the commands listed in the problem (register, checkin, order) translated to creating the item, stocking the item, and selling the item to customers. In order to consume a file of commands, I decided to use a switch case to read the command and the relevant information afterwards. However before I used the terminal to consume the data file, I started off with this as a starting point:
````ruby
input_lines = [
    "register hats $20.50",
    "register socks $3.45",
    "register keychain $5.57",
    "checkin hats 100",
    "order kate hats 20",
    "checkin socks 30",
    "order dan socks 35",
    "order kate socks 10"
]

input_lines.each do |line|
    parts = line.split(' ')
    command = parts[0]

    case command
    when "register"
        _, item_name, price, quantity = parts
        store.register(item_name, price.to_money, quantity.to_i)
    when "checkin"
        _, customer_name, quantity = parts
        store.checkin(customer_name, quantity.to_i)
    when "order"
        _, customer_name, item_name, quantity = parts
        store.order(customer_name, item_name, quantity.to_i)
    end
end
````

I will outline the design and thought process on each file.

#### Tech Used

1. Money gem + Monetize (to deal with precise money calculation. BigDecimal instead of float)
2. Rspec gem (commonly used testing framework for Rails)
3. ChatGpt (Minimal use.)

## `program.rb`

This file is the main entrypoint of the project as the terminal commands are interpreted here. I decided to use the Money gem throughout the project and because warnings were coming up due to deprecation and rounding defaults, I set aside a config section.

Originally I had the entire processing structure in this file, but as the complexity grew, I decided to abstract the processing of data from inputs into a CommandProcessor and mainly focused the logic on allowing both `cat` input and `csv` file input to be processed. This meant that program.rb had to differentiate between teletypes and how files/inputs are fed in. I included a portion that would advise users on the commands to use when unsupported inputs were used.

Finally the store would generate the report.

## `command_processor`

Originally I thought that if the processing of STDIN vs CSV file became more difficult, it would be easier to abstract it away through the Template Method Pattern. Luckily it wasn't too bad, so I kept it small. YAGNI.

```ruby
# class CommandProcessor
#   ...
# end
# class CsvCommandProcessor < CommandProcessor; end
# class StdOutCommandProcessor < CommandProcessor; end
```

## `store.rb`

Here, the store manages its own internal state based upon the commands given to the command processor. I focused on encapsulating each model so that I followed the `tell, dont ask` ideology and have the models manage its own state (ie no items.quantity -= 5). Since this model is the meat of internal state management, I made sure to have guards to ensure accepted inputs and state. As for returning boolean, it could be used upon expansion to check whether a particular method ran correctly.

In the sample output I noticed Dan came before Kate, so I debated whether to sort the customers by alphabetical order. I decided not to as it's not particularly important, but to implement, I would call the `sort` method if necessary.

To improve performance of summation the option to use `money-collection` gem can be found [here](https://github.com/RubyMoney/money-collection)

## `customer.rb`

Mostly consisted of managing its own order history and generating useful calculations and reports. I designed it in a way that if individual item orders by a customer is an interest, a method could be written to index into a particular item.

## `item.rb`

Individual item stock management. Potential combination of `add/remove` into one function, `update_quantity(quantity)`. Enough said.

## `order.rb`

individual customer order details.

## `/test`

Holds all of the rspec files. A particular thing i strove for was to ensure most of test variables are referenced instead of hardcoded (easier to change/fix in future).
```ruby
let(:person_1) { 'dan' }
expect(...).to be(person_1) # not hardcoded
```
I also skipped writing `program_spec.rb` because it'd take too long. I included test files to check error catching in `/test/fixtures`. In a production codebase, I'd write one.

## Thanks for Reading!