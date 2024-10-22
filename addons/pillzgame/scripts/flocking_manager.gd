@tool
extends Node3D

@export_range(0.1, 5.0, 0.1, "or_greater") var point_radius: float = 1.0:
    set(value):
        point_radius = value
        update_all_radius_visualizations()

@export_range(1.0, 20.0, 0.1, "or_greater") var max_speed: float = 7.0:
    set(value):
        max_speed = value
        update_point_speeds()

@export_range(1.0, 50.0, 0.1, "or_greater") var max_force: float = 24.0
@export_range(0.1, 10.0, 0.1, "or_greater") var turn_speed: float = 2.0
@export var fixed_y_position: float = 0.0

@export_group("Target Parameters", "target_")
@export var target_nodes_paths: Array[NodePath] = []
@export var target_node_path: NodePath
@export_range(1.0, 100.0, 0.1, "or_greater") var target_detection_range: float = 42.0
@export_range(0.1, 50.0, 0.1, "or_greater") var target_weight: float = 25.0

@export_group("Flocking Parameters", "flock_")
@export var flocking_enabled: bool = true
@export var flocking_debug_scene: PackedScene
@export_range(0.1, 10.0, 0.1, "or_greater") var flock_min_distance_between_points: float = 2.0
@export_range(0.1, 10.0, 0.1, "or_greater") var flock_min_distance_to_target: float = 1.5
@export_range(1.0, 50.0, 0.1, "or_greater") var flock_neighbor_distance: float = 12.0
@export_range(1, 20, 1) var flock_max_neighbors: int = 7
@export_range(0.1, 50.0, 0.1, "or_greater") var flock_separation_weight: float = 25.0
@export_range(0.1, 50.0, 0.1, "or_greater") var flock_alignment_weight: float = 17.0
@export_range(0.1, 50.0, 0.1, "or_greater") var flock_cohesion_weight: float = 15.0

@export_range(0.1, 5.0, 0.1) var min_speed: float = 0.1
@export_range(1.0, 20.0, 0.1) var rotation_smoothing: float = 10.0

@export_group("Speed Randomization", "speed_")
@export_range(1.0, 10.0, 0.1) var speed_min_max: float = 5.0
@export_range(5.0, 20.0, 0.1) var speed_max_max: float = 9.0
@export_range(0.1, 5.0, 0.1) var speed_min_turn: float = 1.5
@export_range(1.0, 10.0, 0.1) var speed_max_turn: float = 2.5

@export_group("Editor Controls")
@export var reset_positions: bool = false:
    set(value):
        reset_positions = false
        if Engine.is_editor_hint():
            call_deferred("reset_to_initial_positions")

@export_group("World Boundaries")
@export var min_radius: float = 20.0
@export var max_radius: float = 100.0
@export var turn_around_zone: float = 10.0

var target_node: Node3D
var target_nodes: Array[Node3D] = []

var scattered_points = []
var velocities = {}
var point_speeds = {}

# Spatial grid variables
var grid_size: float = 20.0  # Increased grid size for fewer cells
var spatial_grid = {}
var update_counter: int = 0
var update_frequency: int = 10  # Reduced update frequency

# Precomputed values
var neighbor_distance_squared: float
var min_distance_squared: float

# New variables for randomization
@export var min_max_speed: float = 5.0
@export var max_max_speed: float = 9.0
@export var min_turn_speed: float = 1.5
@export var max_turn_speed: float = 2.5

var initial_positions = {}

var noise: FastNoiseLite

func _ready():
    initialize_noise()
    
    if not Engine.is_editor_hint():
        # Filter and cast children to Node3D
        scattered_points = get_children().filter(func(child): return child is Node3D)
        
        for point in scattered_points:
            velocities[point] = Vector3.ZERO
            point.global_position.y = fixed_y_position
            randomize_point_speeds(point)
            initial_positions[point] = point.global_position
        setup_all_flocking_debug()
        
        initialize_targets()
        update_spatial_grid()
        
        # Precompute squared distances
        neighbor_distance_squared = flock_neighbor_distance * flock_neighbor_distance
        min_distance_squared = flock_min_distance_between_points * flock_min_distance_between_points

    initialize_point_speeds()

