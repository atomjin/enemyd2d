extends State
class_name EnemyAttack

@onready var enemy: CharacterBody3D = get_parent().get_parent()
@onready var animation_tree: AnimationTree = $"../../AnimationTree"
@onready var animation_playback: AnimationNodeStateMachinePlayback
@onready var player: CharacterBody3D = null
@export var can_move: bool = true


func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	animation_playback = animation_tree.get("parameters/playback")

func enter() -> void:
	player.forced_look_target = enemy
	player.forcing_look = true
	player.can_move = false

	enemy.can_move = false
	enemy.nav_agent.velocity = Vector3.ZERO
	enemy.nav_agent.set_target_position(enemy.global_position)


	# ✨ Make enemy turn to face player
	var to_player = (player.global_position - enemy.global_position).normalized()
	var angle = atan2(to_player.x, to_player.z)
	enemy.rotation.y = angle

	animation_playback.travel("attack")

	print("👁️ Player will watch:", player.forced_look_target.name)



func process(delta: float) -> void:
	if not player:
		return

	# Force player to look at enemy
	if player.forcing_look and player.forced_look_target:
		player.force_look_at_enemy(delta)

	# Escape: if enemy is too far, stop jumpscare
	var distance = enemy.global_position.distance_to(player.global_position)
	if distance > enemy.AttackReach + 2.0:
		player.can_move = true
		player.forcing_look = false
		player.forced_look_target = null

		enemy.can_move = true  # ✅ Enemy unfrozen

		emit_signal("Transitioned", self, "EnemyChase")

		
func _physics_process(delta):
	if not can_move:
		return  

		
func _attack_player():
	pass 
