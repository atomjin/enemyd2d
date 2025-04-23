extends StaticBody3D

@onready var collisionShape: CollisionShape3D = $CollisionShape3D
@onready var animationPlayer: AnimationPlayer = $AnimationPlayer

var selected = false
var player
var openable = false #wait for key implementation
var open = false

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	player.interact_object.connect(_set_selected)

func _process(delta: float) -> void:
	if selected and not open:
		if Input.is_action_just_pressed("interaction"):
			animationPlayer.play("open_door")
			open = true

func is_openable() -> bool:
	return openable

func _set_selected(object):
	selected = self == object
