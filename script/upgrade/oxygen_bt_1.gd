extends TextureButton

@export var price: int = 100  # Set the price of the upgrade in the Inspector
@onready var player = get_tree().get_first_node_in_group("player")
@onready var ox_tex = load("res://ui/Inven/Ox_Inven.png")

enum ButtonState { LOCKED, NORMAL }
var state = ButtonState.LOCKED

func _ready():
	update_button_texture()
	$"../OxygenLabel1".text = str(price)

func _on_pressed():
	match state:
		ButtonState.LOCKED:
			if player.current_money >= price:
				state = ButtonState.NORMAL
				player.current_money -= price
				print("Upgrade unlocked!")
				$"../..".update_balance()
				$"../OxygenLabel1".hide() 
				$"../OxygenButton2".disabled = false
				$"../../../Main/OxCounter".show()
				$"../../../Main/Ox_Holder".texture = ox_tex
				player.oxygen_upgrade()
			else:
				$"../..".alert()
				print("Not enough balance!")
	player.update_money()
	update_button_texture()

func update_button_texture():
	match state:
		ButtonState.LOCKED:
			texture_normal = load("res://ui/Upgrade/Oxygen_lock.png")
		ButtonState.NORMAL:
			texture_normal = load("res://ui/Upgrade/Oxygen.png")
			disabled = true
