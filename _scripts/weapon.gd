extends Node3D

signal Weapon_fired(recoil_force: Vector3)
signal recoil_reset()

#✦ 🔫 BULLET PARAMETERS 🔫                              ✦
#╘═════════════════════════════════════════════════════╛
@export_group("Bullet Parameters")
@export_range(0.001, 16.0) var fire_rate: float = 0.05
@export_range(1.0, 1000.0) var bullet_speed: float = 50.0
@export_range(0.1, 100) var bullet_damage: float = 10.0
@export var bullet_scene: PackedScene

#✦ 🧭 SPREAD PARAMETERS 🧭                             ✦
#╘═════════════════════════════════════════════════════╛
@export_group("Spread Parameters")
@export_range(1, 7) var spread_count_bullet: int = 1
@export_range(0.1, 120.0) var spread_count_angle: float = 20.0
@export_range(0.1, 450) var spread_count_randomize_angle: float = 5.0

#✦ 🔧 RECOIL PARAMETERS 🔧                             ✦
#╘═════════════════════════════════════════════════════╛
@export_group("Recoil Parameters")
## Base force of recoil applied to the Weapon
@export_range(0.001, 382.0) var recoil_force: float = 1.5
@export_range(0.001, 32.0) var max_recoil: float = 12.0
@export_range(0.01, 4.0) var recoil_amplitude: float = 1.0
@export_range(0.01, 4.0) var recoil_frequency: float = 1.0
@export_range(0.001, 8.0) var recoil_increase_duration: float = 1.0
@export var recoil_curve_time: Curve = Curve.new()
@export var recoil_mouse_up_curve: Curve = Curve.new()
@export var recoil_noise_speed: float = 1.0
@export var recoil_noise_texture: Texture2D # This should now be a normal map texture
@export var recoil_linear_damp: float = 0.92
@export var recoil_angle_damp: float = 0.90


#✦ ⏱ RECOVERY PARAMETERS ⏱                             ✦
#╘═════════════════════════════════════════════════════╛
@export_group("Recovery Parameters")
@export_range(0.0001, 32.0) var recoil_mouse_up_recovery_time: float = 1.0

#✦ 🔧 NODE REFERENCES 🔧                               ✦
#╘═════════════════════════════════════════════════════╛
@export_group("Node References")
@onready var muzzle_node = get_node("Muzzle")
@onready var Weapon_node = self

# Add these new variables at the top of your script
var is_shooting: bool = false
var recoil_start_time: float = 0.0

# Variables
var current_recoil: float = 0.0
@onready var player = get_parent()
var time_since_last_shot: float = 0.0
var last_shot_time: float = 0.0
var current_recoil_offset: float = 0.0
var current_recoil_rotation_y: float = 0.0 # Only track Y-axis rotation for Weapon recoil
var noise_sample_x: float = 0.0 # Track the current X position for sampling the noise texture
var noise_sample_y: float = 0.0 # Track the current Y position for sampling the noise texture
var initial_Weapon_rotation: Vector3 # Store the initial rotation of the Weapon

# Debug cylinder export variables
@export_group("Debug Visualization")
@export var debug_cylinder_scene: PackedScene = preload("res://_meshes/debug/cyl_debug.tscn")
@export var debug_y_offset: float = 0.0
@export var debug_x_offset: float = 0.5
@export var debug_z_offset: float = 0.0
@export var debug_cylinder_spacing: float = 0.15

@export_subgroup("Debug Cylinder Colors")
@export var recoil_color_start: Color = Color.RED
@export var recoil_color_end: Color = Color.RED
@export var recovery_color_start: Color = Color.GREEN
@export var recovery_color_end: Color = Color.GREEN
@export var recoil_increase_color_start: Color = Color.ORANGE
@export var recoil_increase_color_end: Color = Color.ORANGE
@export var recoil_recovery_color_start: Color = Color.BLUE
@export var recoil_recovery_color_end: Color = Color.BLUE

# Debug cylinder variables
var recoil_cylinder: Node3D
var recovery_cylinder: Node3D
var recoil_increase_cylinder: Node3D
var recoil_recovery_cylinder: Node3D
var recoil_noise_cylinder: Node3D

