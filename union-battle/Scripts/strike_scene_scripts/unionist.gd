extends StaticBody2D

# All of the labels
var egmt_label: 				Label		= null
var risk_label:				Label		= null
var player_label:			Label		= null
var priorities_label:		Label 		= null

# Constants for strings
const ENGAGEMENT_LABEL_STR:	String	    = "Engagement: "
const RISK_LABEL_STR:		String	    = "Risk: "

# The player is union
const _IS_UNION:				bool		= true

var player_name:			String	 	= ""

# The player ID
var _id: 					int 		= -1

# The player's hand
var _hand: 					Array   	= []

# The player's engagement and risk
var _engagement: 			int 		= 0
var _risk: 					int		= 0
var _priorities:				Array	= []

# Positions for player cards
var _card_positions:			Array 	= []

signal end_turn

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Retrieving the children and assigning them accordingly for later use
	for child in self.get_children():

		# Storing the engagement label
		if child.name.contains("Engagement"):
			egmt_label = child

		# Storing the risk label
		if child.name.contains("Risk"):
			risk_label = child

		# Storing the player label
		if child.name.contains("Label"):
			player_label = child
			
		# Storing the priorities label
		if child.name.contains("Priorities"):
			priorities_label = child
			
			# Start as hidden
			priorities_label.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

# Called to setup a player
func setup_player(id: int, card_pos: Array) -> void:

	# Set ID
	_id 			= id

	# Set card positions
	_card_positions = card_pos
	
	if not player_name:
		player_name = "Playester " + str(_id + 1)

func toggle_priorities(show_priorities: bool) -> void:
	# Either show the priorities and hide the cards, or vice versa
	for card in _hand:
		card.visible = not show_priorities
	
	if show_priorities:
		var priority_text = ""
		for priority in _priorities:
			priority_text += priority + ", "
			
		# Strip last comma and space
		priority_text = priority_text.left(priority_text.length() - 2)
		
		priorities_label.text = "Priorities: " + priority_text
	
	priorities_label.visible = show_priorities

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
	print("take card called: ", new_card.get_card_name())
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
	emit_signal('end_turn')

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

func add_priorities(
	priorities: Array
) -> void:
	for p in priorities:
		if p not in _priorities:
			_priorities.append(p)

func get_priorities() -> Array:
	print("player w/ id: " + str(_id) + "'s priorities = " + str(_priorities))
	return _priorities

# Setter for the player label
func set_player_label(player_name_param: String) -> void:
	player_name 	  = player_name_param.replace("\n", " ")
	player_label.text = player_name_param
	
func get_player_name():
	return player_name

# Getter for the ID
func get_id() -> int:
	return _id

# Getter for hand size
func get_hand_size() -> int:
	return _hand.size()

# Called to get if the player is union
func is_player_union() -> bool:
	return _IS_UNION

func is_alive() -> bool:
	return _engagement > 0

func get_stats() -> Dictionary:
	return {'engagement':get_engagement(), 'risk':get_risk()}

func set_stats(new_stat: Dictionary) -> void:
	set_engagement(new_stat['engagement'])
	set_risk(new_stat['risk'])
