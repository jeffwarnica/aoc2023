#!/usr/bin/ruby

$DAY = 8
$MODE = ARGV.shift
$PART = ARGV.shift
$DEBUG = false
$cycle = []
$nodes = {}

$ghosts = {}

def parse()

  fname = "data/#{$DAY}_#{$MODE}_#{$PART}.data"
  content = File.open(fname).readlines

  content.each_with_index do |line, idx|
    line.chomp!
    if idx == 1
      next
    elsif idx == 0
      $cycle = line.split("")
      next
    end
    matches = line.match(/(\w\w\w) = \((\w\w\w), (\w\w\w)/)
    $nodes[matches[1]] = {"L" => matches[2], "R" => matches[3]}
    # $first = matches[1] if $first.nil?
  end
end

def process()
  if $PART == "A"
    $first = "AAA"
    $ghosts["AAA"] = {"first" => "AAA", "path" => []}
  elsif $PART == "B"
    $nodes.each{|node, dirs|
      puts "NODE: [#{node}] can go to: [#{dirs}]" if $DEBUG
      if node[2] == "A"
        puts "\tGhost node!" if $DEBUG
        $ghosts[node] = {"first" => node, "path" => []}
      end
    }
  else
    raise "WTF"
  end

  count = -1
  $ghosts.each{|ghost, deets|
    $ghosts[ghost]["curNode"] = deets["first"]
  }
  ghostCount = $ghosts.count
  puts "Ghosts: [#{$ghosts}]"
  puts "ghostCount: [#{ghostCount}]"

  while true
    count += 1
    dirIdx = count%($cycle.count)
    foundCnt = 0
    $ghosts.each{|ghost,deets|
      foundCnt +=1 if deets["curNode"][2]=="Z"
    }

    puts "Ghosts at 'Z' count: [#{foundCnt}], ghostCount: [#{ghostCount}]" if $DEBUG
    break if foundCnt == ghostCount

    dir = $cycle[dirIdx]

    $ghosts.each{|ghost, deets|
      # deets["path"] << deets["curNode"]
      target = $nodes[deets["curNode"]][dir]
      puts "Ghost [#{ghost}] is at: [#{deets["curNode"]}], going [#{dir}], which is to: [#{target}]" if $DEBUG
      deets["curNode"] = target
    }
  end
  count
end


parse()
puts "Parsed!"
puts "Cycle: [#{$cycle}]"
puts "Nodes: [#{$nodes}]"
puts "Ghosts: [#{$ghosts}]"
steps = process()
puts "[#{$ghosts}]"

puts "PART #{$PART}: Steps: [#{steps}]"
