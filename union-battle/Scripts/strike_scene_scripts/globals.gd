extends Node


# JSON paths
const UNIONIST_CARD_JSON: 	String 		= "res://Scripts/card_info/union_cards.json"
const ADMIN_CARD_JSON: 		String 		= "res://Scripts/card_info/admin_cards.json"
const PLAYER_POS_JSON:		String		= "res://Scripts/card_info/player_positions.json"

# For priority btns
const UNDECIDED_STATE 					= "undecided"
const NO_STATE 							= "no"
const YES_STATE 							= "yes"

# Player list
var PLAYERS:				Array		= []
var PLAYER_COORDS: Array = [
	Vector2(580, 580), Vector2(1090,306), Vector2(580, 60), Vector2(50, 306)
]

# The coordinate positions for each player cards
var CARD_COORD_SETS:		Array		= [ 
											[Vector2(462,595), Vector2(462,475), Vector2(582,475), Vector2(702,475), Vector2(702,595)],
											[Vector2(1110,186), Vector2(990,186), Vector2(990,306), Vector2(990,426), Vector2(1110,426)],
											[Vector2(462,60), Vector2(462,180), Vector2(582,180), Vector2(702,180), Vector2(702,60)],
											[Vector2(60,186), Vector2(180,186), Vector2(180,306), Vector2(180,426), Vector2(60,426)]
										  ]

# Off screen coordinates
const OFF_SCREEN:			Vector2		= Vector2(10000, 10000)

# Unused card ID
const UNUSED_CARD_ID:		int			= -1

# Different scale values for the cards (ADJUST WHEN REAL ART IS IN)
const CARD_SCALE:			Vector2		= Vector2(0.15, 0.15)
const CARD_SCALE_HOVER:		Vector2		= Vector2(0.20, 0.20)

# Values that determine if a player has picked up a card
var picked_up:				bool		= false
var picked_up_name:			String		= ""

# Values controlling current turn
var curr_turn:				int			= 0
var drew_this_turn:			bool		= false
# Will hold the global_priority.tscn instance
# for the one that is currently being voted on
var active_vote_btn 					= null

# Player count
var PLAYER_COUNT:			int			= 0


# Networked Multiplayer
var SERVER_ADDR: String = ""
var USERNAME: String = ""
var MY_ID: int = -1

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
