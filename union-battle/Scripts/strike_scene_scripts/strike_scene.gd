extends Node2D

@onready var priority_popup: ColorRect = $CanvasLayer/TopRight/Control/PriorityPopup
@onready var priority_switch: Button = $CanvasLayer/BotRight/Buttons/PrioritySwitch
@onready var end_turn: Button = $CanvasLayer/BotRight/Buttons/EndTurn
@onready var global_priorities: Control = $CanvasLayer/Center/Control/GlobalPriorities
@onready var union_deck_btn: TextureButton = $CanvasLayer/Center/Control/UnionDeck
@onready var admin_deck_btn: TextureButton = $CanvasLayer/Center/Control/AdminDeck
@onready var instructions_text: Label = $CanvasLayer/BotLeft/InstructionsBox/InstructionsLabel
@onready var turn_text: Label = $CanvasLayer/TopLeft/TurnBox/TurnLabel

const PRIO_BTN_SCENE = preload("res://Scenes/global_priority.tscn")


# The unionist and admin decks
var unionist_deck: Array = []
var admin_deck: Array = []

# The unionist and admin discard piles
var unionist_discard_pile: Array = []
var admin_discard_pile: Array = []

var show_priorities: bool = false

# If set, forces the next turn to be this player's turn
var force_player_turn: int = -1

var connectionOutNode

signal send_end_my_turn

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Initializing random number generator
	seed(Globals.R_SEED)

	# Globals for retrieving JSON values
	const PLAYER_STR = "Player"
	const NAME_STR = "card_name"
	const ENGAGEMENT_STR = "engagement"
	const RISK_STR = "risk"
	const SPRITE_STR = "path_to_img"
	const ACADEMIC_STR = "academic_position"
	const PERSONAL_STR = "personal_position"
	
	# Don't show priority stuff by default
	global_priorities.visible = false
	priority_popup.visible = false

	# Get each child that is a player
	for objs in self.get_children():
		if objs.name.contains("CanvasLayer"):
			for box_objs in objs.get_children():
				for obj in box_objs.get_children():
					# Store players only
					if obj.name.contains(PLAYER_STR):
						Globals.PLAYERS.append(obj)
						Globals.PLAYER_COORDS.append(obj.global_position)
						Globals.CARD_COORD_SETS.append(obj.get_init_card_pos_array())
						
			break

	# Total number of cards created
	var total_cards = 0

	# Get each player component
	var player_stances = get_json_from_file(Globals.PLAYER_POS_JSON)
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
		
	for priority in Globals.get_all_priorities():
		var btn = PRIO_BTN_SCENE.instantiate()
		
		btn.text = priority
		btn.set_prio_name(priority)
		global_priorities.add_child(btn)
		Globals.undecided_priority_btns.append(btn)
		btn.size = Vector2(70, 10)
		
		# Connect the button_pressed signal
		btn.pressed.connect(_on_global_priority_btn_pressed.bind(btn))
		btn.mouse_entered.connect(_on_global_priority_btn_mouse_entered.bind(btn))
		btn.mouse_exited.connect(_on_global_priority_btn_mouse_exited.bind(btn))
		
	place_all_global_priorities()

	# Getting the full lists of each kind of card
	var unionist_deck_dict = get_json_from_file(Globals.UNIONIST_CARD_JSON)
	var admin_deck_dict = get_json_from_file(Globals.ADMIN_CARD_JSON)

	turn_text.text = "You are player " + str(Globals.MY_ID + 1) + "\nIt is player " + str(Globals.curr_turn + 1) + "'s turn"

	# DELETE THIS OUTER LOOP ONCE WE GET MORE CARDS
	for i in range(10):
		# Add each of the cards to the deck
		for card_vals in unionist_deck_dict.values():
			# Create the new card
			var new_card = PlayingCard.new()
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
			var new_card = PlayingCard.new()
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

	connectionOutNode = get_node('ConnectionOut')

	setupIndicators()

func place_all_global_priorities():
	place_global_priorities(Globals.undecided_priority_btns)
	place_global_priorities(Globals.yes_priority_btns)
	place_global_priorities(Globals.no_priority_btns)

