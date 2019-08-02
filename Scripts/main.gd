extends Spatial

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var camera = get_node("Camera")
onready var pantin = get_node("pantin")

onready var beacon = get_node("beacon")
onready var lego_game = beacon.get_node("lego game")
onready var beacon2 = get_node("beacon2")

var current_camera
var current_mission

# Called when the node enters the scene tree for the first time.
func _ready():
	current_camera = camera
	current_camera.current = true
	
	pantin.pause()
	pantin.connect("launching_game",self,"_on_player_interact")
	pantin.connect("abandonning_game",self,"_on_player_deinteract")
	
	beacon.set_game(lego_game)
	beacon.connect("game_launched",lego_game,"start")
	beacon.connect("game_abandonned",lego_game,"abandon")

func _on_player_interact():
	if pantin in beacon.close_bodies :
		print("beacon")
		beacon.launch_game()
		change_camera(lego_game.camera)
		current_mission = lego_game
	elif pantin in beacon2.close_bodies :
		print("beacon2")

func _on_player_deinteract():
	if pantin in beacon.close_bodies :
		print("debeacon")
		beacon.abandon_game()
		change_camera(pantin.camera)
		current_mission = null
	elif pantin in beacon2.close_bodies :
		print("debeacon2")

func _input(event):
	if event is InputEventKey :
		if Input.is_action_just_pressed("ui_cancel"):
			if current_camera == camera :
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
				if pantin.STATE == "RUN" :
					change_camera(pantin.camera)
				elif pantin.STATE == "MISSION":
					change_camera(current_mission.camera)
				resume()
			else :
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
				change_camera(camera)
				pause()

func change_camera(value):
	current_camera.current = false
	current_camera = value
	current_camera.current = true

func pause():
	pantin.pause()
	lego_game.pause()

func resume():
	pantin.resume()
	lego_game.resume()
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
