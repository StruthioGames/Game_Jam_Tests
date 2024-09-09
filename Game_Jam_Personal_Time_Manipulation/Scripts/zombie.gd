extends CharacterBody3D

@export var player_path = "../Player"

@onready var nav_agent = $NavigationAgent3D
@onready var anim_tree = $AnimationTree

const SPEED = 4.0
const ATTACK_RANGE = 2.1

var health = 6

var player = null
var state_machine
var look_target

var rng = RandomNumberGenerator.new()

signal zombie_dead

func _ready():
	print(player_path)
	player = get_node(player_path)
	state_machine = anim_tree.get("parameters/playback")
	
func _process(delta):
	velocity = Vector3.ZERO
	
	match state_machine.get_current_node():
		"Run":
			nav_agent.set_target_position(player.global_transform.origin)
			var next_nav_point = nav_agent.get_next_path_position()
			velocity = (next_nav_point - global_transform.origin).normalized() * SPEED
			look_target = Vector3(global_transform.origin.x + velocity.x, 
									global_transform.origin.y, 
									global_transform.origin.z + velocity.z)
			rotation.y = lerp_angle(rotation.y, atan2(-velocity.x, -velocity.z), delta * 10)
			
		"Attack":
			look_target = Vector3(player.global_position.x, global_transform.origin.y, player.global_position.z)
			look_at(look_target, Vector3.UP)
			
	anim_tree.set("parameters/conditions/attack", _target_in_range())
	anim_tree.set("parameters/conditions/run", !_target_in_range())
	
	anim_tree.get("parameters/playback")
	
	move_and_slide()
	
func _target_in_range():
	return global_transform.origin.distance_to(player.global_position) < ATTACK_RANGE
	
func _hit_finished():
	if global_transform.origin.distance_to(player.global_position) < ATTACK_RANGE + .5:
		var dir = global_transform.origin.direction_to(player.global_position)
		player.hit(dir)

func _on_area_3d_body_part_hit(dam):
	health -= dam
	if health <= 0:
		queue_free()
		print("killed")
		emit_signal("zombie_dead")
		print("sent")
