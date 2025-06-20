require_relative 'store'
require_relative 'command_processor'
require 'money'
require 'monetize'
require 'csv'

# config
Money.default_currency = Money::Currency.new("USD")
Money.rounding_mode = BigDecimal::ROUND_HALF_EVEN
Money.locale_backend = nil
I18n.enforce_available_locales = false

store = Store.new
command_processor = CommandProcessor.new(store)

# STDIN piped
if !STDIN.tty?
    abort "Error: No piped input detected (STDIN was empty)." if ARGF.eof?

    ARGF.each_line do |raw_line|
        line = raw_line.strip
        next if line.empty?
        parts = line.split(' ')

        command_processor.process(parts)
    end
# CSV
elsif ARGV.size >= 1
    filename = ARGV.shift

    abort "Error: File ‘#{filename}’ not found." unless File.exist?(filename)
    abort "Error: Csv file is empty." if File.zero?(filename)

    CSV.foreach(filename, headers: false) do |row|
        parts = row.map { |f| f.to_s.strip }

        next if parts.all?(&:empty?)

        command_processor.process(parts)
    end
else
    puts "Please pipe the file into this program."
    puts "Windows: 'cat .\test\fixtures\good_input.txt | ruby .\program.rb'"
    puts "Linux: 'cat ./test/fixtures/good_input.txt | ruby ./program.rb'"
    puts "Or pass the data in as a CSV."
    puts "Windows: 'ruby .\program.rb .\test\fixtures\good_input.csv'"
    puts "Linux : 'ruby .\program.rb .\test\fixtures\good_input.csv'"
end

puts store.generate_report