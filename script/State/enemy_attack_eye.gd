extends State
class_name EnemyAttackEye

@onready var enemy: CharacterBody3D = get_parent().get_parent()
@onready var animation_tree: AnimationTree = $"../../AnimationTree"
@onready var animation_playback: AnimationNodeStateMachinePlayback
@onready var player: CharacterBody3D = null

var already_attacked = false

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	animation_playback = animation_tree.get("parameters/playback")

func enter():
	player.forced_look_target = enemy   # ✅ set who to look at
	player.forcing_look = true          # ✅ enable the look mode
	player.can_move = false              # ✅ freeze movement

	animation_playback.travel("attaking")  # play attack animation
	
	print("👁️ Player will watch:", player.forced_look_target.name)




func process(delta):
	if player and player.forcing_look:
		player.force_look_at_enemy(delta)

	if not player:
		return

	# 💥 Force the player to look at the enemy every frame
	player.force_look_at_enemy(delta)

	# Optional: check if enemy is too far (escape)
	var distance = enemy.global_position.distance_to(player.global_position)
	if distance > enemy.AttackReach + 2.0:
		player.can_move = true
		player.forcing_look = false
		player.forced_look_target = null
		emit_signal("Transitioned", self, "EnemyChaseEye")

func force_look_at_enemy(delta: float) -> void:
	if not player.forced_look_target:
		return

	var head_pos = player.head.global_transform.origin
	var enemy_pos = player.forced_look_target.global_transform.origin

	var to_enemy = (enemy_pos - head_pos).normalized()

	# Horizontal rotation (left-right)
	var desired_y = atan2(to_enemy.x, to_enemy.z)
	player.head.rotation.y = lerp_angle(player.head.rotation.y, desired_y, delta * 5.0)

	# Vertical rotation (up-down)
	var flat_dist = Vector2(to_enemy.x, to_enemy.z).length()
	var desired_x = atan2(to_enemy.y, flat_dist)
	player.head.rotation.x = lerp_angle(player.head.rotation.x, -desired_x, delta * 5.0)
