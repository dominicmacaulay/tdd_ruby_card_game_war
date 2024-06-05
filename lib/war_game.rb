# frozen_string_literal: true

require_relative 'war_player'
require_relative 'card_deck'
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
    return play_round(pile) if deck.tie?(pile[-2], pile[-1])

    match_winner = get_match_winner(pile)
    match_feedback(match_winner, pile)
  end

  def get_match_winner(pile)
    match_winner = deck.player1_wins?(pile[-2], pile[-1]) ? player1 : player2
    match_winner.add_cards(pile)
    match_winner
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
    if player1.hand_length == 0
      self.winner = player2
    elsif player2.hand_length == 0
      self.winner = player1
    else
      false
    end
  end
end
