extends Area3D

@export_group("General Enemy Parameters")
@export var enable_general_features: bool = true
@export var max_health: float = 100.0
@export var damage: float = 10.0

@onready var mesh_instance = $WobbleEffect/CharacterMesh
@onready var wobble_effect = $WobbleEffect
@onready var effects: EnemyEffects = $EnemyEffects
@onready var health_bar: Sprite3D = $HealthBar
@onready var parent_point = get_parent()
@onready var flocking_manager = parent_point.get_parent()

var _health: float
var _time_alive: float = 0
var _knockback_velocity: Vector3 = Vector3.ZERO

signal enemy_killed(enemy)

func _ready():
    if not Engine.is_editor_hint():
        add_to_group("enemies")
        _health = max_health
        update_health_bar()
        connect("enemy_killed", Callable(self, "_on_enemy_killed"))

func _process(delta):
    if Engine.is_editor_hint():
        return
    _time_alive += delta

func hit(direction: Vector3, hit_damage: float, knockback_force: float = 0.0):
    _health -= hit_damage
    update_health_bar()
    
    if knockback_force > 0:
        _knockback_velocity = direction * knockback_force
    
    if _health <= 0:
        die()
    else:
        if effects:
            effects.apply_damage_effect(direction)
        
        if wobble_effect:
            wobble_effect.apply_hit_wobble(-direction)
        
        if mesh_instance:
            mesh_instance.set_instance_shader_parameter("lerp_wave", 0.5)
            mesh_instance.set_instance_shader_parameter("lerp_color", Color(1.5, 0.1, 0.1, 1.0))
            get_tree().create_timer(0.1).connect("timeout", Callable(self, "_reset_hit_feedback"))

func _reset_hit_feedback():
    if mesh_instance:
        mesh_instance.set_instance_shader_parameter("lerp_wave", 0.0)
        mesh_instance.set_instance_shader_parameter("lerp_color", Color(0.395203, 0.24353, 0.546875, 1))

func die():
    if is_instance_valid(parent_point) and flocking_manager and flocking_manager.has_method("remove_point"):
        flocking_manager.remove_point(parent_point)
    
    emit_signal("enemy_killed", self)
    
    if is_instance_valid(parent_point):
        parent_point.queue_free()
    queue_free()

func update_health_bar():
    if health_bar:
        var health_percent = _health / max_health
        health_bar.set_progress(health_percent, true)
        health_bar.visible = true

func _on_enemy_killed(_enemy):
    pass

func is_being_knocked_back() -> bool:
    return has_meta("original_position")

func _physics_process(delta):
    if _knockback_velocity.length() > 0:
        global_position += _knockback_velocity * delta
        _knockback_velocity = _knockback_velocity.lerp(Vector3.ZERO, delta * 5.0)

