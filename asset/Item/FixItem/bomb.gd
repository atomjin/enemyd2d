extends CharacterBody3D

@onready var outlineMesh: MeshInstance3D = $Empty_011/Sphere_003/MeshInstance3D
@onready var outlineMesh2: MeshInstance3D = $Empty_011/Vert/MeshInstance3D

@onready var wholeitem: Node3D = $Empty_011

@onready var collisionShape: CollisionShape3D = $CollisionShape3D

@onready var cursedmarking: Decal = $Empty_011/CursedMarking
var cursed = false

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var selected = false
var outlineWidth = 0.05
var player
var held = false
var onheldcooldown = false
var pickable = true
var handfull = false
var oncooldown = false
var weight = 1.5

var pressed = false

var value: int = 0 #New Add

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interaction") and selected:
		if player.has_method("_is_handfull") and player._is_handfull():
			print("Hand Full!")
			return
		if oncooldown:
			print("oncooldown")
			return
		else:
			player.pick_up_object(self)
			picked_up()
	if pressed and event is InputEventMouseMotion:
		rotation.x += event.relative.y*0.005
		wholeitem.rotation.y += event.relative.x*0.005
		collisionShape.rotation.y += event.relative.x*0.005
		
		#item2.rotation.y += event.relative.x*0.005
		#item3.rotation.y += event.relative.x*0.005
		#item4.rotation.y += event.relative.x*0.005
		#item5.rotation.y += event.relative.x*0.005

func _ready():
	player = get_tree().get_first_node_in_group("player")
	player.interact_object.connect(_set_selected)
	
	outlineMesh.visible = false
	
	#cursed status
	cursed = randi() % 100 < 30  # 30% chance to be cursed
	if cursed:
		cursedmarking.visible = true
	else:
		cursedmarking.visible = false
	
	randomize()
	value = randi_range(100, 200)

func _process(delta):
	outlineMesh2.visible = selected and not player == get_parent()
	outlineMesh.visible = selected and not player == get_parent()
	if selected:
		if Input.is_action_just_pressed("click"):
			pressed = true
		if Input.is_action_just_released("click"):
			pressed = false
	else:
		wholeitem.position.y = 0
		if Input.is_action_just_released("click"):
			pressed = false

func is_pickable() -> bool:
	return pickable

func is_cursed() -> bool:
	return cursed

func _set_selected(object):
	selected = self == object

func _physics_process(delta: float) -> void:
	if player == get_parent():
		return
	
	if not is_on_floor() and not held:
		velocity.y -= gravity * delta
		
	move_and_slide()

func picked_up():
	collisionShape.disabled = true
	held = true
	player.add_weight(weight)

func put_down():
	collisionShape.disabled = false
	held = false
	oncooldown = true
	player.remove_weight(weight)
	await get_tree().create_timer(0.7).timeout
	oncooldown = false
	

func is_sell(value): #New Add
	return value
