#!/usr/bin/ruby

@DAY = 5
@MODE = ARGV.shift
@PART = ARGV.shift
@DEBUG = false

def parse()

  fname = "data/#{@DAY}_#{@MODE}_A.data" #always A for today
  content = File.open(fname).readlines
  content.each do |line|
    puts line if @DEBUG
  end
end


parse()
puts "Parsed!"
xxx = process()

puts "SEEDS: [#{@SEEDS}]"
puts "PART #{@PART}: Closest Location: [#{closest}]"
