#!/usr/bin/ruby

@DAY = 5
@MODE = ARGV.shift
@PART = ARGV.shift
@DEBUG = false

# @BIG_MAP = {}
@REDIRS = {}
@SEEDS = []

class LocRedir
  @redirMaps = []
  def initialize()
    @redirMaps = []
  end

  def addRedir(ds, ss, l)
    @redirMaps << {dest: ds, source: ss, len: l}
  end

  def getRedir(from)
    puts "getRedir([#{from}])"  if @DEBUG
    doRedir = false
    foundMap = []
    @redirMaps.each{|redir|
      if from >= redir[:source] && from < redir[:source]+redir[:len]
        doRedir = true
        foundMap = redir
      end
    }
    if doRedir
      puts "[#{from}] IN A RANGE. CALC HERE"  if @DEBUG
      offset = from - foundMap[:source]
      destStart = foundMap[:dest]
      dest = destStart+offset
      puts "\tOffset: [#{offset}] from dest start ([#{destStart}]) is [#{dest}]" if @DEBUG
      dest
    else
      puts "[#{from}] OUT OF RANGE. RETURN SAME"  if @DEBUG
      from
    end
  end

  def getSourceOf(destination)
    @redirMaps.each{|redir|
      offset = redir[:dest] - redir[:source]
      # puts "map [#{redir}] has offset of [#{offset}]"
      if destination > redir[:dest] && destination < redir[:dest]+offset
        puts "[#{from}] IN A RANGE. CALC HERE"  if @DEBUG
        source = destination-offset
      else
        source = destination
      end
    }
    # puts ""
    return destination

  end

  def to_s
    rets = []
    @redirMaps.each{|redir|
      rets << "[source: #{redir[:source]} dest: #{redir[:dest]} len: #{redir[:len]}]"
    }
    return rets.join(",")
  end
end #Class


def parse()
  fname = "data/#{@DAY}_#{@MODE}_A.data" #always A for today
  content = File.open(fname).readlines

  for mode in ["s2s", "s2f", "f2w", "w2l", "l2t", "t2h", "h2l"]
    @REDIRS[mode] = LocRedir.new()
    # @BIG_MAP[mode] = {}
    # for i in 0..99 do
    #   @BIG_MAP[mode][i]=i
    # end
  end

  puts "#{@REDIRS}"  if @DEBUG

  mode = "seeds"
  content.each do |line|
    next if line.match(/^#?$/)

    if mode == "seeds"
      if @PART == "1"
        @SEEDS = line.split(":")[1].strip.split()
      elsif @PART == "2"
        seedRanges = line.split(":")[1].scan(/((?:\d+\s\d+)\s)/)
        puts "number of ranges: #{seedRanges.size}"
        seedRanges.each{|rangeStrArr|
          puts "."
          (start,length) = rangeStrArr[0].split(" ")
          start = start.to_i
          length = length.to_i
          rangeEnd = start+length
          # puts "Seed rangeStrArr is [#{rangeStrArr}], from [#{start}], length [#{length}], rangeEnd [#{rangeEnd}]"
          for _ in start..rangeEnd do
            @SEEDS <<  _
          end
        }
      else
        raise "CHOOSE VALID PART, ASSHOLE"
      end
      mode = "s2s"
      next
    else
      if line.match(/seed-to-soil map:/)
        mode = "s2s"
        next
      end
      if line.match(/soil-to-fertilizer map:/)
        mode = "s2f"
        next
      end
      if line.match(/fertilizer-to-water map:/)
        mode = "f2w"
        next
      end
      if line.match(/water-to-light map/)
        mode = "w2l"
        next
      end
      if line.match(/light-to-temperature map:/)
        mode = "l2t"
        next
      end
      if line.match(/temperature-to-humidity map:/)
        mode = "t2h"
        next
      end
      if line.match(/humidity-to-location map:/)
        mode = "h2l"
        next
      end

    end

    puts "3[#{mode}] #{line}" if @DEBUG

    (ds, ss, l) = line.split() #dest start source start
    ds = ds.to_i
    ss = ss.to_i
    l  = l.to_i
    @REDIRS[mode].addRedir(ds, ss, l)

  end
end

def processXX()
  @REDIRS.each{|xl,map|
    puts "#{xl} ==> #{map}"
  }  if @DEBUG
  closest = -1

  @SEEDS.each{|seed|
    seed = seed.to_i
    soilLoc = @REDIRS["s2s"].getRedir(seed)
    fertLoc = @REDIRS["s2f"].getRedir(soilLoc)
    waterLoc = @REDIRS["f2w"].getRedir(fertLoc)
    lightLoc = @REDIRS["w2l"].getRedir(waterLoc)
    tempLoc = @REDIRS["l2t"].getRedir(lightLoc)
    humidityLoc = @REDIRS["t2h"].getRedir(tempLoc)
    location = @REDIRS["h2l"].getRedir(humidityLoc)

    puts "Seed [#{seed}], soil [#{soilLoc}], fertilizer [#{fertLoc}], water [#{waterLoc}], light [#{lightLoc}], temperature [#{tempLoc}], humidity [#{humidityLoc}], location [#{location}]." if @DEBUG

    closest = location if closest == -1 || location < closest
  }
  closest
end

def process()
  found = false
  finalLoc = 1
  while not found do
    prevLoc = finalLoc
    for map in ["s2s", "s2f", "f2w", "w2l", "l2t", "t2h", "h2l"].reverse do
      newPrevLoc = @REDIRS[map].getSourceOf(prevLoc)
      puts "Map [#{map}] takes us backwards from [#{prevLoc}] to [#{newPrevLoc}]"
      prevLoc = newPrevLoc
    end
    puts "End of path got us to LOC: [#{prevLoc}]"
    if @SEEDS.include?(prevLoc)
      puts "FOUND A SEED!!!! finalLoc [#{finalLoc}] tracks to seed [#{prevLoc}]"
      found = true
    end
    finalLoc += 1
  end
  prevLoc
end

parse()
puts "Parsed!"
closest = process()
puts "SEEDS: [#{@SEEDS}]"
puts "PART #{@PART}: Closest Location: [#{closest}]"
