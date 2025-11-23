extends Button

const CONN_ERR_STR = 'Error connecting to server\nPlease run `python UBServer.py` outside of Godot'

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func push_GUI_error(msg):
	self.get_node('ErrorLabel').text = msg
	var ti = Timer.new()
	add_child(ti)
	ti.wait_time = 5
	ti.one_shot = true
	ti.start()
	ti.timeout.connect(reset_GUI_error)

func reset_GUI_error():
	self.get_node('ErrorLabel').text = ''

func _on_pressed() -> void:
	var req = self.get_node('JoinRequest')
	var serv = self.get_node('ServerAddr').text
	var username = self.get_node('Username').text
	Globals.SERVER_ADDR = serv
	Globals.USERNAME = username
	req.request_completed.connect(_on_request_completed)
	req.timeout = 1

	var target = Globals.SERVER_ADDR + '/join?user=' + Globals.USERNAME
	print('Server ', serv)
	print('User ', username)
	var err = req.request(target)
	if err:
		push_GUI_error(CONN_ERR_STR)

func _on_request_completed(result, response_code, headers, body):
	if result != HTTPRequest.RESULT_SUCCESS:
		push_GUI_error(CONN_ERR_STR)
		return
	if response_code == 400:
		push_GUI_error(body.get_string_from_utf8())
		return
	var json = JSON.parse_string(body.get_string_from_utf8())
	print('Server response ', json)
	Globals.MY_ID = json['id']
	get_tree().change_scene_to_file("res://Scenes/strike_scene.tscn")
