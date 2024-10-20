@tool
extends EditorNode3DGizmoPlugin

var color_base := Color(1, 0.5, 0)
var x_color := color_base
var y_color := color_base
var z_color := color_base
var forward_color := Color(0, 0.25, 1)  # Blue
var up_color := Color(1, 0.25, 0)  # Red

func _init():
    create_material("main", Color(1, 1, 1))

func _has_gizmo(node):
    return node is PillzGizmoSphere

func _redraw(gizmo):
    gizmo.clear()
    
    var node = gizmo.get_node_3d()
    var uniform_size = node.gizmo_uniform_size
    var torus_radius = node.gizmo_torus_radius
    var torus_resolution = node.gizmo_torus_resolution
    var arrow_length = node.gizmo_arrow_length
    var arrow_radius = node.gizmo_arrow_radius
    
    var circles = [
        {"color": x_color, "rotation": Vector3(0, 0, 0)},
        {"color": y_color, "rotation": Vector3(0, deg_to_rad(90), 0)},
        {"color": z_color, "rotation": Vector3(deg_to_rad(90), 0, 0)}
    ]
    
    for circle_data in circles:
        var torus_points = PackedVector3Array()
        var torus_normals = PackedVector3Array()
        for i in range(torus_resolution):
            var angle = i * TAU / torus_resolution
            var next_angle = (i + 1) * TAU / torus_resolution
            
            var point1 = Vector3(cos(angle), sin(angle), 0) * (uniform_size - torus_radius)
            var point2 = Vector3(cos(angle), sin(angle), 0) * (uniform_size + torus_radius)
            var point3 = Vector3(cos(next_angle), sin(next_angle), 0) * (uniform_size + torus_radius)
            var point4 = Vector3(cos(next_angle), sin(next_angle), 0) * (uniform_size - torus_radius)
            
            var normal = Vector3(cos(angle), sin(angle), 0).normalized()
            var next_normal = Vector3(cos(next_angle), sin(next_angle), 0).normalized()
            
            for point in [point1, point2, point3, point4]:
                point = point.rotated(Vector3(1, 0, 0), circle_data["rotation"].x)
                point = point.rotated(Vector3(0, 1, 0), circle_data["rotation"].y)
                point = point.rotated(Vector3(0, 0, 1), circle_data["rotation"].z)
                torus_points.append(point)
            
            for _i in range(4):
                normal = normal.rotated(Vector3(1, 0, 0), circle_data["rotation"].x)
                normal = normal.rotated(Vector3(0, 1, 0), circle_data["rotation"].y)
                normal = normal.rotated(Vector3(0, 0, 1), circle_data["rotation"].z)
                torus_normals.append(normal)
        
        gizmo.add_mesh(torus_points, torus_normals, [], get_material("main", gizmo), Transform3D(), circle_data["color"])
    
    # Add forward arrow (blue)
    var forward_arrow = create_cylinder(Vector3.ZERO, Vector3(0, 0, arrow_length * uniform_size), arrow_radius)
    gizmo.add_mesh(forward_arrow[0], forward_arrow[1], [], get_material("main", gizmo), Transform3D(), forward_color)
    
    # Add up arrow (red)
    var up_arrow = create_cylinder(Vector3.ZERO, Vector3(0, arrow_length * uniform_size, 0), arrow_radius)
    gizmo.add_mesh(up_arrow[0], up_arrow[1], [], get_material("main", gizmo), Transform3D(), up_color)

func create_cylinder(start: Vector3, end: Vector3, radius: float) -> Array:
    var cylinder_points = PackedVector3Array()
    var cylinder_normals = PackedVector3Array()
    var segments = 8
    var direction = (end - start).normalized()
    var perpendicular = direction.cross(Vector3.UP).normalized()
    if perpendicular.length() < 0.001:
        perpendicular = direction.cross(Vector3.RIGHT).normalized()
    
    for i in range(segments):
        var angle = i * TAU / segments
        var next_angle = (i + 1) * TAU / segments
        
        var point1 = start + perpendicular.rotated(direction, angle) * radius
        var point2 = end + perpendicular.rotated(direction, angle) * radius
        var point3 = end + perpendicular.rotated(direction, next_angle) * radius
        var point4 = start + perpendicular.rotated(direction, next_angle) * radius
        
        var normal1 = (point1 - start).normalized()
        var normal2 = (point2 - end).normalized()
        var normal3 = (point3 - end).normalized()
        var normal4 = (point4 - start).normalized()
        
        cylinder_points.append_array([point1, point2, point3, point1, point3, point4])
        cylinder_normals.append_array([normal1, normal2, normal3, normal1, normal3, normal4])
    
    return [cylinder_points, cylinder_normals]

func _get_gizmo_name():
    return "PillzGizmoSphere"