func place_global_priorities(instance_arr: Array):
	for i in range(len(instance_arr)):
		var prio_btn = instance_arr[i]
		var parent = null
		
		if prio_btn.get_prio_state() == Globals.UNDECIDED_STATE:
			parent = global_priorities.get_node("Undecided")
		elif prio_btn.get_prio_state() == Globals.NO_STATE:
			parent = global_priorities.get_node("Scrapped")
		elif prio_btn.get_prio_state() == Globals.YES_STATE:
			parent = global_priorities.get_node("Approved")
		
		# 0 or 1
		var col = (i % 2)
		
		# 0+
		var row = (floor(i / 2))
		
		prio_btn.global_position = parent.global_position + Vector2(col * 140, row * 90) + Vector2(-20, 50)

func setupIndicators():
	var indicator = get_node('MeIndicator')
	indicator.global_position = Globals.PLAYER_COORDS[Globals.MY_ID]
	indicator.z_index = -10
	
	if (!Globals.PLAYERS[Globals.MY_ID].is_player_union()):
		instructions_text.text = "Turn Instructions\n1.Draw a card from the Admin Deck\n2.Play a card on a unionist\nOR\nSkip your turn"
	else:
		# If a player cannot play then ask them to end their turn
		if !Globals.PLAYERS[Globals.MY_ID].is_alive():
			# Telling the player that both their risk and engagement are out of bounds
			if Globals.PLAYERS[Globals.MY_ID].get_engagement() <= 0 and Globals.PLAYERS[Globals.MY_ID].get_risk() >= 10:
				instructions_text.text = "Your engagement is too low\nand your risk is too high.\nPlease end your turn."

			# Telling the player that their risk is too high
			elif Globals.PLAYERS[Globals.MY_ID].get_risk() >= 10:
				instructions_text.text = "Your risk is too high.\nPlease end your turn."

			# Telling the player that their engagement is too low
			else:
				instructions_text.text = "Your engagement is too low.\nPlease end your turn."

		# Telling the player their actions on their turn as a unionist
		else:
			instructions_text.text = "Turn Instructions:\n1. Draw a card from the Union Deck\n2. Play a card (on yourself or another Unionist)\nOR\nDeclare a priority to vote on\nOR\nSkip your turn"

	indicator = get_node('TurnIndicator')
	indicator.global_position = Globals.PLAYER_COORDS[Globals.curr_turn]
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
	player: StaticBody2D,
	personal_list: Array,
	academic_list: Array
) -> void:
	# Intialize random number generator
	randomize()

	# Globals for retrieving JSON values
	const POS_NAME = "name"
	const ENGAGEMENT = "engagement"
	const RISK = "risk"
	const PRIORITIES = "priorities"

	# Choose a random academic and personal position
	var personal = personal_list[randi_range(0, personal_list.size() - 1)]
	var academic = academic_list[randi_range(0, academic_list.size() - 1)]

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
	var is_union = Globals.PLAYERS[Globals.curr_turn].is_player_union()

	# Only draw if no card has been drawn this turn
	#if not Globals.drew_this_turn: Doesnt look like we want this but leaving it in for easy reversion
	# Draw a card based on the player drawing
	if is_union and union_deck:
		draw_success = union_draw(is_union)
	elif not (is_union or union_deck):
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
		
		# If showing priorities, hide the card
		if show_priorities:
			Globals.PLAYERS[Globals.curr_turn].toggle_priorities(true)

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
	
	# If showing priorities, hide the card
	if show_priorities:
		Globals.PLAYERS[Globals.curr_turn].toggle_priorities(true)

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
	# Resetting the decks
	for i in unionist_discard_pile:
		unionist_deck.append(unionist_discard_pile.pop_front())

	# Shuffling the deck
	admin_deck.shuffle()

# Called to reshuffle the admin deck
func admin_reshuffle() -> void:
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


