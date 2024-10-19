extends RigidBody3D

@export var damage: float = 0.01
@export var lifetime: float = 1.0
@export var knockback: float = 1.0
@export var max_speed: float = 50.0

var bullet_owner: Node3D = null
var time_alive: float = 0.0
var last_print_time: float = 0.0

var direction: Vector3
var speed: float = 20.0

func _ready():
	body_entered.connect(_on_body_entered)
	contact_monitor = true
	max_contacts_reported = 1

func _physics_process(delta: float) -> void:
	time_alive += delta
	if time_alive >= lifetime or not is_position_finite():
		queue_free()
		return
	
	# Clamp the velocity to the maximum speed
	if linear_velocity.length() > max_speed:
		linear_velocity = linear_velocity.normalized() * max_speed
	
	perform_raycast()
	
	if time_alive - last_print_time >= 0.5:
		last_print_time = time_alive

func is_position_finite() -> bool:
	return global_transform.origin.is_finite() and linear_velocity.is_finite()

func perform_raycast():
	if not is_position_finite():
		queue_free()
		return
	
	var space_state = get_world_3d().direct_space_state
	if space_state:
		var from = global_transform.origin
		var to = from + linear_velocity.normalized() * 2.0
		var query = PhysicsRayQueryParameters3D.create(from, to)
		var result = space_state.intersect_ray(query)
		if result:
			print("Raycast Hit: ", result.collider.name)
			if result.collider.has_method("hit"):
				result.collider.hit(-linear_velocity.normalized(), damage, linear_velocity.length())
			queue_free()

func _on_body_entered(body: Node3D) -> void:
	if body == bullet_owner:
		return
	if body.has_method("hit"):
		body.hit(-linear_velocity.normalized(), damage, linear_velocity.length())
	queue_free()

func set_velocity(new_velocity: Vector3) -> void:
	if new_velocity.is_finite():
		# Clamp the new velocity to the maximum speed
		linear_velocity = new_velocity.limit_length(max_speed)
	else:
		print("Warning: Attempted to set non-finite velocity")
		queue_free()

func set_damage(value: float):
	damage = value

func set_lifetime(value: float):
	lifetime = value

func set_knockback(value: float):
	knockback = value

func set_bullet_owner(new_owner: Node3D):
	bullet_owner = new_owner

func shoot(initial_position: Vector3, shoot_direction: Vector3):
	if initial_position.is_finite() and shoot_direction.is_finite():
		global_transform.origin = initial_position
		# Clamp the initial velocity to the maximum speed
		linear_velocity = (shoot_direction.normalized() * max_speed).limit_length(max_speed)
	else:
		print("Warning: Attempted to shoot with non-finite values")
		queue_free()
