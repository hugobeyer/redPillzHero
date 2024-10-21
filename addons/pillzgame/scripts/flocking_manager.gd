extends Node3D

@export var point_radius: float = 0.5:
    set(value):
        point_radius = value
        update_all_radius_visualizations()

@export var min_distance_between_points: float = 0.1
@export var min_distance_to_target: float = 0.5
@export var separation_weight: float = 1.0
@export var alignment_weight: float = 1.0
@export var cohesion_weight: float = 1.0
@export var target_weight: float = 1.0
@export var max_speed: float = 5.0
@export var max_force: float = 0.1
@export var turn_speed: float = 2.0
@export var flock_neighbor_distance: float = 5.0
@export var target_detection_range: float = 10.0
@export var fixed_y_position: float = 0.0
@export var target_node_path: NodePath
@export var flocking_debug_scene: PackedScene:
    set(value):
        flocking_debug_scene = value
        setup_all_flocking_debug()

@export var target_nodes_paths: Array[NodePath] = []
var target_node: Node3D
var target_nodes: Array[Node3D] = []

var scattered_points: Array = []
var velocities: Dictionary = {}

@export var max_neighbors: int = 7  # Maximum number of neighbors to consider for flocking

func _ready():
    scattered_points = get_children().filter(func(child): return child is Node3D)
    for point in scattered_points:
        velocities[point] = Vector3.ZERO
        point.global_position.y = fixed_y_position
    setup_all_flocking_debug()
    
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

func _physics_process(delta):
    for point in scattered_points:
        var flocking_force = calculate_flocking_force(point)
        var target_force = calculate_target_force(point)
        
        var total_force = flocking_force + target_force
        apply_force(point, total_force, delta)
        
        enforce_minimum_distances(point)
        update_flocking_debug(point, flocking_force, target_force)

func calculate_flocking_force(point: Node3D) -> Vector3:
    var separation = Vector3.ZERO
    var alignment = Vector3.ZERO
    var cohesion = Vector3.ZERO
    var neighbors = []
    
    for other in scattered_points:
        if other == point:
            continue
        var distance = point.global_position.distance_to(other.global_position)
        if distance < flock_neighbor_distance:
            neighbors.append({"point": other, "distance": distance})
    
    # Sort neighbors by distance and limit to max_neighbors
    neighbors.sort_custom(func(a, b): return a["distance"] < b["distance"])
    neighbors = neighbors.slice(0, max_neighbors)
    
    for neighbor in neighbors:
        var other = neighbor["point"]
        var distance = neighbor["distance"]
        
        separation += (point.global_position - other.global_position) / distance
        alignment += velocities[other]
        cohesion += other.global_position
    
    var neighbor_count = neighbors.size()
    if neighbor_count > 0:
        separation /= neighbor_count
        alignment /= neighbor_count
        cohesion = (cohesion / neighbor_count) - point.global_position
        
        separation = separation.normalized() * max_speed * separation_weight
        alignment = alignment.normalized() * max_speed * alignment_weight
        cohesion = cohesion.normalized() * max_speed * cohesion_weight
    
    return separation + alignment + cohesion

func calculate_target_force(point: Node3D) -> Vector3:
    var closest_target: Node3D = null
    var closest_distance = INF

    for target in target_nodes:
        if is_instance_valid(target):
            var to_target = target.global_position - point.global_position
            var distance = to_target.length()
            
            if distance < target_detection_range and distance < closest_distance:
                closest_distance = distance
                closest_target = target

    if closest_target:
        var to_target = closest_target.global_position - point.global_position
        var desired_velocity = to_target.normalized() * max_speed
        return (desired_velocity - velocities[point]) * target_weight

    return Vector3.ZERO

func apply_force(point: Node3D, force: Vector3, delta: float):
    velocities[point] += force.limit_length(max_force) * delta
    velocities[point] = velocities[point].limit_length(max_speed)
    
    var new_position = point.global_position + velocities[point] * delta
    new_position.y = fixed_y_position
    
    if velocities[point].length() > 0.001:
        var target_transform = point.global_transform.looking_at(new_position, Vector3.UP)
        point.global_transform = point.global_transform.interpolate_with(target_transform, turn_speed * delta)
    
    point.global_position = new_position