func initialize_noise():
    noise = FastNoiseLite.new()
    noise.seed = 0 if Engine.is_editor_hint() else randi()
    noise.frequency = 0.01  # Adjust this value as needed
    # You can add more noise parameters here if needed
    # For example:
    # noise.fractal_octaves = 4
    # noise.fractal_lacunarity = 2.0
    # noise.fractal_gain = 0.5

func initialize_targets():
    # Initialize singular target
    if not target_node_path.is_empty():
        target_node = get_node_or_null(target_node_path)
        if target_node and target_node is Node3D:
            target_nodes.append(target_node)
    
    # Initialize multiple targets
    for path in target_nodes_paths:
        var node = get_node_or_null(path)
        if node and node is Node3D and node not in target_nodes:
            target_nodes.append(node)

    if target_nodes.is_empty():
        push_warning("No valid targets found. Please set target_node_path or target_nodes_paths in the inspector.")

func update_target_nodes():
    target_nodes.clear()
    
    # Re-add singular target if it exists
    if target_node and is_instance_valid(target_node):
        target_nodes.append(target_node)
    
    # Re-add multiple targets
    for path in target_nodes_paths:
        var node = get_node_or_null(path)
        if node and node is Node3D and node not in target_nodes:
            target_nodes.append(node)

func _physics_process(delta):
    if Engine.is_editor_hint() or not flocking_enabled:
        return

    update_counter += 1
    if update_counter >= update_frequency:
        update_spatial_grid()
        update_counter = 0

    var forces: Dictionary = {}
    for point in scattered_points:
        forces[point] = calculate_forces(point)

    for point in scattered_points:
        apply_force(point, forces[point], delta)
        enforce_minimum_distances(point)

func update_spatial_grid():
    spatial_grid.clear()
    var inv_grid_size = 1.0 / grid_size
    for point in scattered_points:
        var grid_pos = Vector3(
            floor(point.global_position.x * inv_grid_size),
            floor(point.global_position.y * inv_grid_size),
            floor(point.global_position.z * inv_grid_size)
        )
        if not spatial_grid.has(grid_pos):
            spatial_grid[grid_pos] = []
        spatial_grid[grid_pos].append(point)

func get_nearby_points(point):
    var nearby = []
    var inv_grid_size = 1.0 / grid_size
    var grid_pos = Vector3(
        floor(point.global_position.x * inv_grid_size),
        floor(point.global_position.y * inv_grid_size),
        floor(point.global_position.z * inv_grid_size)
    )
    for x in range(-1, 2):
        for y in range(-1, 2):
            for z in range(-1, 2):
                var check_pos = grid_pos + Vector3(x, y, z)
                if spatial_grid.has(check_pos):
                    nearby.append_array(spatial_grid[check_pos])
    return nearby

func calculate_forces(point: Node3D) -> Vector3:
    var separation = Vector3.ZERO
    var alignment = Vector3.ZERO
    var cohesion = Vector3.ZERO
    var neighbor_count = 0
    
    var nearby_points = get_nearby_points(point)
    var point_pos = point.global_position
    
    for other in nearby_points:
        if other == point:
            continue
        
        var offset = point_pos - other.global_position
        var distance_squared = offset.length_squared()
        
        if distance_squared < neighbor_distance_squared and neighbor_count < flock_max_neighbors:
            var distance = sqrt(distance_squared)
            # Separation
            separation += offset.normalized() / distance
            
            # Alignment
            alignment += velocities[other]
            
            # Cohesion
            cohesion += other.global_position
            
            neighbor_count += 1
    
    var flocking_force = Vector3.ZERO
    if neighbor_count > 0:
        separation = separation / neighbor_count * flock_separation_weight
        alignment = (alignment / neighbor_count - velocities[point]) * flock_alignment_weight
        cohesion = ((cohesion / neighbor_count) - point_pos) * flock_cohesion_weight
        flocking_force = separation + alignment + cohesion
    
    var target_force = calculate_target_force(point)
    
    return flocking_force + target_force

