extends Node


# JSON paths
const UNIONIST_CARD_JSON: 	String 		= "res://Scripts/card_info/union_cards.json"
const ADMIN_CARD_JSON: 		String 		= "res://Scripts/card_info/admin_cards.json"
const PLAYER_POS_JSON:		String		= "res://Scripts/card_info/player_positions.json"

# Off screen coordinates
const OFF_SCREEN:			Vector2		= Vector2(10000, 10000)

# Unused card ID
const UNUSED_CARD_ID:		int			= 0

# Different scale values for the cards (ADJUST WHEN REAL ART IS IN)
const CARD_SCALE:			Vector2		= Vector2(0.15, 0.15)
const CARD_SCALE_HOVER:		Vector2		= Vector2(0.20, 0.20)

# Values that determine if a player has picked up a card
var picked_up:				bool		= false
var picked_up_name:			String		= ""

# Values controlling current turn
var curr_turn:				int			= 1
var drew_this_turn:			bool		= false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
