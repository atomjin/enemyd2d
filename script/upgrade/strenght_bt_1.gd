extends TextureButton

@export var price: int = 350  # Set the price of the upgrade in the Inspector
@onready var player = get_tree().get_first_node_in_group("player")

enum ButtonState { LOCKED, NORMAL }
var state = ButtonState.LOCKED

func _ready():
	update_button_texture()
	$"../StrenghtLabel1".text = str(price)

func _on_pressed():
	match state:
		ButtonState.LOCKED:
			if player.current_money >= price:
				state = ButtonState.NORMAL
				player.current_money -= price
				print("Upgrade unlocked!")
				$"../..".update_balance()
				$"../StrenghtLabel1".hide() 
				player.strength_upgrade(0.3)
				$"../StrenghtBT2".disabled = false
			else:
				$"../..".alert()
				print("Not enough balance!")
	player.update_money()
	update_button_texture()

func update_button_texture():
	match state:
		ButtonState.LOCKED:
			texture_normal = load("res://ui/Upgrade/Strenght_lock.png")
		ButtonState.NORMAL:
			texture_normal = load("res://ui/Upgrade/Strenght.png")
			disabled = true
