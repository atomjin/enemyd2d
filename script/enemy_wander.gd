extends State
class_name EnemyWander

var wander_direction: Vector3
var wander_time = 0.0

@onready var enemy : CharacterBody3D = get_parent().get_parent()

func randomize_variables():
	wander_direction = Vector3(randf_range(-1.0, 1.0), 0.0, randf_range(-1.0, 1.0))
	wander_time = randf_range(1.5, 4)

func enter():
	randomize_variables()

func _process(delta: float) -> void:
	if wander_time < 0.0:
		randomize_variables()
	
	wander_time -= delta

func _physics_process(_delta: float) -> void:
	enemy.velocity = wander_direction * enemy.walkSpeed
	
