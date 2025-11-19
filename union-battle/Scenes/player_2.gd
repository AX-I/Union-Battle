extends StaticBody2D

# Both of the labels
@onready var egmt_label: 	Label		= $"PlayerEngagement2"
@onready var risk_label:	Label		= $"PlayerRisk2"
@onready var player_label:	Label		= $"PlayerLabel2"

# The player ID
const _ID: 					int 		= 2

# Constants for strings
const ENGAGEMENT_LABEL_STR:	String	   = "Engagement: "
const RISK_LABEL_STR:		String	   = "Risk: "

# The player's hand
var _hand: 					Array   	= []

# The player's engagement and risk
var _engagement: 			int 		= 0
var _risk: 					int			= 0

# Positions for player cards
var _card_positions:		Array 		= [Vector2(1110,186),
										   Vector2(990,186),
										   Vector2(990,306),
										   Vector2(990,426),
										   Vector2(1110,426)]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

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
	new_card.set_id(_ID)
	new_card.set_start_pos(_card_positions.pop_back())
	new_card.to_start_pos()
	print("take card called: ", new_card.name)
	print(_card_positions)

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

# Called to adjust statistics
func adjust_stats(
	card: PlayingCard
) -> void:

	# Adjusting engagement and risk
	_engagement 		 	   = _engagement + card.get_engagement()
	_risk 				 	   = _risk + card.get_risk()

	# Making sure engagement is not below zero
	if _engagement < 0:
		_engagement = 0

	# Making sure risk is not below zero
	if _risk < 0:
		_risk = 0

	# Updating the label text
	egmt_label.text 		   = ENGAGEMENT_LABEL_STR + str(_engagement)
	risk_label.text 		   = RISK_LABEL_STR + str(_risk)

# Getter for the engagement
func get_engagement() -> int:
	return _engagement

# Setter for the engagement
func set_engagement(
	new_egmt: int
) -> void:
	_engagement 	= new_egmt
	egmt_label.text = ENGAGEMENT_LABEL_STR + str(_engagement)

# Getter for the risk
func get_risk() -> int:
	return _risk

# Setter for the risk
func set_risk(
	new_risk: int
) -> void:
	_risk 			= new_risk
	risk_label.text = RISK_LABEL_STR + str(_risk)

# Setter for the player label
func set_player_label(player_name: String) -> void:
	player_label.text = player_name

# Getter for the ID
func get_id() -> int:
	return _ID

# Getter for hand size
func get_hand_size() -> int:
	return _hand.size()
