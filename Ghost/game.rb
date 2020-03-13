require 'set'
require 'byebug'
require_relative 'player'
require_relative 'AiPlayer'

class Game

    attr_reader :players, :fragment, :losses, :ai_player

    @@fragment = ""

    def initialize(*players_name, ai_player)
        @players = players_name.map {|name| Player.new(name)}
        @ai_player = AiPlayer.new if ai_player
        # @@fragment = ""
        @dictionary = Set.new
            File.foreach("dictionary.txt") { |line| @dictionary.add(line.chomp)}

        @losses = Hash.new(0)
        @players.each do |player|
            @losses[player] = 0
        end
    end

    def play_round
        until !self.take_turn(self.current_player)
            self.next_player!
        end
        @@fragment=""
        @losses[@players.first] += 1
        self.display_standings
    end

    def current_player
        @players.first.name
    end

    def previous_player
        @players[1].name
    end

    def next_player!
        @players.rotate!
    end

    def take_turn(player)
        
        letter = ""
        
        until valid_play?(letter)
            puts "#{player} Write a letter"
            letter = gets.chomp
        end

        @@fragment += letter

        if @dictionary.any? {|word| word == @@fragment}
            puts "it a word ! #{@@fragment}"
            
            return false
        end
        true
    end

    def valid_play?(char)
        alpha = ("a".."z").to_a
        return false if !alpha.include?(char.downcase)

        frag = @@fragment + char

        if !@dictionary.any? {|word| word[0...frag.length].include?(frag)}
            puts "No correct word begin with '#{frag}' retry "
        else
            true
        end
    end

    def record(player_name)

        player = []
        player = @players.select {|player| player.name == player_name}

        return "No Player Found" if player.length == 0

        lost = "GHOST"
        if @losses[player[0]] > 0
            return lost[0..@losses[player[0]] - 1]
        else
            return "-"
        end
    end

    def run
        until @players.length == 1

            self.play_round

            if record(current_player) == "GHOST"
                  @players.delete_at(0)
            end
        end
        puts "#{@players[0].name} is the winner !"
    end

    def display_standings
        puts "Scoreboard  :"
        @players.each do |player|
            puts "#{player.name} => #{self.record(player.name)}"
        end    
    end

    # if __FILE__ == $PROGRAM_NAME
    #     g = Game.new("bob","joe")
    # end

end

g = Game.new("bob","joe")
