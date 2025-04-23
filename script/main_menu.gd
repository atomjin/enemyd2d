extends CanvasLayer

@onready var anim_player = $Background/Gabriel/AnimationPlayer
@onready var main_scene = preload("res://scene/main.tscn")

func _on_exit_bt_pressed() -> void:
	get_tree().quit()

func _on_start_bt_pressed() -> void:
	get_tree().change_scene_to_packed(main_scene)

func _on_start_bt_mouse_entered() -> void:
	anim_player.play("terrified", 0.5)


func _on_start_bt_mouse_exited() -> void:
	anim_player.play("idle", 0.5)


func _on_exit_bt_mouse_entered() -> void:
	anim_player.play("waving", 0.5)


func _on_exit_bt_mouse_exited() -> void:
	anim_player.play("idle", 0.5)
