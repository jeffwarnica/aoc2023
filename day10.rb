#!/usr/bin/ruby

$DAY = 10
$MODE = ARGV.shift
$PART = ARGV.shift
$DEBUG = false

$map = {}
$distances = {}

def parse()

  fname = "data/#{$DAY}_#{$MODE}_A.data"
  content = File.open(fname).readlines
  content.each_with_index { |line, idx|
    line.chomp!
    $map[idx] = {}
    $distances[idx] = {}
    ents = line.split("")
    ents.each_with_index { |ent, entIdx|
      $map[idx][entIdx] = ent
    }
  }
end

def getNext(pos, path, thatIsnt = nil)
  (posY, posX) = pos
  puts "getNext [#{posY}][#{posX}]" if $DEBUG
  puts "\t that isnt: #{thatIsnt[0]},#{thatIsnt[1]}" if thatIsnt
  dirs = {
    up: {offset: {y:-1, x:0 }, waysOut: ["|", "L", "J", "S"], neededCx:  ["|", "7", "F"]},
    rt: {offset: {y:0,  x:1 }, waysOut: ["-", "L", "F", "S"], neededCx:  ["-", "7", "J"]},
    lt: {offset: {y:0,  x:-1}, waysOut: ["-", "7", "J", "S"], neededCx:  ["|", "L", "F"]},
    dn: {offset: {y:1,  x:0 }, waysOut: ["|", "7", "F", "S"], neededCx:  ["|", "L", "J"]},
  }
  dirs.each{|dir,deets|
    next if $map[posY].nil? || $map[posY][posX].nil?
    mePipe = $map[posY][posX]
    candidateY = posY+deets[:offset][:y]
    candidateX = posX+deets[:offset][:x]
    candidatePos = [candidateY, candidateX]
    puts "Checking from [#{pos}], a [#{mePipe}], to dir [#{dir}], offset: [#{deets[:offset]}], [#{candidatePos}]" if $DEBUG
    next unless $map[candidateY] && $map[candidateY][candidateX]
    next if !thatIsnt.nil? && candidatePos[0] == thatIsnt[0] && candidatePos[1] == thatIsnt[1]
    next if path.include?(candidatePos)
    candidatePipe = $map[candidateY][candidateX]
    puts "\tcandidatePipe: [#{[candidatePipe]}]" if $DEBUG
    if deets[:waysOut].include?(mePipe) &&  deets[:neededCx].include?(candidatePipe)
      puts "\t\t I can leave and enter this way" if $DEBUG
      $distances[candidateY][candidateX] = ($distances[pos[0]][pos[1]] ? $distances[pos[0]][pos[1]] : 0) + 1
      path << candidatePos
      return candidatePos
    end
  }
  return pos
end

def process()
  startY = startX = nil
  $map.each{|y,ys|
    ys.each{|x, cell|
      puts "y, x: [#{y}, #{x}] == [#{cell}]"
      if cell == "S"
        startY = y
        startX = x
        $distances[startY][startX] = 0
      end
    }
  }
  puts "S is at [#{startY},#{startX}]"
  path1_last = [startY, startX]
  path2_last = [startY, startX]
  path1 = [[startY, startX]]
  path2 = [[startY, startX]]

  path1_last = getNext(path1_last, path1)
  path2_last = getNext(path2_last, path2, path1_last)

  while true
    path1_last = getNext(path1_last, path1)
    path2_last = getNext(path2_last, path2)
    drawMap($distances) if $DEBUG
    break if path1_last == path2_last
    puts "Path Lasts XXXX: [#{path1_last}] 2: [#{path2_last}]" if $DEBUG
  end
  return path1_last
end

def drawMap(map)
  for y in (0..map.keys.sort.last)
    for x in (0..map.keys.sort.last)
      ent = map[y][x] ? map[y][x] : "."
      printf("%3s", ent)
    end
    puts " !!"
  end

end

parse()
puts "Parsed!"
puts "[#{$map}]"
drawMap($map)

lastPos = process()
drawMap($distances)

puts "Last position is: [#{lastPos}], which was distance: [#{$distances[lastPos[0]][lastPos[1]]}]"
# puts "PART #{$PART}: Closest Location: [#{closest}]"