func enforce_minimum_distances(point: Node3D):
    for other in scattered_points:
        if other == point:
            continue
        var offset = other.global_position - point.global_position
        var distance = offset.length()
        if distance < min_distance_between_points:
            var correction = offset.normalized() * (min_distance_between_points - distance) * 0.5
            point.global_position -= correction
            other.global_position += correction

    if target_node:
        var offset_to_target = target_node.global_position - point.global_position
        var distance_to_target = offset_to_target.length()
        if distance_to_target < min_distance_to_target:
            var correction = offset_to_target.normalized() * (min_distance_to_target - distance_to_target)
            point.global_position -= correction

func setup_all_flocking_debug():
    for point in scattered_points:
        setup_flocking_debug(point)

func setup_flocking_debug(point: Node3D):
    var existing_debug = point.get_node_or_null("FlockingDebug")
    if existing_debug:
        existing_debug.queue_free()
    
    if flocking_debug_scene:
        var debug_instance = flocking_debug_scene.instantiate()
        point.add_child(debug_instance)
        update_radius_visualization(debug_instance)

func update_radius_visualization(debug_instance: Node3D):
    var radius_vis = debug_instance.get_node("radius_vis")
    if radius_vis:
        # Scale the visualization based on the point_radius
        var scale_factor = point_radius * 2  # Diameter
        radius_vis.scale = Vector3(scale_factor, scale_factor, scale_factor)

func update_all_radius_visualizations():
    for point in scattered_points:
        update_radius_visualization(point)

func update_flocking_debug(point: Node3D, flocking_force: Vector3, target_force: Vector3):
    var debug_instance = point.get_node_or_null("FlockingDebug")
    if not debug_instance:
        return
    var capsule_vis = debug_instance.get_node("capsule_vis")
    var forward_arrow = debug_instance.get_node("pivot/forward_arrow")
    var pivot_orient = debug_instance.get_node("pivot")
    var pivot_flock = debug_instance.get_node("pivot_flock")
    var pivot_desired = debug_instance.get_node("pivot_desired")
    var pivot_target = debug_instance.get_node("pivot_target")
    
    if capsule_vis and forward_arrow:
        var closest_target_distance = INF
        var closest_target = null
        for target in target_nodes:
            var distance = point.global_position.distance_to(target.global_position)
            if distance < closest_target_distance:
                closest_target_distance = distance
                closest_target = target
        
        if closest_target:
            var color_modulate = max(0, 1 - closest_target_distance / pow(target_detection_range, 0.5))
            capsule_vis.set_instance_shader_parameter("ColorModulate", color_modulate)
            forward_arrow.set_instance_shader_parameter("ColorModulate", color_modulate)
        else:
            capsule_vis.set_instance_shader_parameter("ColorModulate", 0)
            forward_arrow.set_instance_shader_parameter("ColorModulate", 0)

    if pivot_orient:
        if velocities[point].length() > 0.001:
            pivot_orient.look_at(pivot_orient.global_position + velocities[point], Vector3.UP)
    
    if pivot_flock:
        if flocking_force.length() > 0.001:
            pivot_flock.look_at(pivot_flock.global_position + flocking_force, Vector3.UP)
            pivot_flock.get_node("flock_strength").set_instance_shader_parameter("ColorModulate", flocking_force.length())
        else:
            pivot_flock.get_node("flock_strength").set_instance_shader_parameter("ColorModulate", 0)

    if pivot_desired:
        if velocities[point].length() > 0.001:
            var closest_target = get_closest_target(point)
            if closest_target:
                var angle_diff = 1 - velocities[point].angle_to((closest_target.global_position - point.global_position).normalized())
                pivot_desired.look_at(pivot_desired.global_position + velocities[point], Vector3.UP)

    if pivot_target:
        var closest_target = get_closest_target(point)
        if closest_target:
            pivot_target.look_at(closest_target.global_position, Vector3.UP)
            pivot_target.get_node("target_strength").set_instance_shader_parameter("ColorModulate", target_force.normalized().length())
        else:
            pivot_target.get_node("target_strength").set_instance_shader_parameter("ColorModulate", 0)

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
