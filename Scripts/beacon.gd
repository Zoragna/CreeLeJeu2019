extends Spatial

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

signal game_launched
signal game_abandonned

var game
var close_bodies = []

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_game(value):
	game = value

func get_game():
	return game

func launch_game():
	emit_signal("game_launched")

func abandon_game():
	emit_signal("game_abandonned")

func _on_Area_body_entered(body):
	close_bodies.append(body)
	print("entered")


func _on_Area_body_exited(body):
	close_bodies.erase(body)
	print("exited")