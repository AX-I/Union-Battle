extends Node


# JSON paths
const UNIONIST_CARD_JSON: 	String 		= "res://Scripts/card_info/union_cards.json"
const ADMIN_CARD_JSON: 		String 		= "res://Scripts/card_info/admin_cards.json"
const PLAYER_POS_JSON:		String		= "res://Scripts/card_info/player_positions.json"

# For priority btns
const UNDECIDED_STATE 					= "undecided"
const NO_STATE 							= "no"
const YES_STATE 						= "yes"

# Player list
var PLAYERS:				Array		= []
var PLAYER_COORDS: Array = []

# The coordinate positions for each player cards
var CARD_COORD_SETS:		Array		= []

# Off screen coordinates
const OFF_SCREEN:			Vector2		= Vector2(10000, 10000)

# Unused card ID
const UNUSED_CARD_ID:		int			= -1

# Different scale values for the cards (ADJUST WHEN REAL ART IS IN)
const CARD_SCALE:			Vector2		= Vector2(0.25, 0.25)
const CARD_SCALE_HOVER:		Vector2		= Vector2(0.30, 0.30)

# Values that determine if a player has picked up a card
var picked_up:				bool		= false
var picked_up_name:			String		= ""

# Values controlling current turn
var curr_turn:				int			= 0
var drew_this_turn:			bool		= false
# Will hold the global_priority.tscn instance
# for the one that is currently being voted on
var active_vote_btn 					= null

# Player count for the game and for the waiting room
var PLAYER_COUNT:			int			= 0
var NUM_PLAYERS_WAITING:	int			= 0

# Networked Multiplayer
var SERVER_ADDR: String = ""
var USERNAME: String = ""
var MY_ID: int = -1

var R_SEED: int = -1

func get_all_priorities() -> Array:
	# Returns an array of all priorities for all unionists combined, with no duplicates
	var ret = []
		
	for player in PLAYERS:
		if player.is_player_union():
			for priority in player.get_priorities():
				if priority not in ret:
					ret.append(priority)
				
	return ret 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
