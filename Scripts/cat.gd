extends Spatial

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var animator = get_node("AnimationPlayer")

# Called when the node enters the scene tree for the first time.
func _ready():
	animator.play("idle")

func pause():
	animator.stop()

func resume():
	animator.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
