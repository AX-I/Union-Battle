extends RichTextLabel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	# Changing the role text based on what role the player is
	if Globals.NUM_PLAYERS_WAITING < 4:
		self.text = "[center]Your Roll: [u]Unionist[/u][/center]"
	else:
		self.text = "[center]Your Roll: [u]Admin[/u][/center]"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
