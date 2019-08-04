extends Spatial

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
class_name Block

onready var animator = get_node("AnimationPlayer")
var blocks = ["cube", "L", "bar", "S", "T"]

var paused = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func pause():
	paused = true
	animator.stop()
	change_sleep(paused)

func resume():
	paused = false
	animator.play()
	change_sleep(paused)

func change_sleep(value):
	for block in blocks :
		get_node(block).sleeping=value

func delock():
	for block in blocks:
		get_node(block).axis_lock_linear_z = false

func random_block():
	randomize()
	return blocks[randi()%len(blocks)]

func set_block(value):
	animator.play(value)

func set_random_block():
	var rand = random_block()
	print(rand)
	animator.play(rand)

func _physics_process(delta):
	pass