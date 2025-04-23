extends Node3D  # Change to Node2D if working in 2D

@export var spawn_scenes: Array[PackedScene]  # Assign scenes in the editor

func _ready():
	if spawn_scenes.is_empty():
		print("No scenes assigned to the spawner.")
		return

	var item_node = $"../item"
	if item_node == null:
		print("Item node not found!")
		return

	var random_scene = spawn_scenes[randi() % spawn_scenes.size()]
	var instance = random_scene.instantiate()
	instance.transform.origin = global_transform.origin
	item_node.add_child(instance)  # Add the instance to the Item node
