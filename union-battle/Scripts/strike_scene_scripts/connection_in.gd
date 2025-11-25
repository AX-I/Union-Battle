extends HTTPRequest

var serv = Globals.SERVER_ADDR
var uname = Globals.USERNAME
var ti

var syncData = {}

signal recv_turn_end

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ti = Timer.new()
	add_child(ti)
	ti.wait_time = 0.5
	ti.one_shot = true
	ti.timeout.connect(fetchUpdates)
	ti.start()

	self.timeout = 0.5
	self.request_completed.connect(_on_request_completed)

func fetchUpdates():
	var target = Globals.SERVER_ADDR + '/fetch?user=' + Globals.USERNAME
	var err = self.request(target)
	if err:
		push_error('Connection error')

func _on_request_completed(result, response_code, _headers, body):
	if result != HTTPRequest.RESULT_SUCCESS:
		push_error('Connection error')
		return
	if response_code == 400:
		push_error('Bad request')
		return
	var json = JSON.parse_string(body.get_string_from_utf8())
	if Globals.MY_ID == 0:
		print('Server response ', json)
	syncPlayers(json)
	ti.start()

func syncPlayers(data):
	for k in data:
		var pid = int(k)
		if pid == Globals.MY_ID:
			continue
		if pid not in syncData:
			syncData[pid] = {'endTurn':'-1'}
		var pdata = data[k]
		var plabel = Globals.PLAYERS[pid].get_node('PlayerLabel')
		plabel.text = pdata['user']
		if 'endTurn' in pdata:
			if syncData[pid]['endTurn'] != pdata['endTurn']:
				# Someone's turn end
				syncData[pid]['endTurn'] = pdata['endTurn']
				syncOnePlayer(pid, pdata)
				emit_signal('recv_turn_end')

func syncOnePlayer(pid: int, pdata: Dictionary):
	if 'actions' in pdata:
		for act in pdata['actions']:
			if 'card' in act:
				var card = PlayingCard.new_card_from_data(act['card'])
				var targ_id = act['target']
				Globals.PLAYERS[targ_id].adjust_stats(card)
				card.queue_free()
			elif 'vote' in act:
				syncVote(pid, act)
	if 'data' in pdata:
		Globals.PLAYERS[pid].set_stats(pdata['data']['stats'])

func syncVote(pid, act):
	var strikeNode = self.get_parent()

	for btn in strikeNode.undecided_priority_btns:
		#print('btn name ', btn.get_prio_name(), ' act name ', act['priority'])
		if btn.get_prio_name() == act['priority']:
			#print(' match!')
			strikeNode._on_global_priority_btn_pressed(btn, true)

	if act['vote'] == Globals.YES_STATE:
		strikeNode._on_vote_approve_btn_pressed(true)
	elif act['vote'] == Globals.NO_STATE:
		strikeNode._on_vote_scrap_btn_pressed(true)
	elif act['vote'] == Globals.UNDECIDED_STATE:
		strikeNode._on_vote_cancel_btn_pressed(true)
