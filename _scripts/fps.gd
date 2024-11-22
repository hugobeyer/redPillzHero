extends Label

func _process(_delta):
    text = "FPS: %d\nPhysics: %d" % [
        Engine.get_frames_per_second(),
        Engine.get_physics_ticks_per_second()
    ]