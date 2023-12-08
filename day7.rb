#!/usr/bin/ruby

@DAY = 7
@MODE = ARGV.shift
$PART = ARGV.shift
die unless @MODE
die unless $PART
$DEBUG = true

$HANDS = []

class Hand
  include Comparable
  CARDS = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "T", "J", "Q", "K", "A"]
  CARDSJOKERSUX = ["J", "1", "2", "3", "4", "5", "6", "7", "8", "9", "T", "Q", "K", "A"]
  RANK2DESC = { 7=>"5OfAKind", 6=>"4OfAKind", 5=>"FullHouse", 4=>"3OfAKind", 3=>"2Pair", 2=>"Pair", 1=>"Hi" }
  attr :initial
  attr :initialHand
  attr :hand
  attr :bid
  attr :rank
  attr :desc

  def initialize(hand, bid)
    @initial = hand
    @initialHand = hand.split("")

    @hand = hand.split("")
    @bid = bid.to_i

    if ($PART == "B")
      if @hand.include?("J") #only if  has a joker
        puts "JOKERIFY --> Hand was: [#{self}] Desc was: [#{self.getDesc}]"
        if self.getRank == 7 #5OfAKind
          other = "A"   #promote to A
        elsif self.getRank == 6  #4OfAKind --> 5 of a kind
          other = (@hand.uniq() - ["J"]).first
        elsif self.getRank == 5 #full house -> 4 of a kind or 5 of a kind
          if @hand.count("J") == 3    #replace jokers with the trip
            other = (@hand.uniq() - ["J"]).first
          elsif @hand.count("J") == 2 #replace jokers with pair card
            other = (@hand-["J"]).first
          else
            raise "WTF"
          end
        #3 of a kind. other two must be different (or be a full house) so --> 4 of a kind
        elsif self.getRank == 4 #3 of a kind (always --> 4 of a kind)
          if @hand.count("J") == 3 #replace joker with first non-Joker card
            # counts = Hash[(@hand).group_by { |x| x }.map { |k, v| [k, v.length] }]
            other = @hand.find{|_| _ != "J"}
          else
            #remove J, count, get the card with 1 count
            other = Hash[(@hand-["J"]).group_by { |x| x }.map { |k, v| [v.length,k] }][3]
          end
        elsif self.getRank == 3 #2 pair
          if @hand.count("J") == 1 #single joker
            #replace the joker with the highest non-joker card
            other = (CARDS-["J"]).reverse.find{|c| hand.include?(c) }
          else
            #remove J, count, per above, but map will smash {count=>rank} and just one of them
            other = Hash[(@hand-["J"]).group_by { |x| x }.map { |k, v| [v.length,k] }][2]
          end
        elsif self.getRank == 2 # 1 pair
          if @hand.count("J") == 2
            #replace the joker with the highest non-Joker card
            other = (CARDS-["J"]).reverse.find{|c| hand.include?(c) }
          else
            #remove J, count, per above, get card that is the pair
            other = Hash[(@hand-["J"]).group_by { |x| x }.map { |k, v| [v.length,k] }][2]
          end
        elsif self.getRank == 1 # high card
          #replace the joker with the highest non-Joker card
          other = (CARDS-["J"]).reverse.find{|c| hand.include?(c) }
        else
          throw "WTF?"
        end
        raise "WTF" if other.nil?
        puts "\tBest replacement is: [#{other}]" if $DEBUG
        @hand = self.jokerify(@hand, other)

        raise "WTF" if @hand.include?("J")

        @rank = nil
        @desc = nil
        puts "JOKERIFY <-- Hand is: [#{self}] Desc is: [#{self.getDesc}]"
      end
    end
  end

  def jokerify(handArr, repCard)
    handArr.map!{|_|
          # puts "\tJokerify [#{_}] [#{repCard}]" if $DEBUG
          _ == "J" ? repCard : _
        }
  end

  def <=>(other)
    puts "in <=>, me: [#{@initialHand}], them [#{other.initialHand}]"  if $DEBUG
    puts "\tme rank: [#{self.getRank}][#{self.getDesc}] them rank: [#{other.getRank}][#{other.getDesc}]"  if $DEBUG
    if @initialHand == other.initialHand
      puts "\t\tme is equal" if $DEBUG
      return 0
    elsif self.getRank > other.getRank
      puts "\t\tme is higher" if $DEBUG
      return 1
    elsif self.getRank < other.getRank
      puts "\t\tme is lower" if $DEBUG
      return -1
    else
      @initialHand.each_with_index{|c,i|
        puts "\tworking on card at pos [#{i}] which is [#{@initialHand[i]}] vs [#{other.initialHand[i]}]" if $DEBUG
        if @initialHand[i] == other.initialHand[i]
          next
        end
        if $PART == "A"
          meRank = CARDS.find_index(@initialHand[i])
          themRank = CARDS.find_index(other.hand[i])
        else # $PART == "B"
          meRank = CARDSJOKERSUX.find_index(@initialHand[i])
          themRank = CARDSJOKERSUX.find_index(other.initialHand[i])
        end
        res = meRank <=> themRank
        puts "\t\tCard: meRank / themRank: [#{meRank}] <=> [#{themRank}] is [#{res}]" if $DEBUG
        return res
      }
    end
  end

  def getRank
    return @rank unless @rank.nil?
    puts "getRank calcing"
    puts "Initial:[#{@initialHand}] considered: [#{@hand}]"
    if @hand.uniq.count == 1
      @rank = 7 #"5OfKind"
    elsif @hand.uniq.count == 2 # 4/1 or 3/2,
      if [3,2].include?(@hand.count(@hand[0]))
        @rank = 5 #"FullHouse"
      else
        @rank = 6 #"4OfAKind"
      end
    elsif @hand.uniq.count == 3
      if @hand.count(@hand[0]) == 3 || @hand.count(@hand[1]) == 3 || @hand.count(@hand[2]) == 3
        @rank = 4 #"3ofAKind"
      else
        @rank = 3 #"2Pair"
      end
    elsif @hand.uniq.count == 4
      @rank = 2 #"Pair"
    else
      @rank = 1 #"Hi"
    end
    return @rank
  end

  def getDesc
    return RANK2DESC[getRank()]
  end

  def inspect
    [@hand.join(), @bid]
  end

  def to_s
    @hand.join()
    # "H:[#{@hand}], B:[#{@bid}]"
  end
