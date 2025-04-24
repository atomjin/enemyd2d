extends State
class_name EnemyWander


@onready var enemy : CharacterBody3D = get_parent().get_parent()
@onready var animation_tree: AnimationTree = $"../../AnimationTree"

var wander_direction: Vector3
var wander_time = 0.0

var player: CharacterBody3D = null
var animation_playback: AnimationNodeStateMachinePlayback


func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	animation_playback = animation_tree.get("parameters/playback")

func randomize_variables():
	wander_time = randf_range(1.5, 4)
	
	if randi_range(0, 3)!= 1:
		wander_direction = Vector3(randf_range(-1.0, 1.0), 0.0, randf_range(-1.0, 1.0))
		animation_playback.travel("walking")
	else:
		wander_direction = Vector3.ZERO
		animation_playback.travel("idle")
	

func enter():
	randomize_variables()

func _process(delta: float) -> void:
	if wander_time < 0.0:
		randomize_variables()
	
	wander_time -= delta
	
	if enemy.global_position.distance_to(player.global_position)< enemy.ChaseDistance:
		emit_signal("Tramsitioned",self,"EnemyChase")

func _physics_process(_delta: float) -> void:
	enemy.velocity = wander_direction * enemy.walkSpeed
	
