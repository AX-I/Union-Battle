extends HTTPRequest

# Timer for polling
var timer: Timer = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	# Instantiating the timer for polling
	timer = Timer.new()
	add_child(timer)

	# Setting timer parameters and starting it
	timer.wait_time = 0.5
	timer.one_shot = true
	timer.timeout.connect(fetchUpdates)
	timer.start()

	# Setting rest of HTTPRequest parameters
	self.timeout = 0.5
	self.request_completed.connect(_on_request_completed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

# Called to fetch updates from the server
func fetchUpdates():

	# Getting the server address
	var target = Globals.SERVER_ADDR + '/fetch?user=' + Globals.USERNAME

	# Sending poll request and verifying errors
	var err = self.request(target)
	if err:
		push_error('Connection error')

func _on_request_completed(result, response_code, _headers, body):

	# If the result is not a success return such
	if result != HTTPRequest.RESULT_SUCCESS:
		push_error('Connection error')
		return

	# If the result is a bad request return such
	if response_code == 400:
		push_error('Bad request')
		return

	# Parsing the returned request as a JSON
	var json = JSON.parse_string(body.get_string_from_utf8())
	if Globals.MY_ID == 0:
		print('Server response ', json)

	# Storing the number of players
	Globals.NUM_PLAYERS_WAITING = len(json)

	# Restart the polling timer
	timer.start()
