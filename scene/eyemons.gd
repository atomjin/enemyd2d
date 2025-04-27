extends CharacterBody3D

@export var walkSpeed: float = 1.5
@export var RunSpeed: float = 4.0
@export var ChaseDistance: float = 15.0
@export var AttackReach: float = 1
@export var player_path: NodePath

@export var flash_light_detect_distance: float = 15.0
@export var flashlight_damageable: bool = true  # ✅ Turn on/off this easily


@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var animation_tree: AnimationTree = $AnimationTree



var player: CharacterBody3D = null
var animation_playback: AnimationNodeStateMachinePlayback

func _ready() -> void:
	player = get_node(player_path)
	animation_playback = animation_tree.get("parameters/playback")
	
func _process(delta):
	if flashlight_damageable and not is_dying and is_in_flashlight():
		print("⚡ Eyemons hit by flashlight! Playing death animation!")
		start_death_sequence()

var is_dying = false  # prevent multiple death triggers

func start_death_sequence():
	is_dying = true
	velocity = Vector3.ZERO
	nav_agent.set_target_position(global_position)
	nav_agent.velocity = Vector3.ZERO

	animation_playback.travel("DEAD")  

	await get_tree().create_timer(1.5).timeout 
	queue_free()  # 💀 delete the enemy
	
	
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
	#move_and_slide()
	

	
func is_in_flashlight() -> bool:
	if not player:
		return false

	var flashlight = player.get_node_or_null("Head/Camera3D/SpotLight3D")  # ✨ Your flashlight node path
	if not flashlight or not flashlight.visible:
		return false

	var to_enemy = (global_transform.origin - flashlight.global_transform.origin)
	var flashlight_dir = -flashlight.global_transform.basis.z

	var distance = to_enemy.length()
	if distance > flash_light_detect_distance:
		return false

	var angle = flashlight_dir.angle_to(to_enemy.normalized())
	return angle < deg_to_rad(flashlight.spot_angle / 2.0)  # Inside flashlight cone
