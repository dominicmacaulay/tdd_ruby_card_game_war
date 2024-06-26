# frozen_string_literal: true

require_relative 'war_player'
require_relative 'card_deck'

# manages and plays the game war
class WarGame
  attr_reader :player1, :player2, :deck, :players
  attr_accessor :winner

  def initialize(players = [Player.new('Player 1'), Player.new('Player 2')])
    @players = players
    @deck = CardDeck.new
    @winner = nil
  end

  def start
    deck.shuffle
    until deck.no_cards?
      # player1.add_cards([deck.deal])
      # player2.add_cards([deck.deal])
      players.each { |player| deal_card_to_player(player) }
    end
  end

  def play_round(pile = [])
    return if check_for_game_winner

    pile.push(*retrieve_cards)
    return play_round(pile) if deck.tie?(pile.last(players.length))

    match_winner = get_match_winner(pile)
    match_feedback(match_winner, pile)
  end

  def deal_card_to_player(player)
    card = deck.deal
    card.change_player(player)
    player.add_cards([card])
  end

  # TODO: rewrite to get the card's player
  def get_match_winner(pile)
    # match_winner = deck.winning_card(pile[-2], pile[-1]) ? player1 : player2
    # match_winner.add_cards(pile)
    # match_winner
    winning_card = deck.winning_card(pile.last(players.length))
    pile.each { |card| card.change_player(winning_card.player) }
    winning_card.player.add_cards(pile)
    winning_card.player
  end

  def retrieve_cards
    # card1 = player1.remove_top_card
    # card2 = player2.remove_top_card
    # [card1, card2]
    players.map(&:remove_top_card)
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
    players.delete_if { |player| player.hand_length.zero? }
    # num_of_losers = players.count { |player| player.hand_length.zero? }
    return unless players.count == 1

    self.winner = players.first
  end
end
