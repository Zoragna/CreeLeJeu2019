extends KinematicBody

var mouse_sensitivity = 0.3
var head_angle_y = 0

onready var animator = get_node("AnimationPlayer")

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

var mass = 50
var g = 0
var weight = g*mass

var fly_camera = null
var head = null

func _ready():
	paused = true
	animator.play("idle")

func set_camera(value):
	camera.current = false
	camera = value
	camera.current = true

func _process(delta):
	pass

func pause():
	paused = true

func resume():
	paused = false

func _physics_process(delta):
	if !paused :
		if STATE == "RUN" :
			run(delta)

func run(delta):
	direction = Vector3()
	var target = Vector3()
	var velxy = Vector2(velocity.x, velocity.z)
	if velxy.length() < 1:
		animator.play("idle")
	else :
		animator.play("walk")
	
	aim = fly_camera.get_global_transform().basis
	if Input.is_action_pressed("ui_left") :
		direction -= aim.x
		get_node("idle").flip_h = false
		get_node("run").flip_h = false
	if Input.is_action_pressed("ui_right") :
		get_node("idle").flip_h = true
		get_node("run").flip_h = true
		direction += aim.x
	if Input.is_action_pressed("ui_up") :
		direction -= aim.z
	if Input.is_action_pressed("ui_down") :
		direction += aim.z
	if is_on_floor() :
		if Input.is_action_pressed("jump") :
			target += jump_speed*Vector3(0,1,0)
	direction = direction.normalized()
	target.x = direction.x*speed
	target.z = direction.z*speed
	target.y += velocity.y
	target += weight*Vector3(0,1,0)

	velocity = velocity.linear_interpolate(target, acceleration*delta)
	
	velocity = move_and_slide(velocity,Vector3(0,1,0))

func mouse(event):
	var bas = transform.basis
	if  STATE == "RUN" :
		bas = bas.rotated(bas.y, event.relative.x/ -200)
	transform.basis = bas.orthonormalized()

func key(event):
	if event.pressed : 
		if event.scancode == KEY_R :
			if STATE == "RUN" :
				print("MISSION")
				emit_signal("launching_game")
				STATE = "MISSION"
			elif STATE == "MISSION" :
				print("DEMISSION")
				emit_signal("abandonning_game")
				STATE = "RUN"

func _inactive_input(event):
	if !paused :
		if event is InputEventMouseMotion:
			mouse(event)
		elif event is InputEventKey :
			key(event) 
		elif event is InputEventMouseButton :
			var direction_to_player = head.to_local(transform.origin)
			direction_to_player = direction_to_player.normalized()
			direction_to_player *= event.factor / 2
			var offset = Vector3()
			if event.button_index == BUTTON_WHEEL_DOWN :
				offset = -direction_to_player
			elif event.button_index == BUTTON_WHEEL_UP :
				offset = direction_to_player
			var newtrans = head.transform.translated(offset)
			var new_trans_len = clamp( newtrans.origin.length(), min_head_dist, max_head_dist )
			var t = (max_head_dist - new_trans_len)/(max_head_dist - min_head_dist)
			head.transform = head.transform.interpolate_with ( newtrans, -3*t*(t-1) )