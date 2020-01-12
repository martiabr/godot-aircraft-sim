extends KinematicBody

onready var movement_guide = $MovementGuide

var turn_speed = 50
var speed = 10
var rot = Vector3()

func _ready():
	pass

func _physics_process(delta):
	process_input(delta)
	
	rotation_degrees = rot
	translate(-movement_guide.transform.basis.z * speed * delta)

func process_input(delta):
	if Input.is_action_pressed("movement_up"):
    	rot.x += turn_speed * delta
	if Input.is_action_pressed("movement_down"):
    	rot.x -= turn_speed * delta
	if Input.is_action_pressed("movement_right"):
		rot.y -= turn_speed * delta
	if Input.is_action_pressed("movement_left"):
		rot.y += turn_speed * delta