func _on_end_turn(remote_activation := false) -> void:
	# If it is not the current player's turn don't end
	if not remote_activation:
		# Nothing happens if it is not your turn
		if Globals.curr_turn != Globals.MY_ID:
			return

	Globals.drew_this_turn = false

	if Globals.curr_turn == Globals.MY_ID:
		await get_tree().create_timer(0.5).timeout
		print(Globals.MY_ID, ' end my turn!')
		emit_signal('send_end_my_turn')

	if Globals.curr_turn == Globals.PLAYER_COUNT - 1:
		Globals.curr_turn = 0
	else:
		Globals.curr_turn += 1

	print('id ', Globals.MY_ID, " current turn ", Globals.curr_turn)
	
	# If we are forcing a player's turn, keep going until we hit it
	if -1 != force_player_turn:
		if (force_player_turn != Globals.curr_turn and
			Globals.curr_turn == Globals.MY_ID):
				print('skip my turn')
				_on_end_turn()
		else:
			force_player_turn = -1

	var indicator = get_node('TurnIndicator')
	indicator.position = Globals.PLAYER_COORDS[Globals.curr_turn]

	#Check for end of game conditions
	var all_priorities_agreed = 0 == Globals.undecided_priority_btns.size()
	var union_engagement = 0
	for player in Globals.PLAYERS:
		if player.is_player_union():
			union_engagement += player.get_engagement()
	var unionists_no_engagement = 0 >= union_engagement
	var admin_no_money = false
	for player in Globals.PLAYERS:
		if not player.is_player_union():
			admin_no_money = not player.is_alive()
	#TODO REMOVE, IS FOR TESTING END OF GAME
	# for player in Globals.PLAYERS:
	# 	if not player.is_player_union():
	# 		player.adjust_money(-100)
	# admin_no_money = true
	#END OF TESTING
	if all_priorities_agreed or unionists_no_engagement or admin_no_money:
		if all_priorities_agreed:
			print("Game ended due to all_priorities_agreed")
		elif unionists_no_engagement:
			print("Game ended due to unionists_no_engagement")
		elif admin_no_money:
			print("Game ended due to admin_no_money")
		#get_tree().change_scene_to_file("res://Scenes/end_scene.tscn")
		add_child(load("res://Scenes/end_scene.tscn").instantiate())

	
	turn_text.text = "You are player " + str(Globals.MY_ID + 1) + "\nIt is player " + str(Globals.curr_turn + 1) + "'s turn"
	
	if null != Globals.active_vote_btn:
		start_voting_turn()
	else:
		start_normal_turn()

func start_voting_turn():
	print('id ', Globals.MY_ID, ' start voting turn')
	# IF it is a voting turn, make sure we go through each unionist's opinion on the vote before we get to the admin
	if not Globals.PLAYERS[Globals.curr_turn].is_player_union():
		# Num votes has to equal number of players - 1 (# of unionists), else skip the admin's turn
		if Globals.active_vote_btn.get_num_votes() < (len(Globals.PLAYERS) - 1):
			if Globals.MY_ID == Globals.curr_turn:
				print('admin skip my turn ', Globals.MY_ID)
				_on_end_turn()
			
	# If this player has already voted, skip their turn
	if Globals.active_vote_btn.has_player_voted(Globals.curr_turn):
		if Globals.MY_ID == Globals.curr_turn:
			print('already voted ', Globals.MY_ID)
			_on_end_turn()
		
	show_voting_ui(true)
	
func start_normal_turn():
	if Globals.PLAYERS[Globals.curr_turn].is_player_union():
		if Globals.PLAYERS[Globals.curr_turn].get_risk() > 6:
			Globals.PLAYERS[Globals.curr_turn].set_engagement(Globals.PLAYERS[Globals.curr_turn].get_engagement() - 2)
		elif Globals.PLAYERS[Globals.curr_turn].get_risk() > 2:
			Globals.PLAYERS[Globals.curr_turn].set_engagement(Globals.PLAYERS[Globals.curr_turn].get_engagement() - 1)
	else:
		var total_engagement = 0
		for player in Globals.PLAYERS:
			if player.is_player_union():
				total_engagement -= player.get_engagement()
		Globals.PLAYERS[Globals.curr_turn].adjust_money(total_engagement)
	setupIndicators()
	
func _on_dev_switch_player_pressed() -> void:
	Globals.MY_ID += 1
	if Globals.MY_ID == Globals.PLAYER_COUNT:
		Globals.MY_ID = 0
	setupIndicators()
	
	# If vote is in progress, update the UI
	if null != Globals.active_vote_btn:
		if not Globals.active_vote_btn.get_can_start_vote():
			show_voting_ui(true)

