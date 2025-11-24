extends Button

var prio_state = Globals.UNDECIDED_STATE
var prio_name  = ""

# Used for when "voting" on this priority
# ========================================
# id of player who started the vote
var vote_starter_id = -1

# If true, means we are voting for "yes" else we are voting for "no"
var vote_to_approve = false

# Array of ids, of players that votes yes/no/undecided
var no_votes 		= []
var yes_votes 		= []
var undecided_votes = []

var can_start_vote  = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func start_vote():
	no_votes 		= []
	yes_votes 		= []
	undecided_votes = []
	vote_starter_id = -1
	can_start_vote  = false

func get_prio_state():
	return prio_state
	
func get_prio_name():
	return prio_name
	
func get_vote_starter_id():
	return vote_starter_id
	
func get_num_votes():
	return len(no_votes) + len(yes_votes) + len(undecided_votes)
	
func get_can_start_vote():
	return can_start_vote
	
func get_hover_text():
	var voting_for_text = ""
	var started_by_text = "Vote started by: "
	if -1 != vote_starter_id:
		started_by_text += Globals.PLAYERS[vote_starter_id].get_player_name()
		if vote_to_approve:
			voting_for_text = ", wants this priority Approved"
		else:
			voting_for_text = ", wants this priority Scrapped" 
	else:
		started_by_text += "No one yet"
		
	var state_text      = ""
	if Globals.UNDECIDED_STATE == prio_state:
		state_text      = "Undecided"
	elif Globals.YES_STATE == prio_state:
		state_text      = "Approved" 
	elif Globals.NO_STATE == prio_state:
		state_text      = "Scrapped"
		
	var yes_votes_text  = ""
	var no_votes_text   = ""
	var und_votes_text  = ""
	
	for p_id in yes_votes:
		yes_votes_text  += Globals.PLAYERS[p_id].get_player_name() + ", "
	# Strip last comma and space
	if yes_votes_text.length() > 0:
		yes_votes_text 	= yes_votes_text.left(yes_votes_text.length() - 2)
	else:
		yes_votes_text	= "No one"
		
	for p_id in no_votes:
		no_votes_text 	+= Globals.PLAYERS[p_id].get_player_name() + ", "
	# Strip last comma and space
	if no_votes_text.length() > 0:
		no_votes_text 	= no_votes_text.left(no_votes_text.length() - 2)
	else:
		no_votes_text	= "No one"
	
	for p_id in undecided_votes:
		und_votes_text  += Globals.PLAYERS[p_id].get_player_name() + ", "
	# Strip last comma and space
	if und_votes_text.length() > 0:
		und_votes_text	= und_votes_text.left(und_votes_text.length() - 2)
	else:
		und_votes_text	= "No one"
	
	return( prio_name + ": " + state_text + "\n" +
			started_by_text  + voting_for_text + "\n" +
			"Voted to Approve: " + yes_votes_text + "\n" +
			"Voted to Scrap: " + no_votes_text + "\n" +
			"Voted to Abstain: " + und_votes_text + "\n"
		  )
	
func set_prio_state(new_state: String):
	prio_state = new_state
	can_start_vote = true if Globals.UNDECIDED_STATE == new_state else false
	
func set_prio_name(priority: String):
	prio_name = priority
	
func set_vote_starter_id(player_id: int):
	vote_starter_id = player_id
	
func set_vote_to_approve(to_approve: bool):
	vote_to_approve = to_approve
	
func add_player_no_vote(player_id: int):
	no_votes.append(player_id)
	
func add_player_yes_vote(player_id: int):
	yes_votes.append(player_id)
	
func add_player_undecided_vote(player_id: int):
	undecided_votes.append(player_id)
	
func has_player_voted(player_id: int) -> bool:
	for id in no_votes + yes_votes + undecided_votes:
		if id == player_id:
			return true
	return false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