end

def parse()
  fname = "data/#{@DAY}_#{@MODE}_A.data" #always A for today
  content = File.open(fname).readlines
  content.each do |line|
    (hand, bid) = line.split()
    $HANDS  << Hand.new(hand, bid)
    # puts line if $DEBUG
  end
end

def process()
  winnings = 0
  $HANDS.sort.each_with_index{|hand, idx|
    winnings += hand.bid * (idx+1)
  }
  winnings
end

parse()
puts "Parsed!"
puts "Hands: [[[\n#{$HANDS}\n]]]" if $DEBUG
puts "---\nSorted Hands: [[[\n#{$HANDS.sort!}\n]]]" if $DEBUG
# puts @HANDS.sort!
winnings = process()

puts "Winnings: [#{winnings}]"

doTests = true

if doTests and $PART == "A" #tests
  tests = {
    "AAAA" => "5OfAKind",
    "QQQQQ" => "5OfAKind",
    "99999" => "5OfAKind",
    "AAAAJ" => "4OfAKind",
    "AJAAA" => "4OfAKind",
    "JAAAA" => "4OfAKind",
    "AAAJJ" => "FullHouse",
    "AAJAJ" => "FullHouse",
    "KJKJK" => "FullHouse",
    "AAA7J" => "3OfAAKind",
    "AJAKA" => "3OfAAKind",
    "JAA7A" => "3OfAAKind",
    "AATTJ" => "2Pair",
    "AJTAJ" => "2Pair",
    "JATAJ" => "2Pair",
    "AAKQJ" => "Pair",
    "AKQAJ" => "Pair",
    "AKQJA" => "Pair",
    "AKQJT" => "Hi",
    "12345" => "Hi",
    "1QKTA" => "Hi",
  }
  tests.each{|th,tr|
    th = Hand.new(th,1)
    puts "Hand [#{th}] is [#{th.getDesc}], should be [#{tr}] and is? [#{th.getDesc == tr}]"
    puts "#{th.hand}"
  }

  tests = [

    ["32T3K", "T55J5", "32T3K"],
    ["T55J5", "KK677", "KK677"],
    ["KK677", "KTJJT", "KTJJT"],
    ["KTJJT", "QQQJA", "KTJJT"],
    # ["", "", ""],
    # ["", "", ""],
  ]
  tests.each{|t|
    first = [Hand.new(t[0],1), Hand.new(t[1],1)].sort.first
    puts "Comparing [#{t[0]}] to [#{t[1]}] hoping [#{t[2]}] is higher"
    raise "FAIL" unless first.hand.join() == t[2]
  }
