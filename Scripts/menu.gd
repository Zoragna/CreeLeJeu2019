extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var Credits
var Main

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func change_scene(value):
	get_tree().change_scene(value)


func _on_Button_pressed():
	change_scene("res://Scenes/main.tscn")


func _on_Button2_pressed():
	change_scene("res://Scenes/credits.tscn")
