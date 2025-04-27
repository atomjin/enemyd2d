extends CharacterBody3D

signal player_hit

@export var player_path: NodePath
@export var attack_range: float = 1.0
@export var speed: float = 4.0

var player
var has_hit = false
var forcing_look = false
var forced_look_target = null
var is_preparing_jumpscare = false

@onready var nav_agent = $NavigationAgent3D
@onready var anim_tree: AnimationTree = $AnimationTree

func _ready():
	player = get_node(player_path)

func _process(delta):
	if not player:
		return

	if forcing_look and forced_look_target:
		force_player_look_at_enemy(delta)

	if forcing_look or is_preparing_jumpscare:
		velocity = Vector3.ZERO
		move_and_slide()
		return

	# Normal chase
	velocity = Vector3.ZERO
	nav_agent.set_target_position(player.global_transform.origin)
	var next_nav_point = nav_agent.get_next_path_position()
	velocity = (next_nav_point - global_transform.origin).normalized() * speed
	look_at(Vector3(player.global_position.x + velocity.x, global_position.y, player.global_position.z + velocity.z), Vector3.UP)
	move_and_slide()

	# If close enough, start stopping first
	if global_position.distance_to(player.global_position) < attack_range and !has_hit:
		print("⚡ Scab preparing jumpscare...")
		is_preparing_jumpscare = true
		has_hit = true
		# Wait before jumpscare!
		start_jumpscare_delay()

func start_jumpscare_delay():
	velocity = Vector3.ZERO
	await get_tree().create_timer(0.5).timeout  # ⏱ Wait half second
	start_jumpscare()

func start_jumpscare():
	player.forced_look_target = self
	player.forcing_look = true
	forcing_look = true
	forced_look_target = player
	print("✅ Jumpscare started!")

func force_player_look_at_enemy(delta: float) -> void:
	if not forced_look_target:
		return

	var head = player.head
	var head_pos = head.global_transform.origin
	var enemy_pos = global_transform.origin

	var to_enemy = (enemy_pos - head_pos).normalized()

	# 🧠 Horizontal (Y axis) rotation (left-right)
	var desired_y = atan2(to_enemy.x, to_enemy.z)
	head.rotation.y = lerp_angle(head.rotation.y, desired_y, delta * 6.0)

	# 🧠 Vertical (X axis) rotation (up-down)
	var flat_dist = Vector2(to_enemy.x, to_enemy.z).length()
	var desired_x = atan2(to_enemy.y, flat_dist)
	head.rotation.x = lerp_angle(head.rotation.x, -desired_x, delta * 6.0)
