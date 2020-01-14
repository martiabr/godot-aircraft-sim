extends RigidBody

# bank-to-turn: heading dot = g / V_a * tan roll, careful with domain on this one, removing tan might be easier?
# pitch is simplified as m-s-d with elevator force, should ignore spring force and possibly also damper?
# roll is simplified as m-s-d with aileron force, these should be kept and is the most important part in addition to b2t
# altitude dot = V_a * pitch, dont know if this is needed?

# should start by removing gravity and just trying to get the aircraft rotating with controls while standing still

#onready var movement_guide = $MovementGuide

#var turn_speed = 50
#var speed = 10
#var rot = Vector3()
var g = 10
var V_a = 10
var m = get_mass()
var roll = 0.0  # accumulated roll calculated from angular velocity in z
var pitch = 0.0
var heading = 0.0

var u_roll = 2  # magnitude of force in roll (aileron input)
var k_roll = 5  # spring constant in roll
var d_roll = 150  # damping constant in roll

func _ready():
	pass

func _integrate_forces(state):
	# Find current local frame:
	var dir_x = get_global_transform().basis.x  # right
	var dir_y = get_global_transform().basis.y  # up
	var dir_z = get_global_transform().basis.z  # forward

	# Update stored state:
	var roll_rate = deg2rad(state.get_angular_velocity().z)
	roll += roll_rate
	#roll = wrap_angle(roll) # doesnt work, possibly easier to restrict aircraft to +-90 degrees
	
	var heading_rate = deg2rad(state.get_angular_velocity().y)
	heading += heading_rate
	#print(heading)
	
	if Input.is_action_pressed("movement_left"):
		state.add_torque(u_roll * dir_z)
	elif Input.is_action_pressed("movement_right"):
		state.add_torque(u_roll * -dir_z)
	else:
		state.add_torque(d_roll * roll_rate * - dir_z)
		state.add_torque(k_roll * roll * - dir_z)
	#print(roll)
	
	var ang_vel = state.get_angular_velocity()
	print(ang_vel)
	#state.set_angular_velocity(Vector3(ang_vel.x, g / V_a * tan(roll), ang_vel.z))
	#state.add_torque(0.1 * dir_y)
	state.set_linear_velocity(V_a * -dir_z) # add surge speed control later

#func process_input(delta):
#	if Input.is_action_pressed("movement_up"):
#    	rot.x += turn_speed * delta
#	if Input.is_action_pressed("movement_down"):
#    	rot.x -= turn_speed * delta
#	if Input.is_action_pressed("movement_right"):
#		rot.y -= turn_speed * delta
#	if Input.is_action_pressed("movement_left"):
#		rot.y += turn_speed * delta

func wrap_angle(angle):
	if angle > PI:
		return angle - 2*PI
	elif angle < -PI:
		return angle + 2*PI
	return angle