require 'sinatra'
require 'sinatra/reloader'

configure do
    set :session_secret, "328479283uf923fu8932fu923uf9832f23f232"
    enable :sessions
end

class HangManGame
    attr_accessor :word, :left_to_guess, :guesses_made
    def initialize
        file = File.open('public/5desk.txt')
        @word_bank = file.read.split("\n").select{|item| item.length > 4 && item.length < 13}
        @word = @word_bank[rand(@word_bank.length)]
        @left_to_guess = Array.new(@word.length-1, '_')
        @guesses_left = 9
        @guesses_made = []
    end

    def update_game(guess)
        if @guesses_left <= 0
            return "Dood already dead."
        elsif guess == nil || !guess.match(/^[a-zA-Z]$/)
            return "Guess a letter"
        else
            @word.split("").each_with_index{|letter, i| @left_to_guess[i] = @word[i] if letter.downcase == guess.downcase}
        end
        
        if @left_to_guess.none?{|item| item == '_' } 
            "You saved dood."
        elsif @guesses_made.include?(guess.downcase)
            "You already guessed that."
        elsif !@word.include?(guess) 
            @guesses_left -= 1 
            @guesses_made.push(guess.downcase)
            @guesses_left <= 0 ? "Dood dead." : "You're killing this dood. #{@guesses_left} more tries."
        else 
            "You might save this dood."
        end
    end

    def get_img
        @left_to_guess.none?{|item| item == '_' } ? "win.png" : "#{9 - @guesses_left}.png"
    end

    def save_game
        Dir.mkdir("saved") unless Dir.exists? "saved"
        filename = "saved/game.txt"
        File.open(filename, 'w') do |file| 
            file.puts @word
            file.puts @left_to_guess
            file.puts @guesses_left
        end
        puts "Game saved!"
    end

    def load_game
        file = File.open('saved/game.txt')
        saved_info = file.read.split("\n")
        p saved_info
        @word = saved_info[0]
        @left_to_guess = saved_info[1, @word.length-1]
        @guesses_left = saved_info[-1]
    end

end

game = HangManGame.new

get '/' do
    guess = params['guess']
    message = game.update_game(guess)
    image = game.get_img
    session['word'] = game.word
    session['remaining'] = game.left_to_guess.join(' ')
    session['tried'] = game.guesses_made.join((' '))
    erb :index, :locals => {:word => session['word'], 
                            :message => message, 
                            :remaining => session['remaining'], 
                            :tried => session['tried'],
                            :image => image}
end

get '/new' do
    game = HangManGame.new
    redirect '/'
end
