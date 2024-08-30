extends Node3D

var record_interval = 1.0 / 60.0  # Record every frame at 60 FPS
var timer = 0.0
var rewinding = false
var history = RingBuffer.new(300)

@export var player: CharacterBody3D
@export var ground: StaticBody3D
@export var pathing: PackedScene

var objects_to_track = []

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	objects_to_track.append(player)

func _process(delta):
	timer += delta
	if rewinding:
		if history.size() > 0:
			var state = history.pop_last()
			restore_state(state)
			if history.size() == 0:
				rewinding = false
		return

	if timer >= record_interval:
		timer = 0.0
		var state = capture_state()
		history.add_item(state)  # Ensure this method matches your RingBuffer's

func _input(event):
	if event.is_action_pressed("rewind") and not rewinding:
		rewinding = true
	elif event.is_action_pressed("ui_cancel"):
		get_tree().quit()

func capture_state():
	var state = {}
	for obj in objects_to_track:
		state[obj.name] = {
			"position": obj.global_transform.origin,
			"rotation": obj.rotation,
			#"velocity": obj.linear_velocity  # Assuming velocity is being managed; add this if applicable
		}
	return state

func restore_state(state):
	for obj_name in state.keys():
		var obj = get_node_or_null(obj_name)
		if obj:
			obj.position = state[obj_name]["position"]
			obj.set("rotation", state[obj_name]["rotation"])  # Safely set the attribute if it exists
