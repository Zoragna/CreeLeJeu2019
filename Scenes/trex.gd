extends Spatial

onready var animator = get_node("AnimationPlayer")

# Called when the node enters the scene tree for the first time.
func _ready():
	animator.play("idle")

func pause():
	animator.stop()

func resume():
	animator.play()