extends KinematicBody

var surge_speed = 15.0
var b2t_coeff = 50.0
var eul_ang = Vector3()
var eul_rate = Vector3()
var eul_acc = Vector3()
var g = 10.0
var m = 50.0

var u = Vector3(4, 0, 4)  # magnitude of forces in roll, pitch, yaw

var d_roll = 2.0  # damping constant in roll
var d_pitch = 4.0  # damping constant in pitch
var k_roll = 6.0  # spring constant in roll
var k_pitch = 4.0  # spring constant in roll

# Helper variables
var dir_x = Vector3(1, 0, 0)
var dir_y = Vector3(0, 1, 0)
var dir_z = Vector3(0, 0, 1)

func _ready():
	pass

func _physics_process(delta):
	eul_acc = Vector3()  # reset acceleration
	
	# Add control forces:
	if Input.is_action_pressed("movement_right"):
		eul_acc.z -= u.z
	elif Input.is_action_pressed("movement_left"):
		eul_acc.z += u.z
	if Input.is_action_pressed("movement_up"):
		eul_acc.x -= u.x
	elif Input.is_action_pressed("movement_down"):
		eul_acc.x += u.x
	
	# Add spring and damping forces:
	eul_acc.z -= d_roll * eul_rate.z 
	eul_acc.x -= d_pitch * eul_rate.x
	eul_acc.z -= k_roll * eul_ang.z
	eul_acc.x -= k_pitch * eul_ang.x
	 
	# Euler integration:
	eul_rate += eul_acc * delta
	eul_rate.y = b2t_coeff * tan(eul_ang.z) * delta  # bank-to-turn
	eul_ang += eul_rate * delta
	
	rotation = eul_ang
	#print(eul_rate)
	
	#translate(surge_speed * delta * -dir_z )
	move_and_slide(surge_speed * -transform.basis.z)
