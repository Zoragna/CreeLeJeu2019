extends KinematicBody

class_name Pantin

onready var head = get_node("head")
onready var fly_camera = head.get_node("Camera")

onready var debug_label = get_node("Control/Label")
onready var win_ui = get_node("Control/Win")
onready var lose_ui = get_node("Control/Lose")
onready var animator = get_node("AnimationPlayer")
onready var particles = get_node("Particles")

signal launching_game
signal abandonning_game
signal dino_stomp

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

func win():
	STATE = "RUN"
	win_ui.show()
	get_node("Control/Timer").start()

func lose():
	STATE = "RUN"
	lose_ui.show()
	get_node("Control/Timer").start()

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
		if is_on_floor() :
			if animator.get_current_animation() == "riding_jump":
				get_node("AudioStreamPlayer3").play()
				emit_signal("dino_stomp")
			if velxy.length() < 1 && STATE == "RIDING" :
				animate("riding_idle")
				get_node("Timer").stop()
			elif velxy.length() < 3 && STATE == "RUN" :
					animate("idle")
			elif STATE == "RUN" :
				animate("walk")
			elif STATE == "RIDING":
				animate("riding")
				if get_node("Timer").is_stopped() :
					get_node("Timer").start()
		if Input.is_action_pressed("ui_left") :
			direction += Vector3(1,0,0)
			get_node("idle").flip_h = false
			get_node("run").flip_h = false
			get_node("riding").flip_h = false
			get_node("riding_idle").flip_h = false
			get_node("riding_jump").flip_h = false
		if Input.is_action_pressed("ui_right") :
			direction -= Vector3(1,0,0)
			get_node("idle").flip_h = true
			get_node("run").flip_h = true
			get_node("riding").flip_h = true
			get_node("riding_idle").flip_h = true
			get_node("riding_jump").flip_h = true
		if Input.is_action_pressed("ui_up") :
			direction += Vector3(0,0,1)
		if Input.is_action_pressed("ui_down") :
			direction -= Vector3(0,0,1)
		if Input.is_action_just_pressed("jump") && is_on_floor() && STATE == "RIDING" :
			animate("riding_jump")
			target.y += jump_speed
	direction = direction.normalized()
	target.x = direction.x*speed
	target.z = direction.z*speed
	#target.y += velocity.y
	target += weight*Vector3(0,1,0)
	if STATE == "RIDING" :
		target *= 0.3

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
				_on_Timer_timeout()
				animator.play("using")
				STATE = "MISSION"
				emit_signal("launching_game")
			elif STATE == "MISSION" :
				print("DEMISSION")
				STATE = "RUN"
				emit_signal("abandonning_game")
			elif STATE == "RIDING" :
				emit_signal("abandonning_game")
				get_node("Timer").stop()

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


func _on_Timer_timeout():
	win_ui.hide()
	lose_ui.hide()


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "riding_jump":
		print("!")


func _on_step_timeout():
	randomize()
	if randf() < 0.5 :
		get_node("AudioStreamPlayer").play()
	else :
		get_node("AudioStreamPlayer2").play()
