extends Control

@onready var player = get_tree().get_first_node_in_group("player")
@onready var balance_label: Label = $Main/Balance
@onready var alert_label: Label = $AlertLabel
var inupgrade = false

var current_money

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_balance()

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("upgrade"):
		inupgrade = player.inupgrade_area
		if inupgrade:
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
		else:
			pass

func update_balance():
	current_money = player.balance()
	balance_label.text = str(current_money)

func _on_back_pressed() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	player.menu_set_close()
	hide()

func alert():
	alert_label.show()
	await get_tree().create_timer(0.8).timeout
	alert_label.hide()
