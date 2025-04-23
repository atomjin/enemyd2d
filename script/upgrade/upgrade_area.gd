extends Area3D

@onready var player = get_tree().get_first_node_in_group("player")
var allowupgrade = false

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("upgrade") and not allowupgrade:
			if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
				player.menu_set_close()
				hide()
				print("Capture")
			else:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
				player.menu_set_open()
				show()
				print("Menu")

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		player.upgrade_label_show()
		allowupgrade = true

func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		player.upgrade_label_hide()
		allowupgrade = false
