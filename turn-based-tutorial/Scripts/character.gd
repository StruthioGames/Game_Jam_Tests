extends Node2D
class_name Character

@export var is_player : bool
@export var cur_hp : int = 25
@export var max_hp : int = 25

@export var combat_actions : Array
@export var opponent : Node

@export var visual : Texture2D
@export var flip_visual : bool 

@onready var sprite = $Sprite2D
@onready var health_bar : ProgressBar = $HealthBar
@onready var health_text : Label = $HealthBar/HealthText


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite.texture = visual
	sprite.flip_h = flip_visual
	
	health_bar.max_value = max_hp
	get_node("/root/BattleScene").character_begin_turn.connect(_on_character_begin_turn)

func take_damage (damage):
	cur_hp -= damage
	_update_health_bar()
	
	if cur_hp <= 0:
		get_node("/root/BattleScene").character_died(self)
		queue_free()

func heal(amount):
	cur_hp += amount
	
	if cur_hp >= max_hp:
		cur_hp = max_hp
	
	_update_health_bar()
	
func _update_health_bar ():
	health_bar.value = cur_hp
	health_text.text = str(cur_hp, " / ", max_hp)
	
func _on_character_begin_turn(character):
	if character == self and is_player == false:
		_decide_combat_action()

func cast_combat_action(action):
	if action.damage > 0:
		opponent.take_damage(action.damage)
	elif action.heal > 0:
		heal(action.heal)
	get_node("/root/BattleScene").end_current_turn()

func _decide_combat_action():
	var health_percent = float(cur_hp) / float(max_hp)
	
	for i in combat_actions:
		var action = i as CombatAction
		if action.heal > 0:
			if randf() > health_percent + 0.2:
				cast_combat_action(action)
				return
			else: 
				continue
		else:
			cast_combat_action(action)
			return
