extends Spatial

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var timer = get_node("Timer")
onready var car_UI = get_node("Control")
onready var colorRect = car_UI.get_node("ColorRect")
onready var flying_camera = get_node("Camera")

onready var start_line = get_node("MeshInstance")
onready var path = start_line.get_node("Path")
onready var generator = path.curve

var Car = preload("res://Scenes/car.tscn")
var paused
var player_car
var cars = []
var camera

var STATE = 3

# Called when the node enters the scene tree for the first time.
func _ready():
	paused = false
	car_UI.hide()
	camera = flying_camera

func _process(delta):
	pass

func change_camera(value):
	camera = value

func pause():
	paused = true
	timer.set_paused(paused)
	car_UI.hide()
	for car in cars :
		car.pause()

func resume():
	paused = false
	timer.set_paused(paused)
	car_UI.show()
	for car in cars :
		car.resume()

func start():
	print("started car game !")
	timer.start()
	car_UI.show()
	STATE = 3
	colorRect.color = Color.black
	
	randomize()
	player_car = spawn_car(generator.interpolate(0,randf())+Vector3(0,10,0))
	player_car.show_gui()
	change_camera(player_car.camera)
	cars.append(player_car)

func _physics_process(delta):
	if STATE <= 0:
		var engine_force = 0
		var brake = 0
		var steering = 0
		if Input.is_action_pressed("ui_up"):
			engine_force += 25
		if Input.is_action_pressed("ui_down"):
			engine_force -= 25
		if Input.is_action_pressed("jump"):
			brake += 4
		if Input.is_action_pressed("ui_left"):
			steering += 10
		if Input.is_action_pressed("ui_right"):
			steering -= 10
		if steering != 0:
			engine_force *= -5
		player_car.set_steering(steering)
		player_car.set_brake(brake)
		player_car.set_engine_force(engine_force)

func abandon():
	timer.stop()
	car_UI.hide()

func spawn_car(position):
	print("spawn block !")
	var car = Car.instance()
	car.transform.origin = position
	add_child(car)
	return car

func _on_Timer_timeout():
	if STATE == 3: 
		colorRect.color = Color.red
	elif STATE == 2 :
		colorRect.color = Color.orange
	elif STATE == 1 :
		colorRect.color = Color.green
	elif STATE == 0 :
		colorRect.hide()
		timer.wait_time = 7
	elif STATE == -1 :
		car_UI.hide()
	STATE -= 1
	