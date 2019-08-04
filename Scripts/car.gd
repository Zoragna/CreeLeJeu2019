extends VehicleBody

class_name Car

var player = false

onready var camera = get_node("Camera")
onready var gui = get_node("Control")

var paused_velocity

func _ready():
	hide_gui()

func make_player():
	player = true

func unmake_player():
	player = false

func _process(delta):
	pass

func hide_gui():
	gui.hide()

func show_gui():
	gui.show()

func pause():
	paused_velocity = get_linear_velocity()
	set_sleeping(true)
	set_linear_velocity(Vector3())

func resume():
	set_sleeping(false)
	set_linear_velocity(paused_velocity)