extends Spatial

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var Block = preload("res://Scenes/block.tscn")

onready var path = get_node("Path")
onready var generator = path.curve
onready var timer = get_node("Timer")
onready var camera = get_node("Camera")
onready var selection_block = get_node("block")

var paused
var blocks
var length
var positions

var idx_positions = 0
var current_selection = "cube"

# Called when the node enters the scene tree for the first time.
func _ready():
	paused = true
	length = generator.get_baked_length()
	positions = range(0,length,length/5)
	change_selection(current_selection)
	move_selection()

func move_selection():
	var t = positions[idx_positions]/length
	selection_block.transform.origin = generator.interpolate(0,t) + path.transform.origin

func change_selection(value):
	current_selection = value
	selection_block.animator.play("selection_"+current_selection)

func _process(delta):
	if !paused :
		if Input.is_action_just_pressed("ui_right") :
			idx_positions += 1 
			idx_positions %= len(positions)
		if Input.is_action_just_pressed("ui_left"):
			idx_positions -= 1 
			idx_positions %= len(positions)
		move_selection()
		if Input.is_action_just_pressed("ui_up"):
			if current_selection == "cube" :
				current_selection = "L"
			elif current_selection == "L":
				current_selection = "bar"
			elif current_selection == "bar":
				current_selection = "cube"
		if Input.is_action_just_pressed("ui_down"):
			if current_selection == "cube" :
				current_selection = "bar"
			elif current_selection == "bar":
				current_selection = "L"
			elif current_selection == "L":
				current_selection = "cube"
		change_selection(current_selection)
		if Input.is_action_just_pressed("jump"):
			spawn_block(selection_block.transform.origin - path.transform.origin, true)

func pause():
	paused = true
	timer.set_paused(paused)
	for child in path.get_children():
		child.pause()

func resume():
	paused = false
	timer.set_paused(paused)
	for child in path.get_children():
		child.resume()

func start():
	print("started lego game !")
	timer.start()
	resume()

func abandon():
	timer.stop()
	paused = true

func spawn_block(position, selected = false):
	print("spawn block !")
	var block = Block.instance()
	block.transform.origin = position
	path.add_child(block)
	if selected :
		block.set_block(current_selection)
	else :
		block.set_random_block()

func _on_Timer_timeout():
	randomize()
	var t = positions[randi()%len(positions)]/length
	#spawn_block(generator.interpolate(0,t))
