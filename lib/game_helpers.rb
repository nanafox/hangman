# frozen_string_literal: true

# Helper methods for the Hangman game
module GameHelpers
  def clear_screen
    system('cls') || system('clear')
  end

  def display_menu
    puts 'Would you like to start a new game or load a saved game?'
    puts '[1]. New'
    puts '[2]. Load Saved Game'
    puts '[3]. Exit'
  end

  def display_saved_games
    files = game_files
    if files.empty?
      clear_screen
      puts 'There are no saved games'.colorize(:yellow)
      play
    else
      files.each_with_index { |file, index| puts "#{index + 1}: #{file}" }
      puts 'Select the game file to load back in'
      print '~>: '
    end
  end

  def load_game_file
    filename = game_files[gets.chomp.to_i - 1]
    deserialize(File.read("saves/#{filename}").chomp)
  rescue StandardError => e
    puts "An error occurred: #{e}"
    exit 1
  end

  def game_files
    Dir.foreach('saves').to_a.reject { |file| %w[. ..].include?(file) }
  end

  def create_save_directory
    Dir.mkdir('saves') unless Dir.exist?('saves')
  end

  def game_filename
    puts 'Enter a name for your save file'
    filename = "#{gets.chomp}.hangman"
    if File.exist?("saves/#{filename}")
      puts 'This file already exists, continuing will overwrite it. [Y/N]'
      return game_filename if gets.chomp.downcase == 'n'
    end

    filename
  end

  def write_save_file(filename)
    File.open("saves/#{filename}", 'w') { |file| file.puts serialize }
    puts "\nGame saved. Exiting now...".colorize(:magenta)
    handle_exit
  end

  def handle_exit
    puts 'Thank you for playing!'
    exit
  end

  def game_info
    puts
    puts 'To save the game at any point, type :save'
    puts 'To exit the game at any point, type :exit'
    puts 'To receive hints about the word, type :hint'
    puts
  end

  def print_teaser(last_guess = nil)
    update_teaser(last_guess) unless last_guess.nil?
    puts @word_teaser
  end

  def update_teaser(last_guess)
    new_teaser = @word_teaser.split
    new_teaser.each_with_index do |_letter, index|
      new_teaser[index] = last_guess if @word[index] == last_guess
    end

    @word_teaser = new_teaser.join(' ')
  end

  def words
    File.readlines(File.expand_path('../dictionary.txt', __dir__))
  end

  def game_over
    puts 'Game Over! Better luck next time!'.colorize(:red)
    puts "The word was: #{@word}"
    handle_exit
  end
end
