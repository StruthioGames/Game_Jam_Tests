extends Node3D

@export var player: CharacterBody3D
@export var camera: Camera3D
@export var ground: StaticBody3D

var record_interval = 1.0 / 60.0  # Record every frame at 60 FPS
var timer = 0.0
var rewinding = false
var history = RingBuffer.new(300)

var objects_to_track = []

func _ready():
	objects_to_track.append(player)
	DungeonPathing.generate_dungeon(player.global_transform.origin)

func _process(delta):
	player.rotation.x = clamp(rotation.x, -1, 1)
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
		history.add_item(state)

func _input(event):
	if event.is_action_pressed("rewind") and not rewinding:
		rewinding = true

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
			obj.set("rotation", state[obj_name]["rotation"])
