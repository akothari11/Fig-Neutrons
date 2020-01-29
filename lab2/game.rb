require_relative 'deck'

class Game < Array
  def initialize
    @deck = Deck.new
    @draw_pile = @deck.cards
    @board = @draw_pile.shift(12)
    @score = 0
    @quit = false
  end

  # returns the size of the board.  The board will only be less than 12 when the draw pile is empty.
  def cards_left
    @board.length
  end

  # starts a round.
  def deal
    check_matches
    return if @quit
    @deck.print_cards @board
    next_move
  end

  # makes sure that there is at least one match on the board.
  def check_matches
    return unless find_matches.empty?

    all_cards_left = @board + @draw_pile
    if find_matches(all_cards_left).length.zero?
      puts 'There are no more matches in the whole deck!'
      game_over
    else
      swap_three
    end
  end

  # finds all of the matches on the board and returns an array of them.  Could be used to give another hint.
  def find_matches(cards = @board)
    cards.combination(3).to_a.select { |group| a_set? group }
  end

  # after printing the board, asks what the player would like to do.
  def next_move
    ask_question
    answer = gets.to_i
    until answer.between?(1, 4)
      print 'Try again. Choose 1, 2, 3 or 4:'
      answer = gets.to_i
    end
    find_a_set if answer == 1
    give_hint if answer == 2
    @board.shuffle! if answer == 3
    game_over if answer == 4
  end

  # separating the text to make the next_move method shorter
  def ask_question
    puts 'What would you like to do?'
    puts '1. Pick a set.'
    puts '2. Get a hint: How many matches are there?'
    puts '3. Shuffle the board.'
    puts '4. End Game'
    print 'Choose 1, 2, 3 or 4:'
  end

  # steps for player to select three cards and check if it is a set
  def find_a_set
    puts ''
    cards = pick_a_set
    if a_set? cards
      @board.reject! { |c| cards.include?(c) }
      three_more unless @draw_pile.length.zero?
      up_score
    else
      try_again
    end
  end

  # player picking three cards
  def pick_a_set
    cards = []
    (1..3).each do |i|
      print "Choose card #{i}:"
      answer = gets.to_i
      until answer.between?(1, @board.length) && !cards.include?(@board[answer - 1])
        puts "Try again! Choose card #{i}:"
        answer = gets.to_i
      end
      cards << @board[answer - 1]
    end
    cards
  end

  # determining if the three cards are a set
  def a_set?(three_cards)
    cardStrings = []
    for i in 0..2 do
      cardStrings[i] = (three_cards[i])[4..10]
      three_cards[i] = (three_cards[i])[0..3]
    end
    bool = three_cards.transpose.all? { |feature| feature.length == 3 && feature.uniq.length != 2 }
    for i in 0..2 do
      (three_cards[i])[4..10] = cardStrings[i]
    end
    return bool
  end

  # drawing three cards from the draw pile and adding them to the board
  def three_more
    3.times { @board << @draw_pile.shift(1).flatten}
  end

  # response after selecting a correct set
  def up_score
    @score += 2
    puts "\nGreat Job!"
    puts "Your Score is now #{@score}, and there are #{@draw_pile.length} cards left in the draw pile."
  end

  # response after selecting an incorrect set
  def try_again
    @score -= 1
    puts 'Wrong! Try again!'
    puts "Your Score is now #{@score}!"
  end

  # response after asking for a hint.  Gives the number of hints on the board.
  # Could be changed to give one card that is included in a set or something.
  def give_hint
    @score -= 1
    matches = find_matches.length
    @deck.print_cards @board
    puts "\nThere #{matches == 1 ? 'is 1 match' : "are #{matches} matches"}."
    puts ''
    next_move
  end

  # response when game is over, either because there are no more matches
  # or the player ends the game
  def game_over
    puts "\nYour final score is #{@score}"
    puts 'Thanks for playing!!'
    puts 'Goodbye!!'
    @quit = true
  end

  # swapping the last three cards on the board for new cards from the draw pile
  # so that there is at least one match on the board
  def swap_three
    swap = @board.pop(3)
    three_more
    3.times { @draw_pile << swap.shift(1).flatten }
    @draw_pile.shuffle!
  end

  # boolean keeping track of the player wanting to quit the game.
  def over?
    @quit
  end

  # option to shorten the game, using to test how the game ends.
  # Parameter is the number of cards to take out of the draw pile. 0-69
  def shorten_game(number)
    @draw_pile.shift(number)
  end

end
