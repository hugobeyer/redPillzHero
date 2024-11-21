@tool
extends Node3D
@export var flocking_enabled: bool = true
@export var flocking_agent: PackedScene
@export var target_nodes_paths: Array[NodePath] = []
@export var target_node_path: NodePath
@export_range(1.0, 100.0, 0.1, "or_greater") var target_detection_range: float = 42.0
@export_range(0.1, 50.0, 0.1, "or_greater") var target_weight: float = 25.0
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


@export_group("Speed Randomization", "speed_")
@export var min_max_speed: float = 5.0
@export var max_max_speed: float = 9.0
@export var min_turn_speed: float = 1.5
@export var max_turn_speed: float = 5.5

@export_group("Flocking Parameters", "flock_")
@export_range(0.1, 10.0, 0.1, "or_greater") var flock_min_distance_between_points: float = 2.0
@export_range(0.1, 10.0, 0.1, "or_greater") var flock_min_distance_to_target: float = 1.5
@export_range(1.0, 50.0, 0.1, "or_greater") var flock_neighbor_distance: float = 12.0
@export_range(1, 20, 1) var flock_max_neighbors: int = 7
@export_range(0.1, 50.0, 0.1, "or_greater") var flock_separation_weight: float = 25.0
@export_range(0.1, 50.0, 0.1, "or_greater") var flock_alignment_weight: float = 17.0
@export_range(0.1, 50.0, 0.1, "or_greater") var flock_cohesion_weight: float = 15.0

@export_group("Editor Controls")
@export var reset_positions: bool = false:
    set(value):
        reset_positions = false
        if Engine.is_editor_hint():
            call_deferred("reset_to_initial_positions")

@export_group("Editor Preview")
@export var preview_scene: PackedScene:
    set(value):
        preview_scene = value
        if Engine.is_editor_hint():
            update_preview_scenes()

@export_group("Collision")
@export var use_navigation: bool = true
@export var nav_path_ahead_distance: float = 3.0

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


var initial_positions = {}

var noise: FastNoiseLite

var point_ids = {}  # Track points by their instance ID

# Add to variables at top
var point_knockback_velocities: Dictionary = {}

# Add these variables at the top with other vars
var cached_forces = {}
var cache_time = 0.05
var time_since_cache = 0.0

func _ready():
    initialize_noise()
    
    if Engine.is_editor_hint():
        # Only handle preview scenes in editor
        return
        
    # Remove any preview scenes that might exist
    for point in get_children():
        var preview = point.get_node_or_null("Preview")
        if preview:
            preview.queue_free()
    
    scattered_points = get_children().filter(func(child): return child is Node3D)
    
    for point in scattered_points:
        var point_id = point.get_instance_id()
        point_ids[point_id] = point
        velocities[point_id] = Vector3.ZERO
        point.global_position.y = fixed_y_position
        randomize_point_speeds(point)
        initial_positions[point_id] = point.global_position
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

    # Filter out invalid points
    scattered_points = scattered_points.filter(func(p): return is_instance_valid(p))

    # Process knockback velocities first
    for point in scattered_points:
        var point_id = point.get_instance_id()
        if point_id in point_knockback_velocities:
            var knockback_vel = point_knockback_velocities[point_id]
            point.global_position += knockback_vel * delta
            # Dampen knockback
            point_knockback_velocities[point_id] *= pow(0.1, delta)
            if knockback_vel.length() < 0.01:
                point_knockback_velocities.erase(point_id)

    # Then process regular flocking forces
    update_counter += 1
    if update_counter >= update_frequency:
        update_spatial_grid()
        update_counter = 0

    time_since_cache += delta
    if time_since_cache >= cache_time:
        cached_forces.clear()
        time_since_cache = 0.0

    var forces: Dictionary = {}
    for point in scattered_points:
        if is_instance_valid(point):
            forces[point] = calculate_forces(point)

    for point in scattered_points:
        if is_instance_valid(point) and point in forces:
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
    var point_id = point.get_instance_id()
    
    # Check cache first
    if point_id in cached_forces and time_since_cache < cache_time:
        return cached_forces[point_id]
        
    var total_force = Vector3.ZERO
    
    # Handle knockback separately from other forces
    if point_id in point_knockback_velocities:
        var knockback = point_knockback_velocities[point_id]
        knockback.y = 0  # Ensure Y stays at zero during lerp
        point.global_position += knockback * get_physics_process_delta_time()
        point_knockback_velocities[point_id] = knockback.lerp(Vector3.ZERO, get_physics_process_delta_time() * 3.0)
        if point_knockback_velocities[point_id].length() < 0.01:
            point_knockback_velocities.erase(point_id)
    
    # Calculate regular flocking forces
    var flocking_force = calculate_flocking_forces(point)
    total_force += flocking_force
    
    # Cache the result before returning
    cached_forces[point_id] = total_force
    return total_force

