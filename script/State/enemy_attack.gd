extends State
class_name EnemyAttack

@onready var enemy: CharacterBody3D = get_parent().get_parent()
@onready var animation_tree: AnimationTree = $"../../AnimationTree"

var player: CharacterBody3D = null
var animation_playback = AnimationNodeStateMachinePlayback


func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	animation_playback = animation_tree.get("parameters/playback")

func enter():
	animation_playback.travel("attack")

func process(delta: float) -> void:
	player.healt_component.damage(1.0)
	
	if enemy.global_position.direction_to(player.global_position) > enemy.AttackReach:
		emit_signal("Transitioned",self, "EnemyAttack")
		
		
func _attack_player():
	player.health_component.damage(1.0)
