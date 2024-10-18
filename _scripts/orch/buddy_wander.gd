func noise_sampling(delta: float, direction: Vector3) -> Vector2:
    var noise_sample_x = fmod(noise_sample_x + direction.x * row_speed * delta, noise_texture.get_width())
    var new_current_row = fmod(current_row + direction.y * row_speed * delta, noise_texture.get_height())
    current_row = new_current_row
    return Vector2(noise_sample_x, new_current_row)