extends Button

# Constants for button text
const WAITING_LABEL:		String	= "%s/4 Players"
const JOIN_LABEL:			String	= "Join Game"

# Current player count and the threshold to let players join the game
var curr_player_count:		int		= 0
const PLAYER_THRESHOLD:		int		= 4

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.disabled = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:

	# Change the label if the number of queued players has changed
	if Globals.NUM_PLAYERS_WAITING != curr_player_count:

		# Re-labeling the button
		curr_player_count = Globals.NUM_PLAYERS_WAITING
		self.text		  = WAITING_LABEL % str(curr_player_count)

	# Enable the button if enough players are playing
	if curr_player_count >= PLAYER_THRESHOLD and self.text.contains("Players"):

		# Re-enabling and labeling the button
		self.disabled = false
		self.text	  = JOIN_LABEL

# Called to change scenes
func _on_button_down() -> void:

	# If there are not four players do not start the game
	if curr_player_count < PLAYER_THRESHOLD:
		return

	# If all the players are queued then the game can be played
	else:

		# Switching to the game scene
		get_tree().change_scene_to_file("res://Scenes/strike_scene.tscn")
 
