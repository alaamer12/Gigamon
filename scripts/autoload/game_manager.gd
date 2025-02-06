extends Node

signal game_state_changed(new_state)
signal turn_changed(player_id)
signal score_updated(player_id, new_score)

enum GameState {
	MENU,
	PLAYING,
	PAUSED,
	GAME_OVER
}

var current_state: GameState = GameState.MENU
var current_player: int = 1
var scores: Dictionary = {1: 0, 2: 0}
var deck: Array = []
var player_hands: Dictionary = {1: [], 2: []}

# Configuration
const MAX_HAND_SIZE = 7
const STARTING_HAND_SIZE = 5

func _ready():
	initialize_game()

func initialize_game():
	current_state = GameState.MENU
	current_player = 1
	scores = {1: 0, 2: 0}
	deck = []
	player_hands = {1: [], 2: []}

func start_game():
	current_state = GameState.PLAYING
	initialize_deck()
	deal_initial_hands()
	emit_signal("game_state_changed", current_state)

func initialize_deck():
	# Initialize deck with cards
	deck.clear()
	# Add cards to deck (implement based on game rules)
	shuffle_deck()

func shuffle_deck():
	deck.shuffle()

func deal_initial_hands():
	for player in player_hands.keys():
		for i in STARTING_HAND_SIZE:
			draw_card(player)

func draw_card(player_id: int) -> Dictionary:
	if deck.size() > 0 and player_hands[player_id].size() < MAX_HAND_SIZE:
		var card = deck.pop_back()
		player_hands[player_id].append(card)
		return card
	return {}

func play_card(player_id: int, card_index: int) -> bool:
	if player_id != current_player:
		return false
	
	if card_index >= 0 and card_index < player_hands[player_id].size():
		var card = player_hands[player_id][card_index]
		player_hands[player_id].remove_at(card_index)
		# Implement card effect here
		return true
	return false

func end_turn():
	current_player = 2 if current_player == 1 else 1
	draw_card(current_player)
	emit_signal("turn_changed", current_player)

func update_score(player_id: int, points: int):
	scores[player_id] += points
	emit_signal("score_updated", player_id, scores[player_id])

func get_game_state() -> Dictionary:
	return {
		"current_state": current_state,
		"current_player": current_player,
		"scores": scores.duplicate(),
		"deck_size": deck.size(),
		"player_hands": player_hands.duplicate(true)
	}

func save_game() -> Dictionary:
	var save_data = {
		"current_state": current_state,
		"current_player": current_player,
		"scores": scores,
		"deck": deck,
		"player_hands": player_hands
	}
	return save_data

func load_game(save_data: Dictionary) -> bool:
	if validate_save_data(save_data):
		current_state = save_data.current_state
		current_player = save_data.current_player
		scores = save_data.scores
		deck = save_data.deck
		player_hands = save_data.player_hands
		emit_signal("game_state_changed", current_state)
		return true
	return false

func validate_save_data(save_data: Dictionary) -> bool:
	return save_data.has_all(["current_state", "current_player", "scores", "deck", "player_hands"])