func calculate_target_force(point: Node3D) -> Vector3:
    var closest_target = null
    var closest_distance = INF
    
    for target in target_nodes:
        var distance = point.global_position.distance_to(target.global_position)
        if distance < closest_distance and distance < target_detection_range:
            closest_distance = distance
            closest_target = target
    
    if closest_target:
        return (closest_target.global_position - point.global_position).normalized() * target_weight
    
    return Vector3.ZERO

func apply_force(point: Node3D, force: Vector3, delta: float):
    var acceleration = force.limit_length(max_force)
    velocities[point] += acceleration * delta
    velocities[point] = velocities[point].limit_length(point_speeds[point]["max_speed"])
    
    var new_position = point.global_position + velocities[point] * delta
    var distance_from_center = new_position.length()
    
    if distance_from_center > max_radius:
        # Apply a force to turn around when reaching the max radius
        var turn_force = -new_position.normalized() * turn_around_zone
        velocities[point] += turn_force * delta
        new_position = new_position.normalized() * max_radius
    elif distance_from_center < min_radius:
        # Apply a force to move away from the center when too close
        var away_force = new_position.normalized() * turn_around_zone
        velocities[point] += away_force * delta
    
    point.global_position = new_position
    point.global_position.y = fixed_y_position
    
    if velocities[point].length() > 0.001:
        var look_target = point.global_position + velocities[point]
        point.look_at(look_target, Vector3.UP)

func enforce_minimum_distances(point: Node3D):
    for other in scattered_points:
        if other == point:
            continue
        var offset = other.global_position - point.global_position
        var distance = offset.length()
        if distance < flock_min_distance_between_points:
            var correction = offset.normalized() * (flock_min_distance_between_points - distance) * 0.5
            point.global_position -= correction
            other.global_position += correction

    if target_node:
        var offset_to_target = target_node.global_position - point.global_position
        var distance_to_target = offset_to_target.length()
        if distance_to_target < flock_min_distance_to_target:
            var correction = offset_to_target.normalized() * (flock_min_distance_to_target - distance_to_target)
            point.global_position -= correction

func setup_all_flocking_debug():
    # print("Setting up debug for all points. Total points: ", scattered_points.size())
    for point in scattered_points:
        setup_flocking_debug(point)

func setup_flocking_debug(point: Node3D):
    var existing_debug = point.get_node_or_null("FlockingDebug")
    if existing_debug:
        existing_debug.queue_free()
    
    if flocking_debug_scene:
        var debug_instance = flocking_debug_scene.instantiate()
        point.add_child(debug_instance)
        debug_instance.name = "FlockingDebug"
        
        # Disable shadows for all MeshInstance3D children
        for child in debug_instance.get_children():
            if child is MeshInstance3D:
                child.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
        
        # print("Debug instance added to ", point.name)
        update_radius_visualization(debug_instance)
    else:
        print("Error: flocking_debug_scene is not set")

func update_radius_visualization(debug_instance: Node3D):
    var radius_vis = debug_instance.get_node_or_null("radius_vis")
    if radius_vis:
        var scale_factor = point_radius * 2
        radius_vis.scale = Vector3(scale_factor, scale_factor, scale_factor)
        # print("Updated radius visualization")
    else:
        print("Error: radius_vis node not found in debug instance")

func update_all_radius_visualizations():
    for point in scattered_points:
        update_radius_visualization(point.get_node_or_null("FlockingDebug"))