# Add these new variables
var recoil_label: Sprite3D
var recovery_label: Sprite3D
var recoil_increase_label: Sprite3D
var recoil_recovery_label: Sprite3D

var recoil_noise_sprite: Sprite3D
var recoil_noise_label: Sprite3D
var recoil_accumulation: float = 0.0 # Add this variable to track recoil buildup

var is_recovering: bool = false
var recovery_start_time: float = 0.0

@export var camera_node: Camera3D # Assign this in the Inspector

var thumbstick: Node = null
var fire_threshold: float = 0.5 # Adjust this value as needed

var is_trigger_pressed: bool = false

var shoot_direction: Vector2 = Vector2.ZERO

# Add these if they're not already present
var recoil_recovery_time: float = 0.5 # Adjust this value as needed
var is_recovering_from_recoil: bool = false
var recoil_recovery_start_time: float = 0.0

@export_group("Debug Visualization")
@export var enable_debug_visualization: bool = true
@export var enable_recoil_debug: bool = true
@export var enable_recovery_debug: bool = true
@export var enable_recoil_increase_debug: bool = true
@export var enable_recoil_recovery_debug: bool = true
@export var enable_recoil_noise_debug: bool = true

var can_shoot: bool = true
var shoot_timer: float = 0.0

@onready var camera: Camera3D = get_tree().get_first_node_in_group("cameragame")

# Add these new variables at the top
@export_range(0.1, 10.0) var recoil_noise_intensity: float = 2.0  # Controls how "jumpy" the recoil is
@export_range(0.1, 10.0) var recoil_snap_speed: float = 3.0      # How quickly recoil snaps to new positions
@export_range(0.0, 1.0) var recoil_randomness: float = 0.4       # Additional random variation

func _ready():
	if camera_node:
		if not camera_node:
			push_error("No camera found. Please assign a camera to the camera_node variable.")
	
	if debug_cylinder_scene == null:
		push_error("Debug cylinder scene could not be loaded. Check the provided path.")
	# else:
		# print("Debug cylinder scene successfully loaded in _ready().")
	
	if bullet_scene == null:
		push_error("Bullet scene could not be loaded. Check the provided path.")
	if recoil_noise_texture == null:
		push_error("Recoil noise texture could not be loaded. Assign a NoiseTexture2D.")
	if recoil_mouse_up_curve == null:
		push_error("Recoil mouse up recovery curve could not be loaded. Assign a Curve.")
	if Weapon_node == null:
		push_error("Weapon node could not be loaded. Assign a valid Node3D for the Weapon.")
	else:
		# print("Bullet scene, noise texture, and recovery curve successfully loaded in _ready().")
		initial_Weapon_rotation = Weapon_node.rotation # Store the initial rotation
	
	# Create debug sprites
	create_debug_cylinders()

	thumbstick = get_node("../../../MainHUD/ControllerCanvas/MovementJoystick")
	if not thumbstick:
		push_error("Thumbstick not found. Make sure it's properly added to the scene.")

	# Ensure muzzle_node is a child of the Weapon and positioned correctly
	muzzle_node = $Muzzle # Adjust the path if necessary
	if not muzzle_node:
		push_error("Muzzle node not found!")
	# else:
		# print("Muzzle position: ", muzzle_node.global_transform.origin)

	# Add this to verify camera connection
	# if camera:
	# 	print("Camera connected successfully")
	# else:
	# 	push_error("Camera not found! Check the path!")

func create_debug_cylinders():
	if not enable_debug_visualization:
		return

	if enable_recoil_debug:
		recoil_cylinder = create_cylinder(recoil_color_start)
	if enable_recovery_debug:
		recovery_cylinder = create_cylinder(recovery_color_start)
	if enable_recoil_increase_debug:
		recoil_increase_cylinder = create_cylinder(recoil_increase_color_start)
	if enable_recoil_recovery_debug:
		recoil_recovery_cylinder = create_cylinder(recoil_recovery_color_start)
	if enable_recoil_noise_debug:
		recoil_noise_cylinder = create_cylinder(Color.WHITE)

	for cylinder in [recoil_cylinder, recovery_cylinder, recoil_increase_cylinder, recoil_recovery_cylinder, recoil_noise_cylinder]:
		if cylinder:
			add_child(cylinder)
		else:
			push_error("Failed to create cylinder instance.")