func _on_priority_switch_pressed() -> void:
	show_priorities = not show_priorities
	
	global_priorities.visible = show_priorities
	union_deck_btn.visible = not show_priorities
	admin_deck_btn.visible = not show_priorities
	
	for player in Globals.PLAYERS:
		# For debugging
		if player.get_id() == Globals.MY_ID and player.is_player_union():
			player.get_priorities()
			
		player.toggle_priorities(show_priorities)

func set_visible_prio_voting(visible_voting: bool):
	global_priorities.get_node("SelectedPriority").text = "Selected Priority: " + Globals.active_vote_btn.get_prio_name() if visible_voting else ""
	
	global_priorities.get_node("SelectedPriority").visible = visible_voting
	global_priorities.get_node("Scrapped/VoteScrapBtn").visible = visible_voting
	global_priorities.get_node("Undecided/VoteCancelBtn").visible = visible_voting
	global_priorities.get_node("Approved/VoteApproveBtn").visible = visible_voting
	global_priorities.get_node("Title").visible = not visible_voting

func _on_global_priority_btn_pressed(btn, remote_activation := false):
	if not remote_activation:
		# Nothing happens if it is not your turn
		if Globals.curr_turn != Globals.MY_ID:
			return
		
	# Nothing happens if a vote is in progress
	if null != Globals.active_vote_btn:
		if not Globals.active_vote_btn.get_can_start_vote():
			return
	
	# Nothing happens if you press on a NON undecided prio
	if btn.get_prio_state() != Globals.UNDECIDED_STATE:
		return
	
	# At this point it is undecided, can either cancel
	# action, or start a vote for a "YES" or "NO" for this prio
	Globals.active_vote_btn = btn
	set_visible_prio_voting(true)
	
func _on_global_priority_btn_mouse_entered(btn):
	priority_popup.get_node("PopupText").text = btn.get_hover_text()
	priority_popup.visible = true
	
func _on_global_priority_btn_mouse_exited(btn):
	# If a vote is in progress, do as if we entered the actively voted priority's button, else hide the popup
	if null != Globals.active_vote_btn:
		if not Globals.active_vote_btn.get_can_start_vote():
			_on_global_priority_btn_mouse_entered(Globals.active_vote_btn)
			return
			
	priority_popup.visible = false

func _on_vote_cancel_btn_pressed(remote_activation := false) -> void:
	# If a vote already started, simply add a vote
	if Globals.active_vote_btn.get_can_start_vote():
		Globals.active_vote_btn = null
		set_visible_prio_voting(false)
	else:
		if not remote_activation:
			# Add a vote as long as it's your turn
			if Globals.curr_turn != Globals.MY_ID:
				return

			connectionOutNode.send_vote(Globals.UNDECIDED_STATE)

		add_vote(Globals.UNDECIDED_STATE, remote_activation)

func _on_connection_in_recv_turn_end() -> void:
	#assert(Globals.curr_turn != Globals.MY_ID) # TODO this fails currently as of 11/24 10:30pm
	_on_end_turn(true)

func show_voting_ui(to_show: bool):
	if to_show:
		# Force the 'hover' box to be on - with the actively voted btn's data
		_on_global_priority_btn_mouse_entered(Globals.active_vote_btn)
	
		# Force the 'priorities' screen (toggle on priorities + disable the button)
		if not show_priorities:
			_on_priority_switch_pressed()
		
	priority_switch.disabled = to_show
	# Disable the end turn button - only way to proceed is voting
	end_turn.disabled = to_show
	
	# Different text for admin
	var abstain_text = "Abstain" if Globals.PLAYERS[Globals.MY_ID].is_player_union() else "Leave Undecided"
	var yes_text = "Vote to Approve" if Globals.PLAYERS[Globals.MY_ID].is_player_union() else "Approve Priority"
	var no_text = "Vote to Scrap" if Globals.PLAYERS[Globals.MY_ID].is_player_union() else "Scrap Priority"
	
	global_priorities.get_node("Undecided/VoteCancelBtn").text = abstain_text if to_show else "Cancel Vote"
	global_priorities.get_node("Approved/VoteApproveBtn").text = yes_text if to_show else "Vote to Approve"
	global_priorities.get_node("Scrapped/VoteScrapBtn").text = no_text if to_show else "Vote to Scrap"
	
