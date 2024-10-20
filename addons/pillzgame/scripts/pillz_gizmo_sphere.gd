@tool
extends Node3D

class_name PillzGizmoSphere

@export var gizmo_uniform_size: float = 1.0:
    set(value):
        gizmo_uniform_size = value
        update_gizmo()

@export var gizmo_torus_radius: float = 0.05:
    set(value):
        gizmo_torus_radius = value
        update_gizmo()

@export_range(8, 64, 1) var gizmo_torus_resolution: int = 32:
    set(value):
        gizmo_torus_resolution = value
        update_gizmo()

@export var gizmo_arrow_length: float = 1.2:
    set(value):
        gizmo_arrow_length = value
        update_gizmo()

@export var gizmo_arrow_radius: float = 0.02:
    set(value):
        gizmo_arrow_radius = value
        update_gizmo()

func _ready():
    if Engine.is_editor_hint():
        update_gizmo()

func update_gizmo():
    if Engine.is_editor_hint():
        notify_property_list_changed()