func create_cylinder(color: Color) -> Node3D:
	var cylinder = debug_cylinder_scene.instantiate()
	if cylinder:
		var mesh_instance = find_mesh_instance(cylinder)
		if mesh_instance:
			mesh_instance.set_instance_shader_parameter("emissive_color", color)
	return cylinder

func find_mesh_instance(node: Node) -> MeshInstance3D:
	if node is MeshInstance3D:
		return node
	for child in node.get_children():
		var result = find_mesh_instance(child)
		if result:
			return result
	return null

func update_debug_cylinders():
	if not enable_debug_visualization:
		return

	if not camera_node:
		push_error("Camera node is not set. Cannot update debug cylinders.")
		return

	var world_up = Vector3.UP
	var camera_forward = -camera_node.global_transform.basis.z
	var camera_right = camera_forward.cross(world_up).normalized()
	
	var base_position = global_transform.origin + world_up * debug_y_offset + camera_node.global_transform.basis.z * debug_z_offset

	# Position and update cylinders
	var cylinder_index = 0
	for cylinder_data in [
		[enable_recoil_debug, recoil_cylinder, recoil_color_start, recoil_color_end],
		[enable_recovery_debug, recovery_cylinder, recovery_color_start, recovery_color_end],
		[enable_recoil_increase_debug, recoil_increase_cylinder, recoil_increase_color_start, recoil_increase_color_end],
		[enable_recoil_recovery_debug, recoil_recovery_cylinder, recoil_recovery_color_start, recoil_recovery_color_end],
		[enable_recoil_noise_debug, recoil_noise_cylinder, Color.BLACK, Color.WHITE]
	]:
		var enabled = cylinder_data[0]
		var cylinder = cylinder_data[1]
		var start_color = cylinder_data[2]
		var end_color = cylinder_data[3]

		if enabled and cylinder:
			cylinder.global_transform.origin = base_position + camera_right * (debug_x_offset + debug_cylinder_spacing * cylinder_index)
			update_specific_cylinder(cylinder, start_color, end_color)
			cylinder_index += 1

	# Ensure cylinders are aligned with world up and facing the camera
	for cylinder in [recoil_cylinder, recovery_cylinder, recoil_increase_cylinder, recoil_recovery_cylinder, recoil_noise_cylinder]:
		if cylinder:
			var look_at_pos = cylinder.global_transform.origin + camera_forward
			cylinder.look_at(look_at_pos, world_up)

func update_specific_cylinder(cylinder: Node3D, start_color: Color, end_color: Color):
	var progress = 0.0
	var scale_y = 0.1

	if cylinder == recoil_cylinder:
		progress = current_recoil_offset / max_recoil
		scale_y = progress
	elif cylinder == recovery_cylinder:
		progress = 1.0 - (current_recoil_offset / max_recoil)
		scale_y = progress
	elif cylinder == recoil_increase_cylinder:
		var recoil_duration = Time.get_ticks_msec() / 1000.0 - recoil_start_time
		progress = min(recoil_duration / recoil_increase_duration, 1.0)
		scale_y = recoil_curve_time.sample_baked(progress) if is_shooting else 0.1
	elif cylinder == recoil_recovery_cylinder:
		if is_recovering:
			var recovery_duration = Time.get_ticks_msec() / 1000.0 - recovery_start_time
			progress = min(recovery_duration / recoil_mouse_up_recovery_time, 1.0)
			scale_y = recoil_mouse_up_curve.sample_baked(progress)
		else:
			scale_y = 0.1
	elif cylinder == recoil_noise_cylinder:
		var noise_value = recoil_noise_texture.get_image().get_pixelv(Vector2(int(noise_sample_x) % recoil_noise_texture.get_width(), 0)).r
		progress = noise_value
		scale_y = max(noise_value, 0.01)

	update_cylinder_scale(cylinder, scale_y)
	update_cylinder_color(cylinder, start_color, end_color, progress)

