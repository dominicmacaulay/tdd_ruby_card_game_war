# frozen_string_literal: true

require_relative 'war_player'
require_relative 'card_deck'

# manages and plays the game war
class WarGame
  attr_reader :player1, :player2, :deck, :players
  attr_accessor :winner

  def initialize(player1 = Player.new('Player 1'), player2 = Player.new('Player 2'))
    @player1 = player1
    @player2 = player2
    @players = [@player1, @player2]
    @deck = CardDeck.new
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
    return if check_for_game_winner

    pile.push(*retrieve_cards)
    return play_round(pile) if deck.tie?(pile.last(players.length))

    match_winner = get_match_winner(pile)
    match_feedback(match_winner, pile)
  end

  # TODO: rewrite to get the card's player
  def get_match_winner(pile)
    # match_winner = deck.winning_card(pile[-2], pile[-1]) ? player1 : player2
    # match_winner.add_cards(pile)
    # match_winner
    winning_card = deck.winning_card(pile.last(players.length))
  end

  def retrieve_cards
    card1 = player1.remove_top_card
    card2 = player2.remove_top_card
    [card1, card2]
  end

  def match_feedback(player, cards)
    message = "#{player.name} took "
    cards.each do |card|
      message.concat('and ') if card == cards.last
      message.concat("#{card.rank} of #{card.suit}")
      message.concat(', ') if card != cards.last
    end
    message
  end

  def check_for_game_winner
    num_of_losers = players.count { |player| player.hand_length.zero? }
    return unless num_of_losers == players.count - 1

    winner = nil
    players.each { |player| winner = player if player.hand_length.positive? }
    self.winner = winner
  end
end
