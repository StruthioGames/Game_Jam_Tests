extends Node

@export var next_turn_delay : float = 1.0
@export var player_char : Node
@export var enemy_char : Node

var game_over : bool = false

var cur_char : Character

signal character_begin_turn(character)
signal character_end_turn(character)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	begin_next_turn()

func begin_next_turn():
	if cur_char == player_char:
		cur_char = enemy_char
	elif cur_char == enemy_char:
		cur_char = player_char
	else:
		cur_char = player_char
	emit_signal("character_begin_turn", cur_char)
	
func end_current_turn():
	emit_signal("character_end_turn", cur_char)
	await get_tree().create_timer(next_turn_delay).timeout
	
	if game_over == false:
		begin_next_turn()
		
func character_died (character):
	game_over = true
	
	if character.is_player == true:
		print("Game Over")
	else:
		print("You Win!")