func update_cylinder_scale(cylinder: Node3D, scale_y: float):
	var scale_mesh = cylinder.get_node("ScaleMesh")
	var mesh_instance = scale_mesh.get_node("MeshInstance3D") if scale_mesh else null
	
	if mesh_instance and mesh_instance is MeshInstance3D:
		var new_scale = Vector3(1, max(scale_y, 0.01), 1)
		var original_height = 4.0 # Assuming the original height is 1.0, adjust if different
		var height_difference = original_height * (new_scale.y - 1)
		
		# Scale the mesh
		mesh_instance.scale = new_scale
		
		# Move the mesh up to keep the bottom at the same position
		mesh_instance.position.y = height_difference / 2

func update_cylinder_color(cylinder: Node3D, start_color: Color, end_color: Color, progress: float):
	var mesh_instance = find_mesh_instance(cylinder)
	if mesh_instance:
		var color = start_color.lerp(end_color, progress)
		mesh_instance.set_instance_shader_parameter("emissive_color", color)
	else:
		push_error("Could not find MeshInstance3D in update_cylinder_color().")

func _process(delta: float):
	var current_time = Time.get_ticks_msec() / 1000.0
	time_since_last_shot = current_time - last_shot_time

	# Handle fire rate
	if not can_shoot:
		shoot_timer += delta
		if shoot_timer >= fire_rate:
			can_shoot = true
			shoot_timer = 0.0

	if is_shooting:
		if can_shoot:
			shoot_bullet()
			can_shoot = false
			shoot_timer = 0.0
			last_shot_time = current_time
		update_recoil(delta, current_time)
	else:
		handle_recoil_recovery(delta)
	
	update_debug_cylinders()
	apply_recoil_to_player(delta)

func _physics_process(_delta: float):
	apply_recoil_damping(recoil_linear_damp, recoil_angle_damp)

func update_recoil(delta: float, current_time: float):
	var recoil_duration = current_time - recoil_start_time
	var recoil_progress = min(recoil_duration / recoil_increase_duration, 1.0)
	var curve_value = recoil_curve_time.sample_baked(recoil_progress)
	
	# Add sudden jumps to the recoil
	var noise_jump = randf() * recoil_noise_intensity
	var random_spike = 1.0 + (randf() * recoil_randomness if randf() < 0.3 else 0.0)
	
	# Calculate recoil increment with added noise
	var recoil_increment = recoil_force * curve_value * delta * random_spike
	recoil_increment *= (1.0 + noise_jump)
	
	# Snap to new recoil values more quickly
	recoil_accumulation = lerp(recoil_accumulation, 
		recoil_accumulation + recoil_increment, 
		delta * recoil_snap_speed)
	recoil_accumulation = min(recoil_accumulation, max_recoil)
	
	# Get the back direction for recoil
	var back_direction = -player.global_transform.basis.z
	back_direction.y = 0
	back_direction = back_direction.normalized()
	
	# Apply noise to the direction
	var noise_offset = Vector3(
		randf_range(-1, 1) * recoil_randomness,
		0,
		randf_range(-1, 1) * recoil_randomness
	)
	back_direction += noise_offset
	back_direction = back_direction.normalized()
	
	var local_back_direction = back_direction * recoil_accumulation
	current_recoil_offset = local_back_direction.length()
	current_recoil_offset = clamp(current_recoil_offset, 0, max_recoil)

	# Apply more erratic weapon rotation
	if Weapon_node and recoil_noise_texture:
		noise_sample_x += recoil_noise_speed * recoil_frequency * delta * (1.0 + noise_jump)
		var noise_value = recoil_noise_texture.get_image().get_pixelv(
			Vector2(int(noise_sample_x) % recoil_noise_texture.get_width(), 0)
		).r * 2.0 - 1.0
		
		# Add sudden rotational kicks
		var kick_multiplier = 1.0 + (randf() * 2.0 if randf() < 0.2 else 0.0)
		var recoil_angle = noise_value * recoil_amplitude * max(curve_value, 0.1) * kick_multiplier
		
		# Apply rotation with quick snapping
		var target_rotation = deg_to_rad(recoil_angle)
		Weapon_node.rotation.y = lerp_angle(
			Weapon_node.rotation.y,
			initial_Weapon_rotation.y + target_rotation,
			delta * recoil_snap_speed
		)
		
		# Clamp rotation with some random variation
		var max_rotation = deg_to_rad(max_recoil * curve_value * (1.0 + randf() * recoil_randomness))
		Weapon_node.rotation.y = clamp(
			Weapon_node.rotation.y,
			initial_Weapon_rotation.y - max_rotation,
			initial_Weapon_rotation.y + max_rotation
		)
		
		# Lock X and Z rotations
		Weapon_node.rotation.x = initial_Weapon_rotation.x
		Weapon_node.rotation.z = initial_Weapon_rotation.z

