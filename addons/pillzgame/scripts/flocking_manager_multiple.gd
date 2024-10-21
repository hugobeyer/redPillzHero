extends "res://addons/pillzgame/scripts/flocking_manager.gd"

@export var targets_node_path: NodePath
var targets: Array = []

func _ready():
    super._ready()  # Call the parent _ready function
    
    if not targets_node_path.is_empty():
        var targets_parent = get_node_or_null(targets_node_path)
        if targets_parent:
            targets = targets_parent.get_children()
        else:
            push_error("Could not find targets node at path: " + str(targets_node_path))
    elif not target_node_path.is_empty():
        var single_target = get_node_or_null(target_node_path)
        if single_target:
            targets = [single_target]
        else:
            push_error("Could not find target node at path: " + str(target_node_path))
    else:
        push_warning("Neither targets_node_path nor target_node_path is set in FlockingManagerMultiple. Please set one in the Inspector.")

# Override the apply_flocking_behavior function
func apply_flocking_behavior(point: Node3D, delta: float):
    var separation = Vector3.ZERO
    var alignment = Vector3.ZERO
    var cohesion = Vector3.ZERO
    var target_attraction = Vector3.ZERO
    var neighbors = 0

    for other in scattered_points:
        if other == point:
            continue
        var distance = point.global_position.distance_to(other.global_position)
        if distance < target_detection_range:
            separation += (point.global_position - other.global_position) / distance
            alignment += other.get_node("Velocity").velocity
            cohesion += other.global_position
            neighbors += 1

    if neighbors > 0:
        separation /= neighbors
        alignment /= neighbors
        cohesion /= neighbors
        cohesion = (cohesion - point.global_position)

    # Calculate attraction to the closest target
    var closest_target_distance = INF
    var closest_target = null
    for target in targets:
        var distance = point.global_position.distance_to(target.global_position)
        if distance < closest_target_distance:
            closest_target_distance = distance
            closest_target = target

    if closest_target:
        target_attraction = closest_target.global_position - point.global_position

    var velocity = point.get_node("Velocity").velocity
    var acceleration = Vector3.ZERO
    acceleration += separation.normalized() * separation_weight
    acceleration += alignment.normalized() * alignment_weight
    acceleration += cohesion.normalized() * cohesion_weight
    acceleration += target_attraction.normalized() * target_weight

    velocity += acceleration * delta
    if velocity.length() > max_speed:
        velocity = velocity.normalized() * max_speed

    point.get_node("Velocity").velocity = velocity

    var new_position = point.global_position + velocity * delta
    point.global_position = new_position

# Additional functions for managing targets
func add_target(target: Node3D):
    if target not in targets:
        targets.append(target)

func remove_target(target: Node3D):
    targets.erase(target)

func clear_targets():
    targets.clear()