# func update_flocking_debug(point: Node3D, flocking_force: Vector3, target_force: Vector3):  
#     var debug_instance = point.get_node_or_null("FlockingDebug")
#     if not debug_instance:
#         return
    # var capsule_vis = debug_instance.get_node("capsule_vis")
    # var forward_arrow = debug_instance.get_node("pivot/forward_arrow")
    # var pivot_orient = debug_instance.get_node("pivot")
    # var pivot_flock = debug_instance.get_node("pivot_flock")
    # var pivot_desired = debug_instance.get_node("pivot_desired")
    # var pivot_target = debug_instance.get_node("pivot_target")
    
    # if capsule_vis and forward_arrow:
    #     var closest_target_distance = INF
    #     var closest_target = null
    #     for target in target_nodes:
    #         var distance = point.global_position.distance_to(target.global_position)
    #         if distance < closest_target_distance:
    #             closest_target_distance = distance
    #             closest_target = target
        
    #     # if closest_target:
    #         var color_modulate = max(0, 1 - closest_target_distance / pow(target_detection_range, 0.5))
    #         capsule_vis.set_instance_shader_parameter("ColorModulate", color_modulate)
    #         forward_arrow.set_instance_shader_parameter("ColorModulate", color_modulate)
    #     else:
    #         capsule_vis.set_instance_shader_parameter("ColorModulate", 0)
    #         forward_arrow.set_instance_shader_parameter("ColorModulate", 0)

    # if pivot_orient:
    #     if velocities[point].length() > 0.001:
    #         pivot_orient.look_at(pivot_orient.global_position + velocities[point], Vector3.UP)
    
    # if pivot_flock:
    #     if flocking_force.length() > 0.001:
    #         pivot_flock.look_at(pivot_flock.global_position + flocking_force, Vector3.UP)
    #         pivot_flock.get_node("flock_strength").set_instance_shader_parameter("ColorModulate", flocking_force.length())
    #     else:
    #         pivot_flock.get_node("flock_strength").set_instance_shader_parameter("ColorModulate", 0)

    # if pivot_desired:
    #     if velocities[point].length() > 0.001:
    #         var closest_target = get_closest_target(point)
    #         if closest_target:
    #             var angle_diff = 1 - velocities[point].angle_to((closest_target.global_position - point.global_position).normalized())
    #             pivot_desired.look_at(pivot_desired.global_position + velocities[point], Vector3.UP)

    # if pivot_target:
    #     var closest_target = get_closest_target(point)
    #     if closest_target:
    #         pivot_target.look_at(closest_target.global_position, Vector3.UP)
    #         pivot_target.get_node("target_strength").set_instance_shader_parameter("ColorModulate", target_force.normalized().length())
    #     else:
    #         pivot_target.get_node("target_strength").set_instance_shader_parameter("ColorModulate", 0)

func get_closest_target(point: Node3D) -> Node3D:
    var closest_target = null
    var closest_distance = INF
    for target in target_nodes:
        var distance = point.global_position.distance_to(target.global_position)
        if distance < closest_distance:
            closest_distance = distance
            closest_target = target
    return closest_target

# Add these new functions for managing targets
func add_target(target: Node3D):
    if target and is_instance_valid(target) and target not in target_nodes:
        target_nodes.append(target)

func remove_target(target: Node3D):
    target_nodes.erase(target)

func clear_targets():
    target_nodes.clear()
    if target_node and is_instance_valid(target_node):
        target_nodes.append(target_node)

# Add this function to update the singular target
func set_singular_target(new_target: Node3D):
    target_node = new_target
    if new_target and is_instance_valid(new_target):
        if new_target not in target_nodes:
            target_nodes.append(new_target)
    else:
        target_nodes.erase(target_node)

# Add these functions to control flocking behavior
func enable_flocking():
    flocking_enabled = true

func disable_flocking():
    flocking_enabled = false

func toggle_flocking():
    flocking_enabled = not flocking_enabled

func randomize_point_speeds(point: Node3D):
    point_speeds[point] = {
        "max_speed": randf_range(min_max_speed, max_max_speed),
        "turn_speed": randf_range(min_turn_speed, max_turn_speed)
    }

func reset_to_initial_positions():
    # print("Resetting positions...")
    for point in scattered_points:
        if point in initial_positions:
            point.global_position = initial_positions[point]
        else:
            print("Warning: No initial position stored for ", point.name)
    
    # Reset velocities
    for point in velocities.keys():
        velocities[point] = Vector3.ZERO
    
    # Update the spatial grid after resetting positions
    update_spatial_grid()
    # print("Positions reset complete.")

func initialize_point_speeds():
    for point in scattered_points:
        randomize_point_speed(point)

func randomize_point_speed(point: Node3D):
    point_speeds[point] = {
        "max_speed": randf_range(speed_min_max, speed_max_max),
        "turn_speed": randf_range(speed_min_turn, speed_max_turn)
    }

func update_point_speeds():
    for point in scattered_points:
        if point in point_speeds:
            point_speeds[point]["max_speed"] = min(point_speeds[point]["max_speed"], max_speed)

