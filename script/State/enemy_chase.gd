extends State
class_name EnemyChase

@onready var enemy: CharacterBody3D = get_parent().get_parent()
@onready var animation_tree: AnimationTree = $"../../AnimationTree"

var player: CharacterBody3D = null
var animation_playback: AnimationNodeStateMachinePlayback

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	animation_playback = animation_tree.get("parameters/playback")
	
func enter():
	animation_playback.travel("running")
	
func process(delta: float):
	enemy.nav_agent.set_target_position(player.global_position)
	
	if enemy.global_position.direction_to(player.global_position)> enemy.ChaseDistance:
		emit_signal("Transitioned",self, "EnemyWander")
	
	if enemy.global_position.direction_to(player.global_position) < enemy.AttackReach:
		emit_signal("Transitioned",self, "EnemyAttack")

func physics_process(delta: float) -> void:
	if enemy.nav_agent.is_navigation_finished():
		return
		
	var next_position: Vector3 = enemy.nav_agent.get_next_path_position()
	enemy.velocity = enemy.global_position.direction_to(next_position) * enemy.RunSpeed
