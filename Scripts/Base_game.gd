extends Spatial

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var paused

# Called when the node enters the scene tree for the first time.
func _ready():
	paused = false

func _process(delta):
	pass

func pause():
	paused = true

func resume():
	paused = false

func start():
	pass

func abandon():
	pass
