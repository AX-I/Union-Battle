extends HTTPRequest

var serv = Globals.SERVER_ADDR
var uname = Globals.USERNAME

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.timeout = 0.5
	self.request_completed.connect(_on_request_completed)

func _on_strike_scene_send_end_my_turn() -> void:
	var time = int(Time.get_unix_time_from_system())

	var pinfo = Globals.PLAYERS[Globals.MY_ID].get_stats();
	var body = JSON.stringify({'stats':pinfo})

	var target = Globals.SERVER_ADDR + '/update?id=' + str(Globals.MY_ID)
	target += '&endTurn=' + str(time)
	var err = self.request(target, [], HTTPClient.METHOD_POST, body)
	if err:
		push_error('Connection error')

func _on_card_played(card, player_ref) -> void:
	print('card ', card)
	var pinfo = {'e': card.get_engagement(), 'r':card.get_risk()}
	var body = JSON.stringify(
		{'card':pinfo, 'target': player_ref.get_id()}
	)

	var target = Globals.SERVER_ADDR + '/action?id=' + str(Globals.MY_ID)
	var err = self.request(target, [], HTTPClient.METHOD_POST, body)
	if err:
		push_error('Connection error')

func send_vote(vote) -> void:
	print('vote ', vote)
	var body = JSON.stringify({'vote':vote})

	var target = Globals.SERVER_ADDR + '/action?id=' + str(Globals.MY_ID)
	var err = self.request(target, [], HTTPClient.METHOD_POST, body)
	if err:
		push_error('Connection error')

func _on_request_completed(result, _response_code, _headers, _body):
	if result != HTTPRequest.RESULT_SUCCESS:
		push_error('Connection error')
		return