end #tests

if doTests and $PART == "B" #tests
  jokerifyTests = [
    # five jokers to aces
    ["JJJJJ", "AAAAA"],
    #four of kind to 5 of kind
    ["AAAJA", "AAAAA"],
    ["JAAAA", "AAAAA"],
    ["AAAAJ", "AAAAA"],
    # full house to 5 of kind
    ["AAAJJ", "AAAAA"],
    ["QQQJJ", "QQQQQ"],
    ["JJAAA", "AAAAA"],
    ["AJAJA", "AAAAA"],
    ["JAJAA", "AAAAA"],
    ["JJQQQ", "QQQQQ"],
    # dont touch some things
    ["QQKKK", "QQKKK"],
    ["QQQKK", "QQQKK"],
    # 3 of a kind to 4 of a kind
    ["AAAJT", "AAAJT"],
    ["AAATJ", "AAATA"],
    ["AJATA", "AAATA"],
    ["TAAAJ", "TAAAA"],
    ["JAAAT", "AAAAT"],
    # 3 of a kind with trip J
    ["JJJQQ", "QQQQQ"],
    ["J7J7J", "77777"],
    # 2 pair, one pair is jokers, make 4 of a kind
    ["KKJJ7", "KKKK7"],
    ["JKJK7", "KKKK7"],
    ["7JKJK", "7KKKK"],
    ["77JJQ", "7777Q"],
    ["77JJA", "7777A"],

    # 2 pair odd J, pairs in "order"
    ["77QQJ", "77QQQ"],

    # 2 pair goes to 3 of a kind, preferentially replace highest value card
    ["KKJTT", "KKKTT"],
    ["KTJTK", "KTKTK"],
    #1 pair goes to 3 of a kind
    ["KKJT9", "KKKT9"],
    ["K3JK9", "K3KK9"],
    ["JK3K9", "KK3K9"],
    # 1 pair of jokers
    ["JAKJ7", "AAKA7"],
    #high
    ["1J234", "14234"],
    ["1234J", "12344"],

    ["J345A", "A345A"],
  ]
  jokerifyTests.each{|jt|
    (act, eff) = jt
    hand = Hand.new(act,1)
    desired = Hand.new(eff,1)
    puts "Hand [#{act}] should look like [#{eff}] and does look like [#{hand}] and does? [#{hand == desired}]"
    raise "TEST FAIL" unless hand.hand == desired.hand
  }


  # ordering tests
  tests = [

    ["32T3K", "T55J5", "T55J5"],
    ["T55J5", "KK677", "T55J5"],
    ["KK677", "KTJJT", "KTJJT"],
    ["KTJJT", "QQQJA", "KTJJT"],
    ["2345A", "J345A", "J345A"], #1/2
    ["J345A", "2345J", "2345J"], #2/3
    ["2345J", "32T3K", "32T3K"], #3/5
    ["32T3K", "KK677", "KK677"], #5/7
    ["32T3K", "J345A", "32T3K"], #5/2
    # ["", "", ""],
    # ["", "", ""],
    ]
    tests.each{|t|
      puts "---"
      h0 = Hand.new(t[0],1)
      h1 = Hand.new(t[1],1)
      best = [h0,h1].sort.last
      puts "Comparing [#{t[0]}](read as [#{h0}]) to [#{t[1]}](read as [#{h1}]) hoping highest is [#{t[2]}]"
      puts "\t[#{best.initial}] == [#{t[2]}]??"
      raise "FAIL" unless best.initial == t[2]
    }
end

#250373231
#250374205
#250345431
#250374205
#250385544

fname = "out/#{@DAY}_#{@MODE}_#{$PART}.out" #always A for today
File.open(fname, 'w+') do |fo|
  $HANDS.sort.each{|h|
    fo.puts "#{h.initial} #{h.bid}"
  }
end
