extends Button

var prio_state = Globals.UNDECIDED_STATE

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func get_prio_state():
	return prio_state
	
func set_prio_state(new_state: String):
	prio_state = new_state

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
