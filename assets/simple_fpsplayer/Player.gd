extends KinematicBody
#Variables
var global = "root/global"

const GRAVITY = -32.8
var vel = Vector3()
const MAX_SPEED = 10
const JUMP_SPEED = 12
const ACCEL = 4.5

var dir = Vector3()

const DEACCEL= 16
const MAX_SLOPE_ANGLE = 40

var camera
var rotation_helper
var darkam
var nightam
var footsteps
var chase1
var chase2
var chase3
var chase4
var chase5
var breath

var MOUSE_SENSITIVITY = 0.1

const MAX_SPRINT_SPEED = 20
const SPRINT_ACCEL = 18
var is_sprinting = false

var flashlight

func _ready():
	camera = $rotation_helper/Camera
	rotation_helper = $rotation_helper
	flashlight = $rotation_helper/Flashlight
	darkam = $Audio/Ambient/Dark
	nightam = $Audio/Ambient/Night
	chase1 = $Audio/Chase/Chase1
	chase2 = $Audio/Chase/Chase2
	chase3 = $Audio/Chase/Chase3
	chase4 = $Audio/Chase/Chase4
	chase5 = $Audio/Chase/Chase5
	breath = $Audio/FX/Breath
	
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
	process_input(delta)
	process_movement(delta)

func process_input(delta):
	
	# Temp Quit
	if Input.is_action_pressed("quit"):
		self.get_tree().quit()

	# ----------------------------------
	# Walking
	dir = Vector3()
	var cam_xform = camera.get_global_transform()

	var input_movement_vector = Vector2()

	if Input.is_action_pressed("movement_forward"):
		input_movement_vector.y += 1
	if Input.is_action_pressed("movement_backward"):
		input_movement_vector.y -= 1
	if Input.is_action_pressed("movement_left"):
		input_movement_vector.x -= 1
	if Input.is_action_pressed("movement_right"):
		input_movement_vector.x += 1
		
	# Temp Audio Input
	if Input.is_action_just_pressed("darkam"):
		# Toggle Dark Ambience
		darkam.playing = !darkam.playing

	if Input.is_action_just_pressed("nightam"):
		# Toggle Night Ambience
		nightam.playing = !nightam.playing
	if Input.is_action_just_pressed("chase"):
		# Toggle Chase Channels
		chase1.playing = !chase1.playing
		chase2.playing = !chase2.playing
		chase3.playing = !chase3.playing
		chase4.playing = !chase4.playing
		chase5.playing = !chase5.playing


	input_movement_vector = input_movement_vector.normalized()

	dir += -cam_xform.basis.z.normalized() * input_movement_vector.y
	dir += cam_xform.basis.x.normalized() * input_movement_vector.x
	# ----------------------------------

	# ----------------------------------
	# Jumping
	if is_on_floor():
		if Input.is_action_just_pressed("movement_jump"):
			vel.y = JUMP_SPEED
	# ----------------------------------

	# ----------------------------------
	# Capturing/Freeing the cursor
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	# ----------------------------------

# ----------------------------------
# Turning the flashlight on/off
	if Input.is_action_just_pressed("flashlight"):
		if flashlight.is_visible_in_tree():
			flashlight.hide()
		else:
			flashlight.show()
# ----------------------------------

func process_movement(delta):
	dir.y = 0
	dir = dir.normalized()

	vel.y += delta * GRAVITY

	var hvel = vel
	hvel.y = 0

	var target = dir
	target *= MAX_SPEED

	var accel
	if dir.dot(hvel) > 0:
		accel = ACCEL
	else:
		accel = DEACCEL

	hvel = hvel.linear_interpolate(target, accel * delta)
	vel.x = hvel.x
	vel.z = hvel.z
	vel = move_and_slide(vel, Vector3(0, 1, 0), 0.05, 4, deg2rad(MAX_SLOPE_ANGLE))
	
	# If we are moving in the world play footsteps
	if vel.x != 0 or vel.z != 0:
		breath.play()
	else:
		breath.stop()

func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotation_helper.rotate_x(deg2rad(event.relative.y * MOUSE_SENSITIVITY))
		self.rotate_y(deg2rad(event.relative.x * MOUSE_SENSITIVITY * -1))

		var camera_rot = rotation_helper.rotation_degrees
		camera_rot.x = clamp(camera_rot.x, -80, 80)
		rotation_helper.rotation_degrees = camera_rot
