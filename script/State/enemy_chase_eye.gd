extends State
class_name EnemyChaseEye

@onready var enemy = get_parent().get_parent()
@onready var nav_agent = enemy.get_node("NavigationAgent3D")
@onready var animation_tree: AnimationTree = $"../../AnimationTree"
@onready var animation_playback: AnimationNodeStateMachinePlayback
@onready var player = get_tree().get_first_node_in_group("player")
@onready var ray_cast = player.get_node("Head/Camera3D/RayCast3D") 



func _ready():
	animation_playback = animation_tree.get("parameters/playback")

func enter():
	print("🏃 ENTERED CHASE STATE")
	if animation_playback:
		animation_playback.travel("running")

func physics_process(delta):
	if not player:
		return

	# If player is looking at enemy, Freeze
	if is_player_looking_at_enemy():
		print("🧊 Player is watching — switch to freeze.")
		emit_signal("Transitioned", self, "EnemyFreeze")
		return

	# If enemy is very close to player, Attack
	var distance_to_player = enemy.global_position.distance_to(player.global_position)
	if distance_to_player <= enemy.AttackReach:
		print("⚔️ Close enough — switch to attack.")
		emit_signal("Transitioned", self, "EnemyAttackEye")
		return

	# Otherwise, chase normally
	nav_agent.set_target_position(player.global_position)

	if nav_agent.is_navigation_finished():
		return

	var next_position = nav_agent.get_next_path_position()
	var dir = (next_position - enemy.global_position).normalized()

	enemy.velocity = dir * enemy.RunSpeed

	# ✅ Correct: make enemy look in 3D swimming direction
	if dir.length() > 0.1:
		enemy.look_at(enemy.global_position + dir, Vector3.UP)

	enemy.move_and_slide()


			
func is_player_looking_at_enemy() -> bool:
	if not ray_cast or not enemy:
		return false

	var to_enemy = (enemy.global_position - ray_cast.global_position).normalized()
	var cast_direction = -ray_cast.global_transform.basis.z.normalized()

	var angle = cast_direction.angle_to(to_enemy)


	return angle < deg_to_rad(50)  # Try adjusting this value
