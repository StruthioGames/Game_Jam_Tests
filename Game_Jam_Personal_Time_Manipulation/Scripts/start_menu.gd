extends Control

@export var main_scene: PackedScene

func _on_start_game_pressed():
	SceneSwitcher.switch_scene(main_scene.get_path())
