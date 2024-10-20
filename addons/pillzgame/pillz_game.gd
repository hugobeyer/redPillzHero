@tool
extends EditorPlugin

var sphere_gizmo

func _enter_tree():
	# Register custom node
	add_custom_type("PillzGizmoSphere", "Node3D", preload("res://addons/pillzgame/scripts/pillz_gizmo_sphere.gd"), preload("res://addons/pillzgame/pillz_icon.png"))
	
	# Register gizmo
	sphere_gizmo = preload("res://addons/pillzgame/scripts/gizmos/sphere_gizmo.gd").new()
	add_node_3d_gizmo_plugin(sphere_gizmo)
	pass


func _exit_tree():
	# Unregister custom node
	remove_custom_type("PillzGizmoSphere")
	
	# Unregister gizmo
	remove_node_3d_gizmo_plugin(sphere_gizmo)
	pass

class GizmoInspectorPlugin extends EditorInspectorPlugin:
	var gizmo

	func _can_handle(object):
		return object is Node3D

	func _parse_begin(object):
		if object is Node3D:
			var properties = gizmo.get_script().get_script_property_list()
			for property in properties:
				if property["usage"] & PROPERTY_USAGE_EDITOR:
					add_property_editor(property["name"], GizmoPropertyEditor.new(gizmo, property["name"]))

class GizmoPropertyEditor extends EditorProperty:
	var gizmo
	var property_name

	func _init(p_gizmo, p_property_name):
		gizmo = p_gizmo
		property_name = p_property_name

	func _update_property():
		var new_value = gizmo.get(property_name)
		if new_value != get_edited_object().get(property_name):
			get_edited_object().set(property_name, new_value)
