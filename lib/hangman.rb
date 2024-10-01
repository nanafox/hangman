# frozen_string_literal: true

require 'colorize'
require_relative 'serializable'
require_relative 'game_helpers'

# Class for the Hangman game
class Hangman
  include Serializable
  include GameHelpers

  def initialize
    @word = words.shuffle.sample.chomp
    @lives = 8
    @hints_allowed = @word.length / 2
    @word_teaser = '_ ' * @word.size
  end

  def play
    welcome
    display_menu
    handle_choices(gets.chomp.to_i)
  end

  private

  def handle_choices(choice)
    case choice
    when 1 then start_new_game
    when 2 then load_saved_game
    when 3 then exit_game
    else invalid_option
    end
  end

  def start_new_game
    puts 'Starting a new game...'
    make_guess
  end

  def load_saved_game
    puts 'Loading saved games...'
    display_saved_games
    load_game_file
    puts 'Game state loaded successfully'.colorize(:blue)
    print_teaser
    make_guess
  end

  def exit_game
    exit 0
  end

  def invalid_option
    clear_screen
    puts 'Invalid option selected'.colorize(:red)
    play
  end

  def make_guess
    return game_over if @lives <= 0

    game_info
    puts 'Enter a letter'
    print '~>: '
    handle_guess(gets.chomp.downcase)
  end

  def handle_guess(guess)
    case guess
    when ':exit' then handle_exit
    when ':save' then save_game
    when ':hint' then provide_hint
    else process_guess(guess)
    end
  end

  def process_guess(guess)
    clear_screen
    if @word.include?(guess)
      correct_guess(guess)
    else
      incorrect_guess
    end
    make_guess
  end

  def correct_guess(guess)
    puts 'You are correct!'
    print_teaser(guess)
    return unless @word == @word_teaser.split.join

    puts 'Congratulations... you have won this round!'.colorize(:green)
    exit
  end

  def incorrect_guess
    @lives -= 1
    puts "Sorry... you have #{@lives} lives left"
    print_teaser
  end

  def provide_hint
    if @hints_allowed.positive?
      @hints_allowed -= 1
      puts "Allowed Hints Left: #{@hints_allowed}"
      random_letter = (@word.chars - @word_teaser.split).sample
      update_teaser(random_letter)
      process_guess(random_letter)
    else
      puts 'No more hints allowed'
      make_guess
      print_teaser
    end
  end

  def save_game
    create_save_directory
    write_save_file(game_filename)
  end

  def welcome
    puts 'Welcome to Hangman!'
    game_info
  end
end
