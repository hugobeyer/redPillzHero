extends RigidBody3D

@export var explosion_radius: float = 15.0
@export var explosion_force: float = 25.0
@export var damage: float = 100.0
@export var fuse_time: float = 2.0
@export var explosion_effect_scene: PackedScene
@export var effect_animation_time: float = 1.25
@export var animation_name: String = "explode"

var time_alive: float = 0.0

func _ready():
    time_alive = 0.0

func _physics_process(delta: float) -> void:
    time_alive += delta
    if time_alive >= fuse_time:
        explode()

func explode():
    # Instantiate the explosion effect
    if explosion_effect_scene:
        var explosion_effect = explosion_effect_scene.instantiate()
        get_tree().root.add_child(explosion_effect)
        explosion_effect.global_position = global_position
        
        var anim_player = explosion_effect.get_node("AnimationPlayer")
        if anim_player:
            anim_player.play(animation_name)
        
        get_tree().create_timer(effect_animation_time).timeout.connect(
            func(): explosion_effect.queue_free()
        )

    # Apply explosion effects to enemies
    var enemies = get_tree().get_nodes_in_group("enemies")
    for enemy in enemies:
        if is_instance_valid(enemy):
            var enemy_position = enemy.global_position
            var distance = global_position.distance_to(enemy_position)
            if distance <= explosion_radius:
                apply_explosion_damage(enemy, distance)
    
    queue_free()

func apply_explosion_damage(target, distance):
    var direction = (target.global_position - global_position).normalized()
    direction.y = 0  # Ensure movement is only in the XZ plane
    
    # Calculate damage falloff based on distance
    var damage_multiplier = 1.0 - (distance / explosion_radius)
    damage_multiplier = clamp(damage_multiplier, 0.0, 1.0)
    var final_damage = damage * damage_multiplier
    
    if target.has_method("hit"):
        target.hit(direction, final_damage)
        
        # Apply knockback through flocking manager
        var parent_point = target.get_parent()
        if parent_point and is_instance_valid(parent_point):
            var flocking_manager = parent_point.get_parent()
            if flocking_manager and flocking_manager.has_method("apply_point_knockback"):
                flocking_manager.apply_point_knockback(parent_point, direction, explosion_force * damage_multiplier)

func _integrate_forces(state):
    if state.get_contact_count() > 0:
        print("Grenade touched something!")
        explode()
