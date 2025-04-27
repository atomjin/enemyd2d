extends State
class_name EnemyChase

@onready var enemy: CharacterBody3D = get_parent().get_parent()
@onready var animation_tree: AnimationTree = $"../../AnimationTree"

@onready var collision_shape_3d: CollisionShape3D = $"../../ChaseZone/CollisionShape3D"

var player: CharacterBody3D = null
var animation_playback: AnimationNodeStateMachinePlayback

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	
	animation_playback = animation_tree.get("parameters/playback")
	var shape = SphereShape3D.new()
	shape.radius = enemy.ChaseDistance

	
	
func enter():
	animation_playback.travel("running")
	print("🟢 ENTERED CHASE STATE")

	
func process(delta: float):
	enemy.nav_agent.set_target_position(player.global_position)
	
	
	if enemy.global_position.distance_to(player.global_position) > enemy.ChaseDistance:
		emit_signal("Transitioned", self, "EnemyWander")

	if enemy.global_position.distance_to(player.global_position) < enemy.AttackReach:
		emit_signal("Transitioned", self, "EnemyAttack")  # Use the exact node name


func physics_process(delta: float) -> void:
	if not player:
		return

	# Update target position
	enemy.nav_agent.set_target_position(player.global_position)

	if enemy.nav_agent.is_navigation_finished():
		return

	# Calculate 3D direction to player
	var next_position = enemy.nav_agent.get_next_path_position()
	var dir = (next_position - enemy.global_position).normalized()

	enemy.velocity = dir * enemy.RunSpeed

	# ✅ Make enemy rotate in full 3D direction
	if dir.length() > 0.1:
		enemy.look_at(enemy.global_position + dir, Vector3.UP)

	enemy.move_and_slide()
