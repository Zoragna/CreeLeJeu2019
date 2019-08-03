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
onready var gui = get_node("Control")

var paused
var blocks
var length
var positions

var idx_positions = 0
var idx_selection = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	gui.hide()
	paused = true
	length = generator.get_baked_length()
	positions = range(0,length,length/5)
	change_selection(idx_selection)
	move_selection()
	gui.hide()

func move_selection():
	var t = positions[idx_positions]/length
	selection_block.transform.origin = generator.interpolate(0,t) + path.transform.origin

func change_selection(id):
	var value = selection_block.blocks[id]
	selection_block.animator.play("selection_"+value)

func _process(delta):
	if !paused :
		if Input.is_action_just_pressed("ui_right") :
			idx_positions += 1 
		if Input.is_action_just_pressed("ui_left"):
			idx_positions -= 1 
		idx_positions %= len(positions)
		move_selection()
		if Input.is_action_just_pressed("ui_up"):
			idx_selection += 1
		if Input.is_action_just_pressed("ui_down"):
			idx_selection -= 1
		idx_selection %= len(selection_block.blocks)
		change_selection(idx_selection)
		if Input.is_action_just_pressed("jump"):
			spawn_block(selection_block.transform.origin - path.transform.origin, true)

func pause():
	paused = true
	timer.set_paused(paused)
	for child in path.get_children():
		child.pause()
	gui.hide()

func resume():
	paused = false
	timer.set_paused(paused)
	for child in path.get_children():
		child.resume()
	if !timer.is_stopped():
		gui.show()

func start():
	print("started lego game !")
	timer.start()
	resume()
	gui.show()

func abandon():
	timer.stop()
	paused = true
	gui.hide()

func spawn_block(position, selected = false):
	print("spawn block !")
	var block = Block.instance()
	block.transform.origin = position
	path.add_child(block)
	if selected :
		block.set_block(selection_block.blocks[idx_selection])
	else :
		block.set_random_block()

func _on_Timer_timeout():
	pass#gui.hide()
