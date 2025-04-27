extends CharacterBody3D

@export var walkSpeed: float = 1.5
@export var RunSpeed: float = 4.0
@export var ChaseDistance: float = 15.0
@export var AttackReach: float = 1
@export var player_path: NodePath
@export var can_move: bool = true

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var animation_tree: AnimationTree = $AnimationTree

var player: CharacterBody3D = null
var animation_playback: AnimationNodeStateMachinePlayback

func _ready() -> void:
	player = get_node(player_path)
	animation_playback = animation_tree.get("parameters/playback")

func _physics_process(delta: float) -> void:
	
	if not can_move:
		# 💥 Full Stop movement and stop pathing
		velocity = Vector3.ZERO
		move_and_slide()

		nav_agent.velocity = Vector3.ZERO
		nav_agent.set_target_position(global_position)  # Stay in place
		
		return

	# 🧠 Otherwise normal movement
	move_and_slide()

	var state = animation_playback.get_current_node()

	if state == "attack":
		var to_player = Vector3(player.global_position.x, global_position.y, player.global_position.z) - global_position
		var target_angle = atan2(to_player.x, to_player.z)
		rotation.y = lerp_angle(rotation.y, target_angle, delta * 5.0)
	else:
		var new_velocity = velocity
		new_velocity.y = 0

		if new_velocity != Vector3.ZERO:
			rotation.y = lerp(rotation.y, atan2(-velocity.x, -velocity.z), delta * 10.0)

	move_and_slide()


func on_death() -> void:
	queue_free()
