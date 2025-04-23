extends CharacterBody3D

signal player_hit

@export var player_path: NodePath
@export var attack_range: float = 1.0
@export var speed: float = 4.0

var player
var state_machine
var has_hit = false

@onready var nav_agent = $NavigationAgent3D
@onready var anim_tree: AnimationTree = $AnimationTree

func _ready():
	player = get_node(player_path)
	state_machine = anim_tree.get("parameters/playback")

func _process(delta):
	if not player:
		return

	velocity = Vector3.ZERO
	
	
	nav_agent.set_target_position(player.global_transform.origin)
	var next_nav_point = nav_agent.get_next_path_position()
	velocity = (next_nav_point - global_transform.origin).normalized() * speed
	look_at(Vector3(player.global_position.x + velocity.x, global_position.y, player.global_position.z + velocity.z), Vector3.UP)

			# Trigger player_hit only once when in range
	if global_position.distance_to(player.global_position) < attack_range and !has_hit:
		print("✅ Scab reached player — HIT!")  # This prints ✅
		emit_signal("player_hit")
		has_hit = true
	

	move_and_slide()

	
