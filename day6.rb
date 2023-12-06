#!/usr/bin/ruby

@DAY = 6
@MODE = ARGV.shift
@PART = ARGV.shift
@DEBUG = false

@RACES = []

def parse()
  parseA() if @PART == "A"
  parseB() if @PART == "B"
end

def parseA()
  fname = "data/#{@DAY}_#{@MODE}_A.data" #always A for today
  content = File.open(fname).readlines

  times = content[0].split(":")[1].split()
  distances = content[1].split(":")[1].split()

  times.each_with_index{|t,i|
    @RACES << [t, distances[i]]
  }
end


def parseB()
  fname = "data/#{@DAY}_#{@MODE}_A.data" #always A for today
  content = File.open(fname).readlines

  times = content[0].split(":")[1]
  distances = content[1].split(":")[1]

  times.gsub!(/[^\d]/, "")
  distances.gsub!(/[^\d]/, "")

  puts "times, distances: [#{times}], [#{distances}]"

  @RACES << [times, distances]
end

def process()
  raceWinnerProduct = 1
  @RACES.each{|race|
    thisRaceWinners = 0
    totalTime = race[0].to_i
    distance = race[1].to_i
    puts "race is time: [#{totalTime}], distance: [#{distance}]" if @DEBUG
    for checkButtonTime in 0...totalTime do
      travelTime = totalTime - checkButtonTime
      testDistance = checkButtonTime*travelTime
      puts "\tButtonTime:[#{checkButtonTime}], travelTime: [#{travelTime}], testDistance is: [#{testDistance}] vs [#{distance}]" if @DEBUG
      thisRaceWinners +=1 if testDistance > distance
    end
    puts "Race alt winners: [#{thisRaceWinners}]" if @DEBUG
    raceWinnerProduct = raceWinnerProduct*thisRaceWinners
  }
  raceWinnerProduct
end

parse()
puts "Parsed!"
# puts "RACES: [#{@RACES}]"
raceWinnerProduct = process()

# puts "SEEDS: [#{@SEEDS}]"
puts "PART #{@PART}: ProductOfWinners: [#{raceWinnerProduct}]"
