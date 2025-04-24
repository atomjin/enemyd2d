extends CharacterBody3D

@export var walkSpeed: float = 1.5
@export var RunSpeed: float = 4.0
@export var ChaseDistance: float = 15.0
@export var AttackReach: float = 1
@export var player_path: NodePath

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var animation_tree: AnimationTree = $AnimationTree

var player: CharacterBody3D = null
var animation_playback: AnimationNodeStateMachinePlayback

func _ready() -> void:
	player = get_node(player_path)
	animation_playback = animation_tree.get("parameters/playback")
	
#func _process(delta: float) -> void:
#	nav_agent.set_target_position(player.global_position)
		
func _physics_process(delta: float) -> void:
	var state = animation_playback.get_current_node()
	
	if state =="attack":
		look_at(Vector3(player.global_position.x, global_position.y,player.global_position.z))
	else:
	
		var new_velocity = velocity
		new_velocity.y = 0
	
		if new_velocity != Vector3.ZERO:
			rotation.y = lerp(rotation.y,atan2(-velocity.x,-velocity.z), delta * 10.0)
		#look_at(global_position + new_velocity) instance rotate look weirdo
	move_and_slide()
	
func on_death()-> void:
	queue_free()