func apply_recoil_damping(linear_damp: float, angle_damp: float):
	var linear_damping = linear_damp
	var angle_damping = angle_damp
	recoil_linear_damp *= linear_damping
	recoil_angle_damp *= angle_damping

func apply_recoil_to_player(delta: float):
	if player:
		# Get horizontal direction only
		var recoil_direction = -player.global_transform.basis.z
		recoil_direction.y = 0  # Force Y to zero
		recoil_direction = recoil_direction.normalized()  # Renormalize
		
		# Apply horizontal recoil only
		var recoil_offset = recoil_direction * current_recoil_offset * delta
		player.global_translate(recoil_offset)

func handle_recoil_recovery(delta: float):
	if is_recovering:
		var current_time = Time.get_ticks_msec() / 1000.0
		var recovery_progress = (current_time - recovery_start_time) / recoil_mouse_up_recovery_time
		
		if recovery_progress >= 1.0:
			is_recovering = false
			recoil_accumulation = 0.0
			current_recoil_offset = 0.0
			if Weapon_node:
				Weapon_node.rotation = initial_Weapon_rotation
			reset_noise_sampling()
		else:
			var recovery_curve_value = recoil_mouse_up_curve.sample_baked(recovery_progress)
			recoil_accumulation = lerp(recoil_accumulation, 0.0, recovery_curve_value * delta)
			current_recoil_offset = lerp(current_recoil_offset, 0.0, recovery_curve_value * delta)
			
			if Weapon_node:
				Weapon_node.rotation = Weapon_node.rotation.lerp(initial_Weapon_rotation, recovery_curve_value * delta)

func shoot_bullet():
	var muzzle_transform = muzzle_node.global_transform
	var shoot_direction = muzzle_transform.basis.z.normalized()
	shoot_direction.y = 0  # Force initial direction to be horizontal
	shoot_direction = shoot_direction.normalized()

	var rng = RandomNumberGenerator.new()
	rng.randomize()

	# Calculate the base spread angle between bullets
	var base_spread_angle = spread_count_angle / max(1, spread_count_bullet - 1)

	for i in range(spread_count_bullet):
		var bullet_seed = rng.randi()
		var bullet_rng = RandomNumberGenerator.new()
		bullet_rng.seed = bullet_seed

		# Calculate horizontal spread only
		var spread_angle = (i - (spread_count_bullet - 1) / 2.0) * base_spread_angle
		var random_angle_variation = bullet_rng.randf_range(-spread_count_randomize_angle, spread_count_randomize_angle)
		var final_spread_angle = spread_angle + random_angle_variation
		
		# Only rotate around Y axis for spread
		var spread_direction = shoot_direction.rotated(Vector3.UP, deg_to_rad(final_spread_angle))
		
		# Ensure spread_direction is horizontal
		spread_direction.y = 0
		spread_direction = spread_direction.normalized()

		# Create and setup bullet
		var bullet = bullet_scene.instantiate()
		if bullet:
			get_tree().root.add_child(bullet)
			bullet.global_transform.origin = muzzle_node.global_transform.origin
			
			# Set bullet rotation (Y-axis only)
			bullet.global_transform = bullet.global_transform.looking_at(
				bullet.global_transform.origin + spread_direction,
				Vector3.UP
			)

			# Set velocity (horizontal only)
			if bullet.has_method("set_velocity"):
				var velocity = spread_direction * bullet_speed
				bullet.set_velocity(velocity)

			if bullet.has_method("set_bullet_owner"):
				bullet.set_bullet_owner(player)
			if bullet.has_method("set_damage"):
				bullet.set_damage(bullet_damage)

	# Calculate and apply recoil (horizontal only)
	var recoil_direction = muzzle_transform.basis.z.normalized()
	recoil_direction.y = 0  # Force Y to zero
	recoil_direction = recoil_direction.normalized()  # Renormalize
	
	var recoil_force = -recoil_direction * get_recoil_value()
	apply_recoil(recoil_direction)
	emit_signal("Weapon_fired", recoil_force)

	# Update noise sample position
	noise_sample_x = fmod(noise_sample_x + recoil_frequency, float(recoil_noise_texture.get_width()))

