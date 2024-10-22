extends MeshInstance3D

@export var trail_length: float = 1.0  # Size of the trail
@export var trail_sections: int = 5  # Number of sections in the trail
@export var trail_width: float = 0.1  # Width of the trail
@export var trail_color: Color = Color(1, 1, 1, 0.5)  # Color of the trail

var ribbon_trail: RibbonTrailMesh
var trail_points: Array = []

func _ready():
    setup_trail()