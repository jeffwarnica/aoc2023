#!/usr/bin/ruby

$DAY = 9
$MODE = ARGV.shift
$PART = ARGV.shift
$DEBUG = false
$histories = []

def parse()
  fname = "data/#{$DAY}_#{$MODE}_A.data" #always A for today
  content = File.open(fname).readlines
  content.each do |line|
    line.chomp!
    # puts line if $DEBUG
    gen0 = line.split(/\s/)
    gen0.map!{|v| v = v.to_i}
    $histories << { "gen" => {0 => gen0} }
  end
end

def addNextGen(hist, genLevel)
  thisGen = hist["gen"][genLevel]
  puts "addGen to hist at genLevel: [#{genLevel}] which is [#{thisGen}]" if $DEBUG
  return if thisGen.uniq.count == 1 && thisGen.uniq[0] == 0
  nextGen = []
  for i in (0..thisGen.count-2)
    nextGen << thisGen[i+1] - thisGen[i].to_i
  end
  hist["gen"][genLevel+1] = nextGen
  addNextGen(hist, genLevel+1)
end

def addNewValues(hist)
  incVal = 0
  for genLev in (0..hist["gen"].keys.sort.reverse.first).to_a.reverse do
    valIdx = $PART == "A" ? -1 : 0
    val = hist["gen"][genLev][valIdx]

    incVal = -incVal if $PART == "B"

    newVal = val + incVal
    puts "\tworking on genLev: [#{genLev}], incVal: [#{incVal}] which is: [#{hist["gen"][genLev]}], last val is [#{lastVal}], adding to array [#{newLastVal}]" if $DEBUG
    if $PART == "A"
      hist["gen"][genLev] << newVal
    elsif $PART == "B"
      hist["gen"][genLev].unshift(newVal)
    else
      raise "WTF"
    end
    puts "\t\tGiving: [#{hist["gen"][genLev]}]}" if $DEBUG
    incVal = newVal
  end
end

def process()
  $histories.each{|hist|
    addNextGen(hist, 0)
  }
  printHistories
  $histories.each{|hist|
    addNewValues(hist)
  }
  runningTotal = 0
  $histories.each{|hist|
    valIdx = $PART == "A" ? -1 : 0
    runningTotal += hist["gen"][0][valIdx]
  }
  runningTotal
end

def printHistories
  puts "----- printHistories -----"
  $histories.each{|h| printHistory(h)}
end

def printHistory(hist)
  hist["gen"].each{|genLevel, gen|
    puts "[#{genLevel}]" + ("\t" * genLevel) + "#{gen}"
  }
end

parse()
puts "Parsed!"
puts "[#{$histories}]"

total = process()

printHistories


puts "PART #{$PART}: total: [#{total}]"
