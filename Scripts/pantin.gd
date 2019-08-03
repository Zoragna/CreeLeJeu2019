extends KinematicBody

class_name Pantin

onready var head = get_node("head")
onready var fly_camera = head.get_node("Camera")

onready var debug_label = get_node("Control/Label")
onready var animator = get_node("AnimationPlayer")
onready var particles = get_node("Particles")

signal launching_game
signal abandonning_game

var camera
var min_head_dist = 7
var max_head_dist = 19

var STATE = "RUN"

var speed = 10
var jump_speed = 750
var acceleration = 5
var direction
var aim
var paused = false
var velocity = Vector3()

var mass = 5
var g = -9.81
var weight = g*mass

func ride():
	print("RIDE !")
	STATE = "RIDING"
	animator.play("riding")

func unride():
	print("UNRIDE!")
	STATE = "RUN"
	animator.play("idle")

func _ready():
	camera = fly_camera
	animator.play("idle")

func set_camera(value):
	camera.current = false
	camera = value
	camera.current = true

func _process(delta):
	pass

func pause():
	paused = true
	animator.stop()

func resume():
	paused = false
	animator.play()

func _physics_process(delta):
	if !paused :
		if STATE == "MISSION" :
			if !particles.is_emitting():
				particles.set_emitting(true)
		else :
			if particles.is_emitting():
				particles.set_emitting(false)
		run(delta)

func run(delta):
	direction = Vector3()
	var target = Vector3()
	var velxy = Vector2(velocity.x, velocity.z)
	if STATE != "MISSION" :
		if STATE == "RIDING" :
			animate("riding")
		elif velxy.length() < 3 :
			animate("idle")
		elif STATE == "RUN" :
			animate("walk")
		if Input.is_action_pressed("ui_left") :
			direction += Vector3(1,0,0)
			get_node("idle").flip_h = false
			get_node("run").flip_h = false
			get_node("riding").flip_h = false
		if Input.is_action_pressed("ui_right") :
			direction -= Vector3(1,0,0)
			get_node("idle").flip_h = true
			get_node("run").flip_h = true
			get_node("riding").flip_h = true
		if Input.is_action_pressed("ui_up") :
			direction += Vector3(0,0,1)
		if Input.is_action_pressed("ui_down") :
			direction -= Vector3(0,0,1)
	direction = direction.normalized()
	target.x = direction.x*speed
	target.z = direction.z*speed
	#target.y += velocity.y
	target += weight*Vector3(0,1,0)

	velocity = velocity.linear_interpolate(target, acceleration*delta)
	
	velocity = move_and_slide(velocity,Vector3(0,1,0))

func mouse(event):
	#var bas = transform.basis
	#if  STATE == "RUN" :
	#		bas = bas.rotated(bas.y, event.relative.x/ -200)
	#transform.basis = bas.orthonormalized()
	pass

func key(event):
	if event.pressed : 
		if event.scancode == KEY_R :
			if STATE == "RUN" :
				animator.play("using")
				STATE = "MISSION"
				emit_signal("launching_game")
			elif STATE == "MISSION" :
				print("DEMISSION")
				STATE = "RUN"
				emit_signal("abandonning_game")
			elif STATE == "RIDING" :
				emit_signal("abandonning_game")

func _input(event):
	if !paused :
		if event is InputEventMouseMotion:
			mouse(event)
		elif event is InputEventKey :
			key(event) 

func animate(value):
	if animator.current_animation != value:
		animator.play(value)

func _on_AnimationPlayer_animation_changed(old_name, new_name):
	print(old_name+"->"+new_name)


func _on_AnimationPlayer_animation_started(anim_name):
	print(anim_name)
