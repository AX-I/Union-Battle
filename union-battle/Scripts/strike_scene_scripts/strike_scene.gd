extends Node2D

# The unionist and admin decks
var unionist_deck: 			Array 	= []
var admin_deck:    			Array 	= []

# The unionist and admin discard piles
var unionist_discard_pile:	Array	= []
var admin_discard_pile:		Array	= []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	# Globals for retrieving JSON values
	const PLAYER_STR	   = "Player"
	const NAME_STR		   = "card_name"
	const ENGAGEMENT_STR   = "engagement"
	const RISK_STR		   = "risk"
	const SPRITE_STR	   = "path_to_img"
	const ACADEMIC_STR	   = "academic_position"
	const PERSONAL_STR	   = "personal_position"

	# Get each child that is a player
	for players in self.get_children():

		# Store players only
		if players.name.contains(PLAYER_STR):
			Globals.PLAYERS.append(players)

	# Total number of cards created
	var total_cards 	   = 0

	# Get each player component
	var player_stances     = get_json_from_file(Globals.PLAYER_POS_JSON)
	var personal_positions = player_stances.get(PERSONAL_STR)
	var academic_positions = player_stances.get(ACADEMIC_STR)

	# Setup initial player values
	for player in Globals.PLAYERS:

		# Setup variable player attributes
		player.setup_player(Globals.PLAYER_COUNT, Globals.CARD_COORD_SETS.pop_front())

		# Choose a role for the player if it is union
		if player.is_player_union():
			random_role(player, personal_positions, academic_positions)

		# Increasing player count
		Globals.PLAYER_COUNT += 1

	# Initializing random number generator
	randomize()

	# Getting the full lists of each kind of card
	var unionist_deck_dict = get_json_from_file(Globals.UNIONIST_CARD_JSON)
	var admin_deck_dict	   = get_json_from_file(Globals.ADMIN_CARD_JSON)

	# DELETE THIS OUTER LOOP ONCE WE GET MORE CARDS
	for i in range(10):

		# Add each of the cards to the deck
		for card_vals in unionist_deck_dict.values():

			# Create the new card
			var new_card  = PlayingCard.new()
			self.add_child(new_card)
			new_card.name = "Card_%s" % total_cards

			# Setting the new card values
			new_card.setup_card(
				Globals.UNUSED_CARD_ID,
				card_vals.get(ENGAGEMENT_STR),
				card_vals.get(RISK_STR),
				Globals.OFF_SCREEN,
				card_vals.get(NAME_STR),
				card_vals.get(SPRITE_STR)
			)

			# Adding the card as a child of the scene and as a card in the deck
			unionist_deck.append(new_card)

			# Incrementing card count
			total_cards = total_cards + 1

	# DELETE THIS OUTER LOOP ONCE WE GET MORE CARDS
	for i in range(5):

		# Add each of the cards to the deck
		for card_vals in admin_deck_dict.values():

			# Create the new card
			var new_card  = PlayingCard.new()
			self.add_child(new_card)
			new_card.name = "Card_%s" % total_cards

			# Setting the new card values
			new_card.setup_card(
				Globals.UNUSED_CARD_ID,
				card_vals.get(ENGAGEMENT_STR),
				card_vals.get(RISK_STR),
				Globals.OFF_SCREEN,
				card_vals.get(NAME_STR),
				card_vals.get(SPRITE_STR)
			)

			# Adding the card as a child of the scene and as a card in the deck
			admin_deck.append(new_card)

			# Incrementing card count
			total_cards = total_cards + 1

	# Shuffling the decks
	unionist_deck.shuffle()
	admin_deck.shuffle()

	# Dealing the cards
	deal_cards()

	setupIndicators()

func setupIndicators():
	var indicator = get_node('MeIndicator')
	indicator.position = Globals.PLAYER_COORDS[Globals.MY_ID]
	indicator.z_index = -10

	indicator = get_node('TurnIndicator')
	indicator.position = Globals.PLAYER_COORDS[Globals.curr_turn]
	indicator.z_index = -20

# Called to handle player input
func _input(event):

	# Checking for mouse input
	if event is InputEventMouseButton:

		# See where click occured
		if event.is_pressed():
			print("Mouse clicked at: ", get_global_mouse_position())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

# Called to deal cards to each players
func deal_cards() -> void:

	# Deal a card to each player in order
	for i in range(5):

		# Deal a card to each player once
		for player in Globals.PLAYERS:

			# If player is union pull from the union deck
			if player.is_player_union():
				player.take_card(unionist_deck.pop_front())

			# If the player is not union draw from the admin deck
			else:
				player.take_card(admin_deck.pop_front())

# Called to choose a random role for a player
func random_role(
	player: 		StaticBody2D,
	personal_list: 	Array,
	academic_list: 	Array
) -> void:

	# Intialize random number generator
	randomize()

	# Globals for retrieving JSON values
	const POS_NAME		= "name"
	const ENGAGEMENT	= "engagement"
	const RISK			= "risk"
	const PRIORITIES 	= "priorities"

	# Choose a random academic and personal position
	var personal		= personal_list[randi_range(0, personal_list.size() - 1)]
	var academic		= academic_list[randi_range(0, academic_list.size() - 1)]

	# Setting the role accordingly
	player.set_engagement(personal.get(ENGAGEMENT) + academic.get(ENGAGEMENT))
	player.set_risk(personal.get(RISK) + academic.get(RISK))
	player.set_player_label(personal.get(POS_NAME) + "\n" + academic.get(POS_NAME))

	#Now set the priorities
	player.add_priorities(personal.get(PRIORITIES) + academic.get(PRIORITIES))
	print("Created Player with priorities: ", personal.get(PRIORITIES) + academic.get(PRIORITIES))