func calculate_flocking_forces(point: Node3D) -> Vector3:
    var point_id = point.get_instance_id()
    var total_force = Vector3.ZERO
    
    if not is_instance_valid(point):
        scattered_points.erase(point)
        return Vector3.ZERO
    
    # Calculate distance to closest target for falloff
    var closest_target = get_closest_target(point)
    var flocking_falloff = 1.0
    
    if closest_target:
        var distance_to_target = point.global_position.distance_to(closest_target.global_position)
        # Start reducing flocking at 80% of detection range for more gradual falloff
        var falloff_start = target_detection_range * 0.8
        if distance_to_target < falloff_start:
            flocking_falloff = distance_to_target / falloff_start
            flocking_falloff = clamp(flocking_falloff, 0.3, 1.0)  # Keep more flocking strength (30% minimum)
    
    var separation = Vector3.ZERO
    var alignment = Vector3.ZERO
    var cohesion = Vector3.ZERO
    var neighbor_count = 0
    
    var nearby_points = get_nearby_points(point)
    var point_pos = point.global_position
    
    # Filter out invalid points from nearby_points
    nearby_points = nearby_points.filter(func(p): return is_instance_valid(p))
    
    for other in nearby_points:
        if other == point:
            continue
            
        # Safety check for valid other point
        if not is_instance_valid(other):
            continue
            
        var other_id = other.get_instance_id()
        if not other_id in velocities:
            continue
            
        var offset = point_pos - other.global_position
        var distance_squared = offset.length_squared()
        
        if distance_squared < neighbor_distance_squared and neighbor_count < flock_max_neighbors:
            var distance = sqrt(distance_squared)
            separation += offset.normalized() / distance
            alignment += velocities[other_id]
            cohesion += other.global_position
            neighbor_count += 1
    
    if neighbor_count > 0:
        separation = separation / neighbor_count * flock_separation_weight * flocking_falloff
        alignment = (alignment / neighbor_count - velocities[point_id]) * flock_alignment_weight * flocking_falloff
        cohesion = ((cohesion / neighbor_count) - point.global_position) * flock_cohesion_weight * flocking_falloff
        total_force = separation + alignment + cohesion
    
    var target_force = calculate_target_force(point)
    var nav_force = get_navigation_force(point)
    
    return total_force + target_force + nav_force

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
    var point_id = point.get_instance_id()
    if not point_id in velocities:
        return
    
    var acceleration = force.limit_length(max_force)
    
    # Apply any existing knockback velocity
    if point_id in point_knockback_velocities:
        var knockback = point_knockback_velocities[point_id]
        velocities[point_id] += knockback * delta
        # Reduce knockback over time
        point_knockback_velocities[point_id] *= 0.95  # Damping factor
        
        # Remove very small knockback values
        if point_knockback_velocities[point_id].length() < 0.01:
            point_knockback_velocities.erase(point_id)
    
    velocities[point_id] += acceleration * delta
    velocities[point_id] = velocities[point_id].limit_length(point_speeds[point_id]["max_speed"])
    
    point.global_position += velocities[point_id] * delta
    point.global_position.y = fixed_y_position
    
    # Only rotate if we have significant movement
    if velocities[point_id].length() > 0.001:
        # Create a look target that's always on the XZ plane
        var forward = velocities[point_id].normalized()
        forward.y = 0  # Ensure movement is on XZ plane
        
        # Create look target ahead of current position
        var look_target = point.global_position + forward
        
        # Use basis to ensure Y-axis only rotation
        var current_basis = point.global_transform.basis
        var target_basis = point.global_transform.looking_at(look_target, Vector3.UP).basis
        
        # Interpolate rotation using turn speed
        point.global_transform.basis = current_basis.slerp(target_basis, point_speeds[point_id]["turn_speed"] * delta)

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
    var existing_debug = point.get_node_or_null("Enemy")
    if existing_debug:
        existing_debug.queue_free()
    
    if flocking_agent:
        var enemy_instance = flocking_agent.instantiate()
        point.add_child(enemy_instance)
        enemy_instance.name = "Enemy"
        
        # Disable shadows for all MeshInstance3D children
        for child in enemy_instance.get_children():
            if child is MeshInstance3D:
                child.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
        
        # print("Debug instance added to ", point.name)
        update_radius_visualization(enemy_instance)
    # else:
        # print("Error: flocking_agent is not set")

func update_radius_visualization(enemy_instance: Node3D):
    var radius_vis = enemy_instance.get_node_or_null("radius_vis")
    if radius_vis:
        var scale_factor = point_radius * 2
        radius_vis.scale = Vector3(scale_factor, scale_factor, scale_factor)
        # print("Updated radius visualization")
    # else:
        # print("Error: radius_vis node not found in debug instance")

func update_all_radius_visualizations():
    for point in scattered_points:
        update_radius_visualization(point.get_node_or_null("Enemy"))

