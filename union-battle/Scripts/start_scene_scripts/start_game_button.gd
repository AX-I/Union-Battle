extends Button

const CONN_ERR_STR = 'Error connecting to server\nPlease run `python UBServer.py` outside of Godot'
const CONN_CHECK = 'Checking connection in new tab'

var conn_success = false;

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
	Globals.SERVER_ADDR = serv.trim_suffix('/')
	Globals.USERNAME = username
	req.request_completed.connect(_on_request_completed)
	req.timeout = 1

	var target = Globals.SERVER_ADDR
	if conn_success:
		target += '/join?user=' + Globals.USERNAME
	print('Server ', serv)
	print('User ', username)
	var err = req.request(target)
	if err:
		push_GUI_error(CONN_ERR_STR)

# https://stackoverflow.com/questions/74333504/how-to-redirect-to-a-website-in-godot-web
func check_connection():
	var cmd = "window.open('" + Globals.SERVER_ADDR + "', '_blank').focus();"
	if OS.has_feature('web'):
		print('running ', cmd)
		JavaScriptBridge.eval(cmd)

func _on_request_completed(result, response_code, _headers, body):
	if result != HTTPRequest.RESULT_SUCCESS:
		print(CONN_CHECK)
		check_connection()
		push_GUI_error(CONN_ERR_STR)
		return
	if response_code == 400:
		push_GUI_error(body.get_string_from_utf8())
		return
	if not conn_success:
		conn_success = true
		self.text = 'Join Game'
		return
	var json = JSON.parse_string(body.get_string_from_utf8())
	print('Server response ', json)
	Globals.MY_ID = json['id']
	Globals.R_SEED = json['seed']
	Globals.NUM_PLAYERS_WAITING = json['id'] + 1
	get_tree().change_scene_to_file("res://Scenes/connect_scene.tscn")
