extends Spatial

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var pause_camera = get_node("pause_camera")
onready var travelling_camera = get_node("travelling_camera")
onready var pantin = get_node("pantin")

onready var mission_indicator = get_node("Control/mission_indicator")
onready var pause_gui = get_node("Control/pause")

onready var beacon = get_node("beacon")
onready var lego_game = beacon.get_node("lego game")
onready var beacon2 = get_node("beacon2")
onready var car_game = beacon2.get_node("car game")

onready var trex = get_node("trex")
onready var town = get_node("town")

var Trex = preload("res://Scenes/trex.tscn")

var paused = false

var current_camera
var current_mission
var close_beacon

# Called when the node enters the scene tree for the first time.
func _ready():
	mission_indicator.hide()
	pause_gui.hide()
	
	current_camera = travelling_camera
	current_camera.current = true

	pantin.connect("launching_game",self,"_on_player_interact")
	pantin.connect("abandonning_game",self,"_on_player_deinteract")
	
	beacon.set_game(lego_game)
	beacon.connect("game_launched",lego_game,"start")
	beacon.connect("game_abandonned",lego_game,"abandon")
	beacon.connect("player_entered",self,"player_entered", [beacon])
	beacon.connect("player_exited",self,"player_exited", [beacon])
	
	lego_game.connect("game_won",self,"player_won",[beacon])
	lego_game.connect("game_lost",self,"player_lost",[beacon])

	beacon2.set_game(car_game)
	beacon2.connect("game_launched",car_game,"start")
	beacon2.connect("game_abandonned",car_game,"abandon")
	beacon2.connect("player_entered",self,"player_entered", [beacon2])
	beacon2.connect("player_exited",self,"player_exited", [beacon2])
	
	car_game.connect("game_won",self,"player_won",[beacon2])
	car_game.connect("game_lost",self,"player_lost",[beacon2])
	
	yield(win_conditions(),"completed")
	print("YOU HAVE REACHED WINNING CONDITIONS !")
	get_tree().change_scene("res://Scenes/win_title.tscn")

func win_conditions():
	yield(car_game,"game_won")
	yield(lego_game,"game_won")
	
func _on_player_interact():
	if pantin.STATE != "RIDING" :
		if pantin in beacon.close_bodies :
			launch_beacon(beacon)
		elif pantin in beacon2.close_bodies :
			print("launching car game")
			launch_beacon(beacon2)
			var curve = car_game.get_node("checkpoint").get_curve()
			var checkpoints = []
			for i in range(curve.get_point_count()):
				checkpoints.append(curve.get_point_position(i))
			car_game.add_checkpoints(checkpoints)
		elif pantin in trex.close_bodies :
			print("pantin wants to ride trex")
			remove_child(trex)
			pantin.ride()

func player_entered(beacon):
	close_beacon = beacon

func player_exited(beacon):
	close_beacon = null
	mission_indicator.hide()

func player_won(beacon):
	abandon_game(beacon, true)

func player_lost(beacon):
	abandon_game(beacon, false)

func launch_beacon(beacon):
	print("beacon")
	beacon.launch_game()
	change_camera(beacon.get_game().camera)
	current_mission = beacon.get_game()
	mission_indicator.hide()

func _on_player_deinteract():
	if pantin.STATE == "RIDING" :
		print("pantin wants to leave trex")
		pantin.unride()
		trex = Trex.instance()
		#trex.transform.origin = pantin.transform.origin - pantin.velocity.normalized()*5
		trex.transform.origin = pantin.transform.origin + Vector3(1,2,1)
		add_child(trex)
	else :
		if pantin in beacon.close_bodies :
			abandon_game(beacon)
		elif pantin in beacon2.close_bodies :
			abandon_game(beacon2)

func abandon_game(beacon, player_won = false):
	print("debeacon")
	beacon.abandon_game(player_won)
	change_camera(travelling_camera)
	current_mission = null
	mission_indicator.show()
	if player_won :
		pantin.win()
	else :
		pantin.lose()

func _input(event):
	if event is InputEventKey :
		if Input.is_action_just_pressed("ui_cancel"):
			if current_camera == pause_camera :
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
				if pantin.STATE == "RUN" :
					change_camera(travelling_camera)
				elif pantin.STATE == "MISSION":
					change_camera(current_mission.camera)
				resume()
			else :
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
				change_camera(pause_camera)
				pause()

func change_camera(value):
	current_camera.current = false
	current_camera = value
	current_camera.current = true

func pause():
	paused = true
	trex.pause()
	pantin.pause()
	town.pause()
	if current_mission != null :
		current_mission.pause()
	elif close_beacon != null :
		mission_indicator.hide()
	pause_gui.show()

func resume():
	paused = false
	trex.resume()
	pantin.resume()
	town.resume()
	if current_mission != null :
		current_mission.resume()
	elif close_beacon != null :
		mission_indicator.show()
	pause_gui.hide()

func _physics_process(delta):
	travelling_camera.transform.origin = pantin.transform.origin + Vector3(0,8,-11)
	if pantin.transform.origin.y < - 50 :
		pantin.transform.origin.y = 10
	if close_beacon != null && !paused && current_mission == null :
		mission_indicator.rect_global_position = travelling_camera.unproject_position(close_beacon.transform.origin)+Vector2(0,-50)
		mission_indicator.show()
