extends Node

@export var path_tester: PackedScene

const TOTAL_MAPS := 8
const MAIN_PATH_LENGTH := 4

var map_nodes := []
var map_movements := []
var prev_direction := Vector3.ZERO
var path_object = null

var rng = RandomNumberGenerator.new()

func _ready():
	print(path_tester)
	rng.randomize()
	generate_main_path(Vector3.ZERO)
	generate_branching_paths()
	print_map()

func generate_main_path(start_position):
	var current_position = start_position
	map_nodes.append(start_position)
	
	for i in range(1, MAIN_PATH_LENGTH):
		current_position = get_next_position(current_position)
		map_nodes.append(current_position)

func generate_branching_paths():
	var current_maps = map_nodes.size()
	prev_direction = Vector3.ZERO
	while current_maps < TOTAL_MAPS:
		var branch_from = map_nodes[rng.randi_range(0, map_nodes.size() - 1)]
		if can_branch_from(branch_from):
			var new_position = get_next_position(branch_from)
			if not map_nodes.has(new_position):
				map_nodes.append(new_position)
				current_maps += 1

func get_next_position(current_position):
	var possible_directions = [
		Vector3(1, 0, 0),   # Right
		Vector3(0, 0, 1),   # Backward
		Vector3(-1, 0, 0),  # Left
		Vector3(0, 0, -1)   # Forward
	]
	
	if prev_direction != Vector3.ZERO:
		var opposite_direction = -prev_direction
		possible_directions.erase(opposite_direction)
	
	var new_direction = possible_directions[rng.randi() % possible_directions.size()]
	map_movements.append(new_direction)
	prev_direction = new_direction
	return current_position + new_direction

func can_branch_from(branch_position):
	return true
	
func print_map():
	var node_size = 1
	for i in range(0, map_nodes.size() -1):
		var path_instance = path_tester.instantiate()
		var scaler = path_instance.get_child(0).get_child(0).scale
		var node = map_nodes[i]
		var direction_moved = map_movements[i]
		if direction_moved == Vector3(1,0,0) or direction_moved == Vector3(-1,0,0):
			node_size = scaler.x
		elif direction_moved == Vector3(0,0,1) or direction_moved == Vector3(0,0,-1):
			node_size = scaler.z 
		path_instance.global_position = node * node_size * 1.1
		add_child(path_instance)
