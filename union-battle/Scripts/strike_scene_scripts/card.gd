@tool
class_name PlayingCard extends Area2D

# The two stats that each card can affect
var _engagement: 		int 				= 0
var _risk:				int 				= 0

# Child objects of a playing card
var _tex: 				Sprite2D			= Sprite2D.new()
var _collision: 		CollisionShape2D 	= CollisionShape2D.new()
var _rect: 				RectangleShape2D 	= RectangleShape2D.new()

# Important fields of a card
var _starting_pos: 		Vector2 	 		= Vector2(0, 0)
var _player_id:			int					= 0
var _card_name:			String				= "Unknown"
var _movement_offset:	Vector2				= Vector2(0.0, 0.0)
var _player_ref:		StaticBody2D		= null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	# Setting the scale
	self.scale = Globals.CARD_SCALE

	# Calling a set sprite to get a default sprite
	set_sprite("")

	# Setting the sprite
	_tex.global_position 			 = self.global_position
	add_child(_tex)
	
	# Setting the collision shape to a rectangle shape
	_rect.size 						 = _tex.texture.get_size()
	_collision.shape 				 = _rect

	# Adding the collision shape
	#collision.debug_color			 = Color(0, 0, 0, 0.5)
	_collision.global_position 		 = self.global_position
	add_child(_collision)

	# Attaching signals
	self.connect("mouse_entered", Callable(self, "_on_mouse_entered"))
	self.connect("mouse_exited", Callable(self, "_on_mouse_exited"))
	self.connect("body_entered", Callable(self, "_on_body_entered"))
	self.connect("body_exited", Callable(self, "_on_body_exited"))

# Called when an input event occurs
func _input(event: InputEvent) -> void:

	# If there is a mouse event then deal with it
	if event is InputEventMouseButton:

		# If the mouse event is left mouse button then deal with it
		if event.button_index == MOUSE_BUTTON_LEFT:
			if Globals.curr_turn != Globals.MY_ID:
				return
			if not Globals.PLAYERS[Globals.MY_ID].is_alive():
				return
			# Checking if the object is picked up or not
			if event.is_pressed() and Globals.picked_up_name != "":
				Globals.picked_up 	   = true
			else:
				Globals.picked_up 	   = false

			# Setting the drag offset
			_movement_offset = get_global_mouse_position() - self.global_position

			# If the item is picked up make sure it always appears on top
			if Globals.picked_up:
				self.z_index = 1000
			else:
				self.z_index = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:

	# Checking if the cards are being interacted with in the right turn order
	if (Globals.curr_turn == _player_id and
		Globals.curr_turn == Globals.MY_ID and
		Globals.PLAYERS[_player_id].is_alive()):

		# If the card is picked up then move it by its calculated offset
		if Globals.picked_up and Globals.picked_up_name == self.name:
			self.global_position = get_global_mouse_position() - self._movement_offset

		# If the card is dropped on a player then apply stats and discard it
		if _player_ref != null and not Globals.picked_up:
			if _player_ref.is_in_group("player_group"):
				var connOut = get_node('/root/StrikeScene/ConnectionOut')
				connOut._on_card_played(self, _player_ref)

				_player_ref.adjust_stats(self)
				get_parent().discard_card(self)

# Called to set the value of a card
func setup_card(
	new_player_id: 		int,
	new_egmt: 	   		int,
	new_risk: 	   		int,
	new_start_pos: 		Vector2,
	sprite_name:		String,
	sprite_img:			String
) -> void:

	# Setting each of the fields
	_player_id 		= new_player_id
	_engagement 	= new_egmt
	_risk 			= new_risk
	_starting_pos 	= new_start_pos
	_card_name 		= sprite_name

	# Setup the sprite image
	set_sprite(sprite_img)

	# Send the card to its starting position
	self.to_start_pos()

# Setter for the ingredient sprite
func set_sprite(
	sprite_image_name:  String
) -> void:

	# File path for texture
	print("Path to Image: %s" % sprite_image_name)

	# If the file path exists then load it as a texture
	if ResourceLoader.exists("res://Assets/"+sprite_image_name):
		_tex.texture = load("res://Assets/"+sprite_image_name)

	# Use the default sprite if no file path exists
	else:
		_tex.texture = load("res://Assets/delete_later.JPG")

	# Setting the collision shape to a rectangle shape
	_rect.size 		 = _tex.texture.get_size()
	_collision.shape = _rect

# This function triggers if the mouse hovers an ingredient
func _on_mouse_entered() -> void:

	# Only consider if the card belongs to the player
	if Globals.MY_ID == _player_id:

		# We only want to do starting pickup changes if the item is not picked up
		if not Globals.picked_up:

			# Setting the scale large to indicate hovering
			Globals.picked_up_name = self.name
			self.scale	   		   = Globals.CARD_SCALE_HOVER

# This function triggers if the mouse stops hovering an ingredient
func _on_mouse_exited() -> void:

	# Only consider if the card belongs to the player
	if Globals.MY_ID == _player_id:

		# If we haven't dropped the item yet then amend this
		if Globals.picked_up and Globals.picked_up_name == self.name:
			self.global_position   = get_global_mouse_position() - self._movement_offset

		# Just shrink the item if we are hovering an object already
		elif Globals.picked_up_name != self.name:
			self.scale     		   = Globals.CARD_SCALE

		# We only want to do the dropped item operations if we have actually dropped it
		else:

			# Setting the scale smaller to indicate no longer hovering
			Globals.picked_up_name = ""
			self.scale     		   = Globals.CARD_SCALE

# This function triggers if a card touches a player icon
func _on_body_entered(
	body: Node2D
) -> void:

	# If the body is an appliance then change its colour
	if body.is_in_group("player_group"):
		body.modulate = Color(0.0, 1.0, 0.0, 0.5)
		_player_ref   = body

# This function triggers if a card exits a player icon
func _on_body_exited(
	body: Node2D
) -> void:

	# If the body is an appliance then revert its colour
	if body.is_in_group("player_group"):
		body.modulate = Color(1.0, 1.0, 1.0, 1.0)
		_player_ref   = null

# Getter for starting position
func get_start_pos() -> Vector2:
	return _starting_pos

# Setter for the ingredient starting position
func set_start_pos(
	start: Vector2
) -> void:
	_starting_pos = start

# Function that returns the ingredient to its starting position
func to_start_pos() -> void:
	self.global_position = _starting_pos

# Getter for the engagement
func get_engagement() -> int:
	return _engagement

# Getter for the risk
func get_risk() -> int:
	return _risk

# Getter for the ID
func get_id() -> int:
	return _player_id

# Setter for the ID
func set_id(
	new_id: int
) -> void:
	_player_id = new_id

# Getter for the name
func get_card_name() -> String:
	return _card_name
