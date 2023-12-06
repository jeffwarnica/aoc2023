#!/usr/bin/ruby

@DAY = 5
@MODE = ARGV.shift
@PART = ARGV.shift
@DEBUG = true

@BIG_MAP = {}
fname = "data/#{@DAY}_#{@MODE}_#{@PART}.data"
content = File.open(fname).readlines

for mode in ["s2s", "s2f", "f2w", "w2l", "l2t", "t2h", "h2l"]
  @BIG_MAP[mode] = {}
  for i in 0..99 do
    @BIG_MAP[mode][i]=i
  end
end

mode = "seeds"
content.each do |line|
  next if line.match(/^#?$/)
  puts "1[#{mode}] #{line}" if @DEBUG

  if mode == "seeds"
    @SEEDS = line.split(":")[1].strip.split()
    mode = "s2s"
    next
  else
    puts "2[#{mode}] HERE"
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
  puts "DS: [#{ds}], SS:[#{ss}], l:[#{l}]"

  for i in 0..l-1 do
    #puts "setting src [#{ss+i}] to [#{ds+i}]" if @DEBUG
    @BIG_MAP[mode][ss+i]=ds+i
  end

end

@BIG_MAP.each{|xl,map|
  puts "#{xl} ==> #{map}"
}
# puts "#{@BIG_MAP}"
# lowest = 99
closest = -1

@SEEDS.each{|seed|
  seed = seed.to_i
  puts "SEED: [#{seed}]"
  soilLoc = @BIG_MAP["s2s"][seed]
  fertLoc = @BIG_MAP["s2f"][soilLoc]
  waterLoc = @BIG_MAP["f2w"][fertLoc]
  lightLoc = @BIG_MAP["w2l"][waterLoc]
  tempLoc = @BIG_MAP["l2t"][lightLoc]
  humidityLoc = @BIG_MAP["t2h"][tempLoc]
  location = @BIG_MAP["h2l"][humidityLoc]
  puts "Seed [#{seed}], soil [#{soilLoc}], fertilizer [#{fertLoc}], water [#{waterLoc}], light [#{lightLoc}], temperature [#{tempLoc}], humidity [#{humidityLoc}], location [#{location}]."

  closest = location if closest == -1 || location < closest
}

puts "PART 1: Closest Location: [#{closest}]"
