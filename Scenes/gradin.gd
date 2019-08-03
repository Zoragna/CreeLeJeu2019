extends Spatial

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var animator = get_node("AnimationPlayer")

# Called when the node enters the scene tree for the first time.
func _ready():
	animator.play("cheering")

func pause():
	animator.stop()

func resume():
	animator.play("cheering")