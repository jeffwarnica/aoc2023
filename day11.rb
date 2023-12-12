#!/usr/bin/ruby

$DAY = 11
$MODE = ARGV.shift
$PART = ARGV.shift
$DEBUG = true
$initialGalaxy = {}
$galaxies = {}
$expansions = {}
$EXPANSION = 10

def parse()

  fname = "data/#{$DAY}_#{$MODE}_A.data" #always A for today
  content = File.open(fname).readlines
  content.each_with_index do |line, yIdx|
    line.chomp!
    puts line if $DEBUG
    $initialGalaxy[yIdx] = {}
    bits = line.split("")
    bits.each_with_index{|_, xIdx|
    $initialGalaxy[yIdx][xIdx] = _
    }
  end
end

def buildExpansions()
  (0..$initialGalaxy.size-1).each{|y|
    xs = {}
    (0..$initialGalaxy[0].size-1).each{|x|
      xs[x] = 1
    }
    $expansions[y] = xs
  }

  (0..$initialGalaxy.size-1).each{|curY|
    if $initialGalaxy[curY].all?{|k,v| v == "."}
      puts "empty line at [#{curY}]"
      (curY..$initialGalaxy.size-1).each{|addAtY|
        puts "Adding Expansions row [#{addAtY}]"
        (0..$initialGalaxy[addAtY].size-1).each {|xIdx|
          $expansions[addAtY][xIdx] = $expansions[addAtY][xIdx]+1
        }
      }
    end
  }

  addXsAt = []
  (0..$initialGalaxy[0].size-1).each{|curX|
    colContents = []
    (0..$initialGalaxy.size-1).each{|curY|
      colContents << $initialGalaxy[curY][curX]
    }

    if !colContents.include?("#")
      puts "Empty col at: [#{curX}]"
      (curX..$initialGalaxy[0].size-1).each {|newX|
        (0..$initialGalaxy.size-1).each{|newY|
          $expansions[newY][newX] = $expansions[newY][newX].to_i
        }
      }
    end
  }

end

def expand()

  (0..$initialGalaxy.size-1).reverse_each{|curY|
    if $initialGalaxy[curY].all?{|k,v| v == "."}
      puts "empty line at [#{curY}]"
      (curY..$initialGalaxy.size-1).reverse_each{|addAtY|
        puts "Moving line at [#{addAtY}] forward"
        $initialGalaxy[addAtY+1] = $initialGalaxy[addAtY]
        newLine = {}
        (0..$initialGalaxy[curY].size).each {|newLineIdx| newLine[newLineIdx] = "."}
      }
    end
  }
  addXsAt = []
  (0..$initialGalaxy[0].size-1).reverse_each{|curX|
    colContents = []
    (0..$initialGalaxy.size-1).each{|curY|
      colContents << $initialGalaxy[curY][curX]
    }
    puts "Col [#{curX}] is [#{colContents}]"
    if !colContents.include?("#")
      puts "Empty col at: [#{curX}]"
      (curX..$initialGalaxy[0].size-1).reverse_each {|newX|
        puts "Moving col [#{newX}] to right"
        (0..$initialGalaxy.size-1).reverse_each{|newY|
          $initialGalaxy[newY][newX+1] = $initialGalaxy[newY][newX]
        }
      }
    end
  }
end

def printMap(map)
  map.each{|y, line|
    outStr = ""
    line.each{|x, elem| outStr += "#{elem}|"}
    puts outStr
  }
end

def findGalaxies()
  galaxyId = 1
  (0..$initialGalaxy.size-1).each{|y|
    (0..$initialGalaxy[0].size-1).each{|x|
      if $initialGalaxy[y][x] == "#"
        puts "Galaxy at [#{y}][#{x}]"
        # expansion = $expansions[y][x]
        # puts "expansion: [#{expansions}]+[#{x}]"
        # puts "expansion: [#{expansions}]+[#{y}]"
        realY = y #expansion+y
        realX = x #expansion+x
        $galaxies[galaxyId] = {pos: [realY,realX]}
        galaxyId += 1
      end
    }
  }
end

def getPaths()
  highestGalaxy = $galaxies.keys.sort.last
  runningTotal = 0
  $galaxies.each{|g,deets|
    (g+1..highestGalaxy).each{|other|
      puts  "working on [#{g}] to [#{other}], which is [#{deets[:pos][0]}][#{deets[:pos][1]}] to [#{$galaxies[other][:pos][0]}][#{$galaxies[other][:pos][1]}]"
      distance = (deets[:pos][0] - $galaxies[other][:pos][0]).abs + (deets[:pos][1] - $galaxies[other][:pos][1]).abs
      puts "\tDistance: [#{distance}]"
      runningTotal += distance
    }
  }
  runningTotal
end

parse()
puts "Parsed!"
# puts "#{$initialGalaxy}"
printMap($initialGalaxy)

expand()

# buildExpansions()
# puts "===== Expansions: ====="
# printMap($expansions)
# puts "===== /Expansions: ====="

# puts "#{$initialGalaxy}"
printMap($initialGalaxy)
findGalaxies()
distanceSum = getPaths()
puts "[#{$galaxies}]"
puts "distanceSum: [#{distanceSum}]"
# xxx = process()

# puts "SEEDS: [#{$SEEDS}]"
# puts "PART #{$PART}: Closest Location: [#{closest}]"


#TEST A: 374
#REAL A: 9681886