func apply_recoil(direction: Vector3):
	is_recovering = false
	
	var recoil_value = get_recoil_value()
	
	# Calculate recoil offset with linear damping (only in XZ plane)
	var recoil_direction = direction
	recoil_direction.y = 0  # Remove vertical component
	recoil_direction = recoil_direction.normalized()  # Renormalize
	
	var local_back_direction = player.to_local(recoil_direction) * -recoil_value
	current_recoil_offset = local_back_direction.length()
	current_recoil_offset = clamp(current_recoil_offset, 0, max_recoil)
	current_recoil_offset *= recoil_linear_damp

	# Apply recoil to the Weapon's rotation (Y-axis only)
	if Weapon_node and recoil_noise_texture:
		noise_sample_x += recoil_noise_speed * recoil_frequency * (recoil_value / max_recoil)
		
		var texture_size = recoil_noise_texture.get_width()
		var sample_pos = Vector2(
			fmod(noise_sample_x, float(texture_size)) / float(texture_size),
			0  # Only sample X for Y rotation
		)
		var normal = recoil_noise_texture.get_image().get_pixelv(sample_pos * texture_size)
		
		# Only calculate Y rotation
		var recoil_y = (normal.r * 2.0 - 1.0) * recoil_amplitude * (recoil_value / max_recoil)
		recoil_y *= recoil_angle_damp
		
		# Apply only Y rotation
		Weapon_node.rotate_y(deg_to_rad(recoil_y))
		
		# Clamp Y rotation
		var max_rotation = deg_to_rad(recoil_value * recoil_angle_damp)
		Weapon_node.rotation.y = clamp(Weapon_node.rotation.y, 
			initial_Weapon_rotation.y - max_rotation, 
			initial_Weapon_rotation.y + max_rotation)
			
		# Lock X and Z rotations
		Weapon_node.rotation.x = initial_Weapon_rotation.x
		Weapon_node.rotation.z = initial_Weapon_rotation.z

	# Add camera shake
	if camera:
		var shake_amount = (recoil_value / max_recoil) * 0.2
		camera.add_shake(shake_amount)

func apply_recoil_force(delta: float):
	# Apply translation recoil to player
	if player:
		player.translate(Vector3(0, 0, -current_recoil_offset * delta))

	# Apply Y-axis recoil to Weapon_node rotation
	# if Weapon_node:
		# Weapon_node.rotate_y(current_recoil_rotation_y * delta)

func reset_recoil():
	if not is_recovering:
		is_recovering = true
		recovery_start_time = Time.get_ticks_msec() / 1000.0
	emit_signal("recoil_reset")

func get_recoil_value() -> float:
	var curve_time = min(time_since_last_shot / recoil_increase_duration, 1.0)
	var curve_value = recoil_curve_time.sample_baked(curve_time)
	return curve_value * max_recoil

func reset_noise_sampling():
	noise_sample_x = 0.0
	noise_sample_y = 0.0

func trigger_pressed(direction: Vector2):
	is_trigger_pressed = true
	shoot_direction = direction
	is_shooting = true

func trigger_released():
	is_trigger_pressed = false
	shoot_direction = Vector2.ZERO
	is_shooting = false
	reset_recoil()
	
	# Reset camera shake when trigger released
	if camera:
		camera.reset_shake()