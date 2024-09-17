extends CharacterBody2D


const SPEED : float = 300.0
const JUMP_VELOCITY : float = -200.0
const GRAVITY : float = 500.0


func _physics_process(delta):
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	
	if global_position.y > 100:
		game_over()
	
func game_over():
	get_tree().reload_current_scene()
