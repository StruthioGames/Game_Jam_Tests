extends Node3D

@export var zombie_scene: PackedScene

@onready var player = $NavigationRegion3D/Player
@onready var hit_rect = $Control/ColorRect
@onready var nav_region = $NavigationRegion3D

var zombie = load("res://Scenes/zombie.tscn")
var new_zombie

const SAFE_SPAWN_DISTANCE = 3.0

func _on_player_player_hit():
	hit_rect.visible = true
	await get_tree().create_timer(.02).timeout
	hit_rect.visible = false
	
func _on_zombie_zombie_dead():
	spawn_new_zombie()

func spawn_new_zombie():
	var spawn_position = find_spawn_position()
	if spawn_position:
		var new_zombie = zombie_scene.instantiate()
		new_zombie.global_transform.origin = spawn_position
		nav_region.add_child(new_zombie)
		var callable = Callable(self, "_on_zombie_zombie_dead")
		new_zombie.connect("zombie_dead", callable)

func find_spawn_position():
	for i in range(100):  # Try up to 100 times to find a valid spawn location
		var random_point = global_transform.origin + Vector3(Vector3(randf_range(-9, 9), 0, randf_range(-4, 4)))
		print(random_point)
		if random_point.distance_to(player.global_transform.origin) > SAFE_SPAWN_DISTANCE:
			return random_point
	return Vector3(0, 0, 0)


