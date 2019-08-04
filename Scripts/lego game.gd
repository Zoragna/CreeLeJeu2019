extends Spatial

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var Block = preload("res://Scenes/block.tscn")

signal game_won
signal game_lost

onready var path = get_node("Path")
onready var generator = path.curve
onready var timer = get_node("Timer")
onready var camera = path.get_node("Camera")
onready var selection_block = get_node("block")
onready var gui = get_node("Control")
onready var progressBar = gui.get_node("ProgressBar")
onready var clock = gui.get_node("time_left")

var paused
var blocks = []
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

func change_random_selection():
	randomize()
	idx_selection = randi()%len(selection_block.blocks)
	change_selection(idx_selection)

func _process(delta):
	if !paused :
		progressBar.value = progressBar.get_max() - timer.time_left
		clock.set_value(clock.get_value()+delta)
		if Input.is_action_just_pressed("ui_right") :
			idx_positions += 1 
		if Input.is_action_just_pressed("ui_left"):
			idx_positions -= 1 
		idx_positions %= len(positions)
		move_selection()
		if Input.is_action_just_pressed("ui_up"):
			selection_block.transform.basis = selection_block.transform.basis.rotated(Vector3(0,0,1),PI/2)
		if Input.is_action_just_pressed("ui_down"):
			selection_block.transform.basis = selection_block.transform.basis.rotated(Vector3(0,0,1),-PI/2)
		if Input.is_action_just_pressed("jump"):
			spawn_selected_block()
			print(timer.time_left)
			timer.start()
			print(timer.time_left)
			change_random_selection()
		if clock.get_value() >= clock.get_max():
			abandon()

func pause():
	paused = true
	timer.set_paused(paused)
	for block in blocks :
		block.pause()
	gui.hide()

func resume():
	paused = false
	timer.set_paused(paused)
	for block in blocks :
		block.resume()
	if !timer.is_stopped():
		gui.show()

func _physics_process(delta):
	if !paused :
		path.transform.origin.y += delta*0.5

func start():
	print("started lego game !")
	timer.start()
	paused = false
	timer.set_wait_time(progressBar.get_max())
	resume()
	gui.show()
	path.transform.origin.y = 8.4
	blocks = []
	clock.value = 0
	clock.show()

func abandon(player_won = false):
	paused = true
	gui.hide()
	get_node("AudioStreamPlayer3D").play()
	for block in blocks :
		var self_origin = self.transform.origin
		var current_animation = block.animator.get_current_animation()
		var impulse = 10*(block.transform.origin - self_origin)
		block.delock()
		block.get_node(current_animation).apply_impulse(self_origin, impulse)

func spawn_selected_block():
	spawn_block(selection_block.transform.origin + 0*path.transform.origin, true)

func spawn_block(position, selected = false):
	print("spawn block !")
	var block = Block.instance()
	block.transform.origin = position
	if selected :
		block.transform.basis = selection_block.transform.basis
	add_child(block)
	blocks.append(block)
	if selected :
		block.set_block(selection_block.blocks[idx_selection])
	else :
		block.set_random_block()

func _on_Timer_timeout():
	if !paused :
		print("timer timeout")
		spawn_selected_block()
		change_random_selection()

func _on_Area_body_exited(body):
	if !paused :
		print("LOSE")
		emit_signal("game_lost")

func _on_Area2_body_entered(body):
	if !paused :
		# Wait 5 seconds, then resume execution.
		yield(get_tree().create_timer(3.0), "timeout")
		if body in get_node("Area2").get_overlapping_bodies():
			print("WIN")
			emit_signal("game_won")