# Draw a card from the unionist deck
func draw_card(union_deck: bool) -> void:

	# Success of a draw
	var draw_success = false

	# Getting the player allegiance
	var is_union	 = Globals.PLAYERS[Globals.curr_turn].is_player_union()

	# Only draw if no card has been drawn this turn
	if not Globals.drew_this_turn:

		# Draw a card based on the player drawing
		if is_union and union_deck:
			draw_success = union_draw(is_union)
		elif not(is_union or union_deck):
			draw_success = admin_draw(is_union)

		# Making sure that no other card can be drawn this turn
		if draw_success:
			Globals.drew_this_turn = true

# Draw a card specifically from the union pile
func union_draw(
	is_union: bool
) -> bool:

	# Do not draw if wrong deck as trigger
	if not is_union:
		return false

	# If the player's hand is not full then draw
	if Globals.PLAYERS[Globals.curr_turn].get_hand_size() < 5:
		Globals.PLAYERS[Globals.curr_turn].take_card(unionist_deck.pop_front())

	# Check if the unionist discard pile should be shuffled back into the deck
	if unionist_deck.size() == 0:
		union_reshuffle()

	return true

# Draw a card specifically from the admin pile
func admin_draw(
	is_union: bool
) -> bool:

	# Do not draw if wrong deck as trigger or hand size is too large
	if is_union:
		return false

	# Player 4 draws from the admin deck
	Globals.PLAYERS[Globals.curr_turn].take_card(admin_deck.pop_front())

	# Check if the admin discard pile should be shuffled back into the deck
	if admin_deck.size() == 0:
		admin_reshuffle()

	return true

# Discard a card to the discard pile
func discard_card(
	old_card: PlayingCard
) -> void:
	
	# Discard from the player's hand first
	Globals.PLAYERS[Globals.curr_turn].discard(old_card)
	
	# Discard to the union discard pile if the player is a unionist
	if Globals.PLAYERS[Globals.curr_turn].is_player_union():
		union_discard(old_card)

	# Discard to the admin discard pile otherwise
	else:
		admin_discard(old_card)

# Called to reshuffle the unionist deck
func union_reshuffle() -> void:

	# Set random number generator
	randomize()

	# Resetting the decks
	for i in unionist_discard_pile:
		unionist_deck.append(unionist_discard_pile.pop_front())

	# Shuffling the deck
	admin_deck.shuffle()

# Called to reshuffle the admin deck
func admin_reshuffle() -> void:

	# Set random number generator
	randomize()

	# Resetting the decks
	for i in admin_discard_pile:
		admin_deck.append(admin_discard_pile.pop_front())

	# Shuffling the deck
	admin_deck.shuffle()

# Called to place a card in the unionist discard pile
func union_discard(
	card: PlayingCard
) -> void:

	# Add card to the discard pile
	if not unionist_discard_pile.has(card):
		unionist_discard_pile.append(card)

# Called to place a card in the admin discard pile
func admin_discard(
	card: PlayingCard
) -> void:

	# Add card to the discard pile
	if not admin_discard_pile.has(card):
		admin_discard_pile.append(card)

# Called to retrieve JSON object from file
func get_json_from_file(
	path: String
) -> Dictionary:
	
	# The variable that will hold the json
	var json_obj: Dictionary = {}
	
	# Checking to see if the desired file exists
	if not ResourceLoader.exists(path):
		print("ERROR: No file found to retrieve JSON from")
		return json_obj

	# Getting the JSON object from the file
	var retrieved_json = JSON.parse_string(FileAccess.get_file_as_string(path))

	# If the type is successfully a dictionary then assign it to the return object
	if typeof(retrieved_json) == TYPE_DICTIONARY:
		json_obj = retrieved_json
	else:
		print("WARNING: JSON file content not a dictionary, type '", typeof(retrieved_json), "' found instead")

	return json_obj


func _on_end_turn() -> void:
	if Globals.curr_turn == Globals.PLAYER_COUNT-1:
		Globals.curr_turn = 0
	else:
		Globals.curr_turn += 1

	print("current turn", Globals.curr_turn)

	var indicator = get_node('TurnIndicator')
	indicator.position = Globals.PLAYER_COORDS[Globals.curr_turn]

	if Globals.PLAYERS[Globals.curr_turn].is_player_union():
		if Globals.PLAYERS[Globals.curr_turn].get_risk() > 6:
			Globals.PLAYERS[Globals.curr_turn].set_engagement(Globals.PLAYERS[Globals.curr_turn].get_engagement()-2)
		elif Globals.PLAYERS[Globals.curr_turn].get_risk() > 2:
			Globals.PLAYERS[Globals.curr_turn].set_engagement(Globals.PLAYERS[Globals.curr_turn].get_engagement()-1)
		if Globals.PLAYERS[Globals.curr_turn].get_engagement() < 1:
			Globals.curr_turn += 1
		else:
			draw_card(true)
	else:
		var total_engagement = 0
		for player in Globals.PLAYERS:
			if player.is_player_union():
				total_engagement -= player.get_engagement()
		Globals.PLAYERS[Globals.curr_turn].adjust_money(total_engagement)
		draw_card(false)