func start_vote(to_approve: bool, remote_activation := false):
	# Re-init in case of prev data being there
	Globals.active_vote_btn.start_vote()
	
	show_voting_ui(true)
	
	# Only add your vote if you are not the admin, since admin is last
	if Globals.PLAYERS[Globals.curr_turn].is_player_union():
		if to_approve:
			Globals.active_vote_btn.add_player_yes_vote(Globals.curr_turn)
		else:
			Globals.active_vote_btn.add_player_no_vote(Globals.curr_turn)
	Globals.active_vote_btn.set_vote_starter_id(Globals.curr_turn)
	Globals.active_vote_btn.set_vote_to_approve(to_approve)
	
	# Starts a vote, assuming that active_vote_btn has already been set
	if not remote_activation:
		_on_end_turn()

# Vote to add should be one of Globals.UNDECIDED|YES|NO_STATE
func add_vote(vote_to_add: String, remote_activation := false):
	if Globals.UNDECIDED_STATE == vote_to_add:
		Globals.active_vote_btn.add_player_undecided_vote(Globals.curr_turn)
		
	elif Globals.YES_STATE == vote_to_add:
		Globals.active_vote_btn.add_player_yes_vote(Globals.curr_turn)
		
	elif Globals.NO_STATE == vote_to_add:
		Globals.active_vote_btn.add_player_no_vote(Globals.curr_turn)
		
	else:
		print("ERROR! Should never see this with: ", vote_to_add)
		
	# IF we are the admin, finish the voting phase
	if not Globals.PLAYERS[Globals.curr_turn].is_player_union():
		finish_voting(vote_to_add)

	if not remote_activation:
		_on_end_turn()

# Vote to add should be one of Globals.UNDECIDED|YES|NO_STATE
func finish_voting(vote_to_add: String):
	Globals.active_vote_btn.set_prio_state(vote_to_add)
	show_voting_ui(false)
	
	if Globals.UNDECIDED_STATE != vote_to_add:
		# Remove btn from undecided
		var index_to_rm = -1
		for i in range(len(Globals.undecided_priority_btns)):
			var btn = Globals.undecided_priority_btns[i]
			if btn.get_prio_name() == Globals.active_vote_btn.get_prio_name():
				index_to_rm = i
				break
				
		if -1 != index_to_rm:
			Globals.undecided_priority_btns.remove_at(index_to_rm)
			
		# Add btn to appropriate list
		if Globals.YES_STATE == vote_to_add:
			Globals.yes_priority_btns.append(Globals.active_vote_btn)
		elif Globals.NO_STATE == vote_to_add:
			Globals.no_priority_btns.append(Globals.active_vote_btn)
			
		# Re-place buttons
		place_all_global_priorities()
		
	set_visible_prio_voting(false)
	
	# Force next player's turn to be the player after the inital voter
	force_player_turn = Globals.active_vote_btn.get_vote_starter_id() + 1
	if force_player_turn >= len(Globals.PLAYERS):
		force_player_turn = 0
		
	Globals.active_vote_btn = null
	
	# Hide the hover box
	priority_popup.visible = false

func _on_vote_scrap_btn_pressed(remote_activation := false) -> void:
	if not remote_activation:
		# Needs to be your turn for it to do anything
		if Globals.curr_turn != Globals.MY_ID:
			return

		connectionOutNode.send_vote(Globals.NO_STATE)

	# If a vote already started, simply add a vote
	if Globals.active_vote_btn.get_can_start_vote():
		start_vote(false, remote_activation)
	else:
		add_vote(Globals.NO_STATE, remote_activation)

func _on_vote_approve_btn_pressed(remote_activation := false) -> void:
	if not remote_activation:
		# Needs to be your turn for it to do anything
		if Globals.curr_turn != Globals.MY_ID:
			return

		connectionOutNode.send_vote(Globals.YES_STATE)

	# If a vote already started, simply add a vote
	if Globals.active_vote_btn.get_can_start_vote():
		start_vote(true, remote_activation)
	else:
		add_vote(Globals.YES_STATE, remote_activation)
