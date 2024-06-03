require_relative 'war_player'
require_relative 'card_deck'
class WarGame
    attr_reader :player1, :player2, :deck, :winner
    def initialize
        @player1 = Player.new("Player 1")
        @player2 = Player.new("Player 2")
        @deck = CardDeck.new
        @winner = nil
    end
    def start
        @deck.shuffle
        until @deck.no_cards?
            @player1.add_cards(@deck.deal)
            @player2.add_cards(@deck.deal)
        end
    end
    def play_round(pile = [])
        card1 = @player1.remove_top_card
        card2 = @player2.remove_top_card
        pile.push(card1)
        pile.push(card2)
        if card1.rank > card2.rank
            player1.add_cards(pile)
        elsif card1.rank < card2.rank
            player2.add_cards(pile)
        end
    end
end