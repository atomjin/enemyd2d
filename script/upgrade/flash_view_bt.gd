extends TextureButton

@export var price: int = 2000  # Set the price of the upgrade in the Inspector
@onready var player = get_tree().get_first_node_in_group("player")

enum ButtonState { LOCKED, NORMAL }
var state = ButtonState.LOCKED

func _ready():
	update_button_texture()
	$"../FlashViewLabel".text = str(price)

func _on_pressed():
	match state:
		ButtonState.LOCKED:
			if player.current_money >= price:
				state = ButtonState.NORMAL
				player.current_money -= price
				print("Upgrade unlocked!")
				$"../..".update_balance()
				$"../FlashViewLabel".hide() 
				$"../../../Main/Flash_Bar".show()
			else:
				$"../..".alert()
				print("Not enough balance!")
	player.update_money()
	update_button_texture()

func update_button_texture():
	match state:
		ButtonState.LOCKED:
			texture_normal = load("res://ui/Upgrade/Flashlight-Viewer_lock.png")
		ButtonState.NORMAL:
			texture_normal = load("res://ui/Upgrade/Flashlight-Viewer.png")
			disabled = true
