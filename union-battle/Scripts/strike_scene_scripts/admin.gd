extends StaticBody2D

# Both of the labels
@onready var money_label: 	Label		= $"Money"

# The player ID
var _id: 					int 		= -1

# Money string constant
const MONEY_STR:			String		= "Money: "

# The player is union
const _IS_UNION:			bool		= false

# The player's hand
var _hand: 					Array   	= []

# The player's engagement and risk
var _money: 				int 		= 100

# Positions for player cards
var _card_positions:		Array 		= []

signal end_turn

# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	# Setting the label's text
	money_label.text = MONEY_STR + str(_money)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

# Called to setup a player
func setup_player(id: int, card_pos: Array) -> void:

	# Set ID
	_id 			= id

	# Set card positions
	_card_positions = card_pos

# Called to take a card from the deck
func take_card(
	new_card: PlayingCard
) -> void:

	# If the new card is null or the hand is full do not perform any operations
	if new_card == null or _hand.size() >= 5:
		return

	# Add card to hand
	_hand.append(new_card)

	# Setting the card's ID and position
	new_card.set_id(_id)
	new_card.set_start_pos(_card_positions.pop_back())
	new_card.to_start_pos()

# Called to discard a card
func discard(
	old_card: PlayingCard
) -> void:

	# Remove the card from the hand
	for i in range(_hand.size()):
		if _hand[i] == old_card:
			_hand.remove_at(i)
			break

	# Reset the ID and position
	old_card.set_id(Globals.UNUSED_CARD_ID)
	_card_positions.append(old_card.get_start_pos())
	old_card.set_start_pos(Globals.OFF_SCREEN)
	old_card.to_start_pos()
	emit_signal('end_turn')

# Called to adjust the money of the admin player
func adjust_money(
	bonus: int
) -> void:

	# Adding the bonus to the current money value
	_money = _money + bonus

	# Setting the label's text
	money_label.text = MONEY_STR + str(_money)

# Getter for the ID
func get_id() -> int:
	return _id

# Getter for hand size
func get_hand_size() -> int:
	return _hand.size()

# Called to get if the player is union
func is_player_union() -> bool:
	return _IS_UNION
