@tool
extends Node3D

@export var point_count: int = 10:
    set(value):
        point_count = value
        scatter_points()

@export var scatter_radius: float = 10.0:
    set(value):
        scatter_radius = value
        scatter_points()

var points: Array[Node3D] = []

func _ready():
    if Engine.is_editor_hint():
        scatter_points()

func scatter_points():
    # Clear existing points
    for point in points:
        if is_instance_valid(point):
            point.queue_free()
    points.clear()

    # Scatter new points
    for i in range(point_count):
        var point = Node3D.new()
        point.name = "ScatteredPoint_" + str(i)
        
        # Generate random position within scatter radius
        var random_position = Vector3(
            randf_range(-scatter_radius, scatter_radius),
            randf_range(-scatter_radius, scatter_radius),
            randf_range(-scatter_radius, scatter_radius)
        )
        point.global_position = global_position + random_position
        
        add_child(point)
        point.owner = get_tree().edited_scene_root
        points.append(point)

func _notification(what):
    if what == NOTIFICATION_EDITOR_POST_SAVE:
        scatter_points()

