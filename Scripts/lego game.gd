extends Spatial

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var Block = preload("res://Scenes/block.tscn")

onready var path = get_node("Path")
onready var generator = path.curve
onready var timer = get_node("Timer")
onready var camera = get_node("Camera")

var paused

# Called when the node enters the scene tree for the first time.
func _ready():
	paused = false

func _process(delta):
	pass

func pause():
	paused = true
	timer.set_paused(paused)
	for child in path.get_children():
		child.sleeping = true

func resume():
	paused = false
	timer.set_paused(paused)
	for child in path.get_children():
		child.sleeping = false

func start():
	print("started lego game !")
	timer.start()

func abandon():
	timer.stop()

func spawn_block(position):
	print("spawn block !")
	var block = Block.instance()
	block.transform.origin = position
	path.add_child(block)

func _on_Timer_timeout():
	randomize()
	spawn_block(generator.interpolate(0,randf()))
