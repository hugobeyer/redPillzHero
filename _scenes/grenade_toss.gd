extends Node3D

@export var grenade_scene: PackedScene
@export var toss_strength: float = 20.0
@export var cooldown_time: float = 1.0

var can_toss: bool = true

func _input(event):
    if event.is_action_pressed("toss_grenade") and can_toss:
        toss_grenade()
        start_cooldown()

func toss_grenade():
    if not grenade_scene:
        return
    
    var grenade = grenade_scene.instantiate()
    grenade.global_transform.origin = global_transform.origin
    
    get_tree().root.add_child(grenade)
    
    var toss_direction = -global_transform.basis.z.normalized()
    grenade.apply_impulse(toss_direction * toss_strength)

func start_cooldown():
    can_toss = false
    await get_tree().create_timer(cooldown_time).timeout
    can_toss = true
