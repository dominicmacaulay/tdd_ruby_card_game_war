require_relative 'war_player'
require_relative 'card_deck'
class WarGame
    attr_reader :player1, :player2, :deck
    attr_accessor :winner
    def initialize
        @player1 = Player.new("Player 1")
        @player2 = Player.new("Player 2")
        @deck = CardDeck.new()
        @winner = nil
    end

    def start
        deck.shuffle
        until deck.no_cards?
            player1.add_cards([deck.deal])
            player2.add_cards([deck.deal])
        end
    end

    def play_round(pile = [])
        pile.push(*retrieve_cards)
        if deck.tie?(pile[-2],pile[-1])
            play_round(pile)
        else
            if deck.player1_wins?(pile[-2],pile[-1])
                player1.add_cards(pile)
                message = match_feedback(player1, pile)
            else
                player2.add_cards(pile)
                message = match_feedback(player2, pile)
            end
            check_for_winner
            return message
        end
    end

    def retrieve_cards
        card1 = player1.remove_top_card
        card2 = player2.remove_top_card
        return [card1,card2]
    end

    def match_feedback(player, cards)
        message = "#{player.name} took "
        cards.each do |card|
            message.concat("and ") if card == cards.last
            message.concat("#{card.rank} of #{card.suit}")
            message.concat(", ") if card != cards.last
        end
        return message
    end

    def check_for_winner
        if player1.hand_length == 0
            self.winner = player2
        elsif player2.hand_length == 0
            self.winner = player1
        end
    end
end