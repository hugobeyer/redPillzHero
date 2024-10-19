# This script is for movement (attached to the Player (RigidBody3D))
extends RigidBody3D

@export var health: float = 1000.0
@export var SPEED: float = 6.0
@export var ROTATION_SPEED: float = 10.0
@export_range(0.1, 1.0) var SHOOTING_THRESHOLD: float = 0.8
@export var camera: Camera3D = null
@onready var Weapon = get_node("Weapon")
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

var thumbstick: Node = null
var input_vector: Vector2 = Vector2.ZERO
var is_shooting: bool = false
var has_left_deadzone: bool = false

@onready var navigation_agent: NavigationAgent3D = self.get_node("NavigationAgent3D")

func _ready():
	thumbstick = get_node("../../MainHUD/ControllerCanvas/MovementJoystick")
	if not thumbstick:
		push_error("Thumbstick not found. Make sure it's properly added to the scene.")
	else:
		thumbstick.connect("on_trigger", Callable(self, "_on_thumbstick_trigger"))
		thumbstick.connect("on_pressed", Callable(self, "_on_thumbstick_pressed"))
		thumbstick.connect("on_released", Callable(self, "_on_thumbstick_released"))
	
	if Weapon:
		if not Weapon.is_connected("Weapon_fired", Callable(self, "_on_Weapon_fired")):
			Weapon.connect("Weapon_fired", Callable(self, "_on_Weapon_fired"))
		if not Weapon.is_connected("recoil_reset", Callable(self, "_on_Weapon_recoil_reset")):
			Weapon.connect("recoil_reset", Callable(self, "_on_Weapon_recoil_reset"))
	
	# Initialize the navigation agent
	navigation_agent.max_speed = SPEED

func _physics_process(delta):
	handle_movement()
	handle_rotation(delta)
	# Apply gravity manually
	apply_central_force(Vector3.UP * -gravity * mass)

func handle_movement():
	if input_vector.length() > 0:
		var cam_basis = camera.global_transform.basis
		var direction = (cam_basis * Vector3(input_vector.x, 0, input_vector.y)).normalized()
		direction.y = 0  # Ensure movement is horizontal
		
		# Set the target position for navigation
		var target_position = global_transform.origin + direction * SPEED
		navigation_agent.set_target_position(target_position)
		
		# Get the next path direction
		var next_direction = navigation_agent.get_next_path_position() - global_transform.origin
		next_direction.y = 0  # Keep movement on the XZ plane
		
		# Apply force towards the next position
		if next_direction.length() > 0:
			var force = next_direction.normalized() * SPEED * mass
			apply_central_force(force)
	else:
		# Optionally, apply damping when not moving
		linear_damp = 1.0

func handle_rotation(delta):
	if input_vector.length() > 0:
		var cam_basis = camera.global_transform.basis
		var aim_direction = (cam_basis * Vector3(input_vector.x, 0, input_vector.y)).normalized()
		var target_rotation = atan2(aim_direction.x, aim_direction.z)
		var new_rotation = lerp_angle(rotation.y, target_rotation, ROTATION_SPEED * delta)
		rotation.y = new_rotation

func start_shooting():
	if not is_shooting and Weapon:
		is_shooting = true
		var direction = get_shoot_direction()
		Weapon.trigger_pressed(direction)

func stop_shooting():
	if is_shooting and Weapon:
		is_shooting = false
		Weapon.trigger_released()

func _on_thumbstick_trigger(stick_vector: Vector2, _elapsed: float):
	input_vector = stick_vector
	if input_vector.length() > thumbstick.deadzone_radius_percentage:
		has_left_deadzone = true
		if input_vector.length() > SHOOTING_THRESHOLD:
			start_shooting()
		else:
			stop_shooting()
	elif has_left_deadzone and input_vector.length() <= thumbstick.deadzone_radius_percentage:
		has_left_deadzone = false
		stop_shooting()

func _on_thumbstick_pressed(_event):
	has_left_deadzone = false

func _on_thumbstick_released(_position: Vector2, _elapsed: float) -> void:
	input_vector = Vector2.ZERO
	stop_shooting()
	has_left_deadzone = false

func _input(event):
	if event.is_action_pressed("fire"):
		if Weapon and Weapon.has_method("shoot2"):
			Weapon.shoot2()

func _on_Weapon_fired(recoil_force_forward: Vector3) -> void:
	# Apply the recoil force
	apply_central_impulse(-recoil_force_forward * Weapon.get_recoil_value())

func get_shoot_direction() -> Vector2:
	# Get the direction from the thumbstick
	return input_vector.normalized()

func handle_recoil(delta: float):
	if Weapon:
		Weapon.handle_recoil(delta)

func start_recoil_recovery():
	if Weapon:
		Weapon.start_recoil_recovery()