func update_flocking_debug(point: Node3D, flocking_force: Vector3, target_force: Vector3):  
    var point_id = point.get_instance_id()
    if not point_id in velocities:
        return
        
    var enemy_instance = point.get_node_or_null("Enemy")
    if not enemy_instance:
        return
        
    var char_mesh_instance = enemy_instance.get_node("CharacterMesh")

    if char_mesh_instance:
        var closest_target_distance = INF
        var closest_target = null
        for target in target_nodes:
            var distance = point.global_position.distance_to(target.global_position)
            if distance < closest_target_distance:
                closest_target_distance = distance
                closest_target = target
        
        if closest_target:
            var color_modulate = max(0, 1 - closest_target_distance / pow(target_detection_range, 0.5))
            char_mesh_instance.set_instance_shader_parameter("ColorModulate", color_modulate)
        else:
            char_mesh_instance.set_instance_shader_parameter("ColorModulate", 0)

    if velocities[point_id].length() > 0.001:
        var closest_target = get_closest_target(point)
        if closest_target:
            var angle_diff = 1 - velocities[point_id].angle_to((closest_target.global_position - point.global_position).normalized())

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

func initialize_point_speeds():
    for point in scattered_points:
        randomize_point_speeds(point)

func randomize_point_speeds(point: Node3D):
    var point_id = point.get_instance_id()
    point_speeds[point_id] = {
        "max_speed": randf_range(min_max_speed, max_max_speed),
        "turn_speed": randf_range(min_turn_speed, max_turn_speed)
    }

func reset_to_initial_positions():
    # print("Resetting positions...")
    for point in scattered_points:
        if point in initial_positions:
            point.global_position = initial_positions[point]
        # else:
        #     print("Warning: No initial position stored for ", point.name)
    
    # Reset velocities
    for point in velocities.keys():
        velocities[point] = Vector3.ZERO
    
    # Update the spatial grid after resetting positions
    update_spatial_grid()
    # print("Positions reset complete.")

func update_point_speeds():
    for point in scattered_points:
        if point in point_speeds:
            point_speeds[point]["max_speed"] = min(point_speeds[point]["max_speed"], max_speed)

func update_preview_scenes():
    if not Engine.is_editor_hint():
        return
        
   
    # Find ScatteredPoints node
    # var scattered_points = get_tree().get_nodes_in_group("ScatteredPoints")
    # if scattered_points.is_empty():
    #     var scattered_container = get_node_or_null("../ScatteredPoints")
    #     if scattered_container:
    #         scattered_points = scattered_container.get_children()
    
    # print("Found points:", scattered_points.size())
    
    for point in scattered_points:
        # print("Processing point:", point.name)
        
        # Remove existing preview
        var existing = point.get_node_or_null("Preview")
        if existing:
            existing.queue_free()
            
        # Add new preview if we have a scene
        if preview_scene:
            var preview = preview_scene.instantiate()
            preview.name = "Preview"
            point.add_child(preview)
            preview.set_owner(get_tree().edited_scene_root)
            # print("Added preview to:", point.name)

# Add this function to remove points from tracking
func remove_point(point: Node3D):
    if not point or not is_instance_valid(point):
        return
        
    var point_id = point.get_instance_id()
    
    # Remove from all tracking
    scattered_points.erase(point)
    if point_id in point_ids:
        point_ids.erase(point_id)
    if point_id in velocities:
        velocities.erase(point_id)
    if point_id in point_speeds:
        point_speeds.erase(point_id)
    if point_id in initial_positions:
        initial_positions.erase(point_id)

func get_navigation_force(point: Node3D) -> Vector3:
    var point_id = point.get_instance_id()
    if not point_id in velocities:
        return Vector3.ZERO
    
    # Get current velocity direction
    var current_velocity = velocities[point_id]
    if current_velocity.length_squared() < 0.001:
        return Vector3.ZERO
    
    # Check point ahead of current movement
    var look_ahead = point.global_position + current_velocity.normalized() * nav_path_ahead_distance
    
    # Get path using NavigationServer3D directly
    var path = NavigationServer3D.map_get_path(
        NavigationServer3D.get_maps()[0],  # Get first navigation map
        point.global_position,
        look_ahead,
        true  # optimize path
    )
    
    # If path exists and has points, use it for steering
    if path.size() > 1:
        var next_point = path[1]
        var desired_velocity = (next_point - point.global_position).normalized() * point_speeds[point_id]["max_speed"]
        return (desired_velocity - current_velocity) * 2.0
    
    return Vector3.ZERO

# Add this function to handle knockback
func apply_point_knockback(point: Node3D, direction: Vector3, force: float):
    var point_id = point.get_instance_id()
    direction.y = 0
    direction = direction.normalized()
    
    # Store raw velocity for physics_process to handle
    point_knockback_velocities[point_id] = direction * force

