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
  puts "Ghosts: [#{$ghosts}]" if $DEBUG
  puts "ghostCount: [#{ghostCount}]" if $DEBUG

  while true
    count += 1
    dirIdx = count%($cycle.count)
    doneCnt = 0
    $ghosts.each{|ghost,deets|
      doneCnt +=1 if deets.key?("loopSize")
    }

    puts "Ghosts with loopSize: [#{doneCnt}], ghostCount: [#{ghostCount}]" if $DEBUG
    break if doneCnt == ghostCount

    dir = $cycle[dirIdx]

    $ghosts.each{|ghost, deets|
      target = $nodes[deets["curNode"]][dir]
      puts "Ghost [#{ghost}] is at: [#{deets["curNode"]}], going [#{dir}], which is to: [#{target}]" if $DEBUG
      deets["curNode"] = target
      deets["path"] << deets["curNode"]

      if deets["curNode"][2]=="Z"
        puts "END OF THIS LOOP" if $DEBUG
        puts "path so far: [#{deets["path"]}]" if $DEBUG
        deets["loopSize"] = deets["path"].size
      end
    }
  end
  loopSizes = $ghosts.map{|ghost, deets| deets["loopSize"]}
  lcm = loopSizes.reduce(1, :lcm)
  puts "loopSizes: [#{loopSizes}], lcm: [#{lcm}]" if $DEBUG
  lcm
end

parse()
puts "Parsed!"
puts "Cycle: [#{$cycle}]"  if $DEBUG
puts "Nodes: [#{$nodes}]" if $DEBUG
puts "Ghosts: [#{$ghosts}]" if $DEBUG
steps = process()
# puts "[#{$ghosts}]"

puts "PART #{$PART}: Answer: [#{steps}]"
