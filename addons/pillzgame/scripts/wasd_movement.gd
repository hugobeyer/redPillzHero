extends Node3D

@export var move_speed: float = 10.0
@export var wander_speed: float = 5.0
@export var flee_speed: float = 7.0  # Speed when fleeing
@export var world_noise_strength: float = 2.0
@export var noise_speed: float = 0.5
@export var max_radius: float = 10.0
@export var min_radius: float = 1.0
@export var turn_around_zone: float = 2.0  # Distance from max_radius to start turning around
@export var min_turn_angle: float = 0.1
@export var max_turn_angle: float = PI / 2
@export var turn_speed: float = 2.0
@export var flee_distance: float = 5.0  # Distance at which to start fleeing
@export var flock_node_path: NodePath  # Path to the node containing the flock

var wander_enabled: bool = true
var noise: FastNoiseLite
var noise_offset: float = 0.0
var current_direction: Vector3 = Vector3.FORWARD
var flock_node: Node

func _ready():
    randomize()
    noise = FastNoiseLite.new()
    noise.seed = randi()
    noise.frequency = 0.5
    flock_node = get_node(flock_node_path)

func _process(delta):
    if wander_enabled:
        wander_and_flee(delta)
    else:
        wasd_movement(delta)

    if Input.is_action_just_pressed("toggle_wander"):
        wander_enabled = !wander_enabled

func wasd_movement(delta):
    var input_dir = Vector3.ZERO
    
    if Input.is_action_pressed("move_right"):
        input_dir.x += 1
    if Input.is_action_pressed("move_left"):
        input_dir.x -= 1
    if Input.is_action_pressed("move_forward"):
        input_dir.z -= 1
    if Input.is_action_pressed("move_backward"):
        input_dir.z += 1
    
    input_dir = input_dir.normalized()
    
    global_position += input_dir * move_speed * delta

func wander_and_flee(delta):
    noise_offset += noise_speed * delta

    var to_world_center = -global_position
    var distance_to_center = to_world_center.length()

    var center_force = clamp(inverse_lerp(min_radius, max_radius, distance_to_center), 0.0, 1.0)
    
    var flee_direction = Vector3.ZERO
    var closest_distance = INF
    for flock_member in flock_node.get_children():
        var distance = global_position.distance_to(flock_member.global_position)
        if distance < flee_distance and distance < closest_distance:
            closest_distance = distance
            flee_direction = global_position - flock_member.global_position

    to_world_center = to_world_center.normalized()
    flee_direction = flee_direction.normalized()

    var noise_angle = noise.get_noise_1d(noise_offset) * PI * world_noise_strength

    var desired_direction = to_world_center.rotated(Vector3.UP, noise_angle)
    
    var turn_around_strength = clamp(inverse_lerp(max_radius - turn_around_zone, max_radius, distance_to_center), 0.0, 1.0)
    desired_direction = desired_direction.lerp(to_world_center, turn_around_strength)

    if flee_direction != Vector3.ZERO:
        var flee_blend = clamp(inverse_lerp(flee_distance, 0, closest_distance), 0.0, 1.0)
        desired_direction = desired_direction.lerp(flee_direction, flee_blend)

    desired_direction = desired_direction.normalized()

    var flee_intensity = clamp(1.0 - inverse_lerp(0, flee_distance, closest_distance), 0.0, 1.0)
    var max_angle_change = lerp(min_turn_angle, max_turn_angle, max(1.0 - center_force, flee_intensity, turn_around_strength))

    var angle_to_desired = current_direction.angle_to(desired_direction)
    var clamped_angle = clamp(angle_to_desired, 0, max_angle_change)

    var new_direction: Vector3
    if angle_to_desired > 0.001:
        var cross_product = current_direction.cross(desired_direction)
        if cross_product.length() > 0.001:
            new_direction = current_direction.rotated(cross_product.normalized(), clamped_angle)
        else:
            new_direction = current_direction
    else:
        new_direction = current_direction

    new_direction = new_direction.normalized()
    current_direction = current_direction.slerp(new_direction, clamp(turn_speed * delta, 0.0, 1.0)).normalized()

    var speed = lerp(wander_speed, flee_speed, flee_intensity)
    var movement = current_direction * speed * delta
    
    var new_position = global_position + movement
    if new_position.length() > max_radius:
        new_position = new_position.normalized() * max_radius

    if is_valid_vector3(new_position):
        global_position = new_position
    else:
        print("Invalid new position: ", new_position)

    var look_target = global_position + current_direction
    if look_target.distance_to(global_position) > 0.001 and is_valid_vector3(look_target):
        var new_transform = global_transform.looking_at(look_target, Vector3.UP)
        if is_valid_transform(new_transform):
            global_transform = new_transform
        else:
            print("Invalid transform when looking at: ", look_target)

    global_position.y = 0

func is_valid_vector3(v: Vector3) -> bool:
    return v.is_finite()

func is_valid_transform(t: Transform3D) -> bool:
    return is_valid_vector3(t.origin) and t.basis.is_finite()
