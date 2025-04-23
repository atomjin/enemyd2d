extends Area3D

@onready var player = $"../../player"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("itemforsell"):
		var item_value = body.is_sell(body.value)  # Get the item's value
		if player and item_value:  # Ensure player exists
			player.add_money(body.value)  # Add money to the player
			body.queue_free()  # Remove the item after selling (optional)
			print("Sold item for", body.value, "coins!")
			$"../../GUI/Upgrade".update_balance()
