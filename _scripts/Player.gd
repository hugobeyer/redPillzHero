# This script is for movement (attached to the Player (CharacterBody3D))
extends CharacterBody3D

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

@export var acceleration: float = 15.0  # How quickly the player reaches max speed
@export var deceleration: float = 10.0  # How quickly the player comes to a stop
@export var air_control: float = 0.3    # How much control the player has while in the air

# Current movement velocity (separate from gravity)
var movement_velocity: Vector3 = Vector3.ZERO

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

func _physics_process(delta):
    handle_movement(delta)
    handle_rotation(delta)
    
    # Apply gravity
    if not is_on_floor():
        velocity.y -= gravity * delta
    elif velocity.y < 0:
        velocity.y = 0  # Reset vertical velocity when on ground
    
    move_and_slide()

func handle_movement(delta: float):
    # Get input and normalize immediately to ensure consistent speed
    var move_vector = Vector2.ZERO
    if Input.is_action_pressed("move_forward"):
        move_vector.y -= 1
    if Input.is_action_pressed("move_backward"):
        move_vector.y += 1
    if Input.is_action_pressed("move_left"):
        move_vector.x -= 1
    if Input.is_action_pressed("move_right"):
        move_vector.x += 1
    
    # Normalize before applying any movement
    # This ensures diagonal movement isn't faster
    move_vector = move_vector.normalized()

    # Get the desired direction relative to the camera
    var cam_basis = camera.global_transform.basis
    var direction = Vector3.ZERO
    
    if move_vector.length() > 0:
        direction = (cam_basis * Vector3(move_vector.x, 0, move_vector.y)).normalized()
        direction.y = 0  # Ensure movement is horizontal
    
    # Calculate target velocity
    # Since direction is normalized, this will maintain consistent speed
    var target_velocity = direction * SPEED
    
    # Calculate acceleration rate based on whether we're on the ground
    var current_acceleration = acceleration
    if not is_on_floor():
        current_acceleration *= air_control
    
    if direction.length() > 0:
        # Accelerate towards target velocity
        movement_velocity = movement_velocity.move_toward(target_velocity, current_acceleration * delta)
    else:
        # Decelerate when no input
        movement_velocity = movement_velocity.move_toward(Vector3.ZERO, deceleration * delta)
    
    # Apply movement velocity
    velocity.x = movement_velocity.x
    velocity.z = movement_velocity.z

func handle_rotation(delta: float):
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
    # Handle recoil by adjusting velocity or another method
    velocity += recoil_force_forward * Weapon.get_recoil_value()

func get_shoot_direction() -> Vector2:
    # Get the direction from the thumbstick
    return input_vector.normalized()

func handle_recoil(delta: float):
    if Weapon:
        Weapon.handle_recoil(delta)

func start_recoil_recovery():
    if Weapon:
        Weapon.start_recoil_recovery()
