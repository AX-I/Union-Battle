extends Button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_pressed() -> void:
	var req = self.get_node('JoinRequest')
	var serv = self.get_node('ServerAddr').text
	var username = self.get_node('Username').text
	Globals.SERVER_ADDR = serv
	Globals.USERNAME = username
	req.request_completed.connect(_on_request_completed)
	req.request(Globals.SERVER_ADDR + '/?user=' + Globals.USERNAME)
	print('Server ', serv)
	print('User ', username)


func _on_request_completed(result, response_code, headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	print('Server response ', json)
	get_tree().change_scene_to_file("res://Scenes/strike_scene.tscn")
