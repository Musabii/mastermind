# frozen_string_literal: true

# this is the class for game
class Game
  private

  def initialize
    @default_colors = %w[red blue black white yellow green]
    @players = Players.new
    @board = Board.new
    @colors_amount = @players.codebreaker == 'AI' ? 4 : ask_colors
    colors
    @guesses_left = 13
    play_round
  end

  def choose_colors
    puts @default_colors.join(', ')
    puts "Mastermind, Please pick #{@colors_amount} colors from colors list you want the other person to guess!"
    input_colors
  end

  def input_colors
    input = gets.chomp.split
    input.length == @colors_amount && check_colors(input, @default_colors) == input ? input : input_colors
  end

  def ask_colors
    puts 'How many colors do you want to play with? MAX 12'
    input = gets.chomp.to_i
    input.between?(1, 12) ? input : ask_colors
  end

  def set_random_colors
    @default_colors.sample(@colors_amount)
  end

  def colors
    @chosen_colors = @players.mastermind == 'AI' ? set_random_colors : choose_colors
  end

  def ask_guesses
    puts @default_colors.join(', ')
    puts "#{@players.codebreaker} Please enter #{@colors_amount} colors from the list of colors to make a guess!"
    input_colors
  end

  def play_round
    unless @guesses_left.positive?
      out_of_guesses
      return
    end

    notify_guesses
    guess = @players.codebreaker == 'AI' ? @players.ai_guess(@default_colors, @colors_amount) : ask_guesses
    mastermind_feedback(guess)
    guess == @chosen_colors ? game_victory : play_round
  end

  def notify_guesses
    @guesses_left -= 1
    puts "#{@guesses_left} guesses left!"
  end

  def mastermind_feedback(guess)
    correct_colors = check_colors(guess, @chosen_colors).length
    correct_codes = check_correct_codes(guess).length
    @players.ai_update_data(correct_codes, correct_colors, guess) if @players.codebreaker == 'AI'
    puts "#{@players.codebreaker} guessed #{correct_colors} colors correctly"
    puts "and #{correct_codes} colors correctly with their positions!"
  end

  def game_victory
    puts "Wohooo #{@players.codebreaker} won!"
  end

  def out_of_guesses
    puts "#{@players.codebreaker} is out of guesses! better luck next time, loser."
  end

  def check_colors(code, chosen_colors)
    temp = chosen_colors.clone
    code.select do |color|
      search = temp.find_index(color)
      if search.nil?
        false
      else
        temp[search] = nil
        true
      end
    end
  end

  def check_correct_codes(code)
    code.select.with_index { |color, index| color == @chosen_colors[index] }
  end
end

# this is the class for players
class Players
  attr_reader :names, :mastermind, :codebreaker

  private

  def initialize
    @against_ai = against_ai?
    @names = [get_name('First'), @against_ai ? 'AI' : get_name('Second')]
    roles = choose_mastermind
    @codebreaker = roles == 1 ? @names[1] : @names[0]
    @mastermind = roles == 1 ? @names[0] : @names[1]
    @ai_last_correct_colors, @ai_last_correct_codes = 0
  end

  def choose_mastermind
    puts "Who is the MASTERMIND, 1 (#{@names[0]}) or 2 (#{names[1]})?"
    input = gets.chomp.to_i
    p input
    input.between?(1, 2) ? input : choose_mastermind
  end

  def get_name(num)
    puts "#{num} player, please enter your name."
    gets.chomp
  end

  def against_ai?
    puts 'Please type yes if you want to play against AI!'
    return true if gets.chomp == 'yes'

    false
  end

  def ai_update_possible_guesses(correct_codes, correct_colors, last_guess)
    @ai_all_possible_guesses = ai_check_color_matches(correct_colors, last_guess)
    @ai_all_possible_guesses = ai_check_code_matches(correct_codes, last_guess)
  end

  def ai_check_color_matches(colors, last)
    @ai_all_possible_guesses.select { |guess| (guess & last).size == colors }
  end

  def ai_check_code_matches(codes, last)
    @ai_all_possible_guesses.select do |guess|
      matches = 0
      guess.each.with_index { |code, index| matches += 1 if code == last[index] }
      matches == codes
    end
  end

  def ai_first_guess(colors, amount)
    @ai_all_possible_guesses = colors.repeated_permutation(amount).to_a
    @ai_guesses = 1
    %w[red red blue blue]
  end

  public

  def ai_guess(default_colors, colors_amount)
    return ai_first_guess(default_colors, colors_amount) if @ai_guesses.nil?

    @ai_guesses += 1
    ai_update_possible_guesses(@ai_last_correct_codes, @ai_last_correct_colors, @ai_last_guess)
    @ai_all_possible_guesses[0]
  end

  def ai_update_data(correct_codes, correct_colors, last_guess)
    @ai_last_correct_codes = correct_codes
    @ai_last_correct_colors = correct_colors
    @ai_last_guess = last_guess
  end
end

Game.new
