extends KinematicBody
# TODO: sounds, smoke trail, more advanced dynamics, turn terrain into hollow sphere shit
# surge speed control, generate trees and stuff, possibly buildings? Erosion, clouds, fog, ...
# Water, moving propeller (change to rotating disc at high speed?)

# Helper variables:
var dir_x = Vector3(1, 0, 0)
var dir_y = Vector3(0, 1, 0)
var dir_z = Vector3(0, 0, 1)

# Aircraft dynamics parameters:
var g = 10.0
var m = 50.0
var surge_speed = 20.0
var b2t_param = 700.0  # bank-to-turn speed
var d_roll = 2.5  # damping constant in roll
var d_pitch = 3.0  # damping constant in pitch
var k_roll = 10.0  # spring constant in roll
var k_pitch = 6.0  # spring constant in roll
var u = Vector3(4, 0, 5)  # magnitude of forces in pitch, yaw, roll

var eul_acc_max = 15
var eul_rate_max = 2
var roll_max = deg2rad(80)
var pitch_max = deg2rad(80)

# Aircraft state:
var eul_ang = Vector3()
var eul_rate = Vector3()
var eul_acc = Vector3()

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
	
	# Clamp attitude rate and acceleration:
	eul_acc = clamp_elements(eul_acc, -eul_acc_max, eul_acc_max)
	eul_rate = clamp_elements(eul_rate, -eul_rate_max, eul_rate_max)
	 
	# Euler integration:
	eul_rate += eul_acc * delta
	eul_rate.y = b2t_param / surge_speed * tan(eul_ang.z) * delta  # bank-to-turn equation
	eul_ang += eul_rate * delta
	
	# Clamp euler angles:  TODO: use sigmoid instead?
	eul_ang.x = clamp(eul_ang.x, -roll_max, roll_max)
	eul_ang.z = clamp(eul_ang.z, -pitch_max, pitch_max)
	
	#translate(surge_speed * delta * -dir_z )
	rotation = eul_ang
	move_and_slide(surge_speed * -transform.basis.z)

func clamp_elements(vec, min_el_val, max_el_val):
	vec.x = clamp(vec.x, min_el_val, max_el_val)
	vec.y = clamp(vec.y, min_el_val, max_el_val)
	vec.z = clamp(vec.z, min_el_val, max_el_val)
	return vec
