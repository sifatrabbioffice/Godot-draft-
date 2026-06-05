extends CharacterBody3D

@export var move_speed := 12.0
@export var sprint_multiplier := 1.6
@export var jump_velocity := 15.0
@export var mouse_sensitivity := 0.002
@export var controller_sensitivity := 3.0

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	var arm = $SpringArm3D

	# Mouse look
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		arm.rotation.y -= event.relative.x * mouse_sensitivity
		arm.rotation.x -= event.relative.y * mouse_sensitivity
		arm.rotation.x = clamp(arm.rotation.x, -1.4, 0.2)

	# Controller right-stick look (fine control)
	if event is InputEventJoypadMotion:
		var axis_val = event.axis_value
		if abs(axis_val) < 0.1:   # deadzone
			return
		if event.axis == JOY_AXIS_RIGHT_X:
			arm.rotation.y -= axis_val * controller_sensitivity * get_process_delta_time()
		if event.axis == JOY_AXIS_RIGHT_Y:
			arm.rotation.x -= axis_val * controller_sensitivity * get_process_delta_time()
			arm.rotation.x = clamp(arm.rotation.x, -1.4, 0.2)

func _physics_process(delta):
	# Gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	# Movement input – works for both keyboard and controller left stick
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := Vector3(input_dir.x, 0, input_dir.y).rotated(Vector3.UP, $SpringArm3D.rotation.y).normalized()

	# Sprint
	var speed := move_speed
	if Input.is_action_pressed("sprint"):
		speed *= sprint_multiplier

	velocity.x = direction.x * speed
	velocity.z = direction.z * speed

	move_and_slide()
