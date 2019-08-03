extends Spatial

onready var animator = get_node("AnimationPlayer")

var close_bodies = []

# Called when the node enters the scene tree for the first time.
func _ready():
	animator.play("idle")

func pause():
	animator.stop()

func resume():
	animator.play()

func _on_StaticBody2_body_entered(body):
	var pantin := body as Pantin
	if not pantin :
		print("not pantin")
		return
	close_bodies.append(body)
	print("body entered")

func _on_StaticBody2_body_exited(body):
	var pantin := body as Pantin
	if not pantin :
		print("not pantin")
		return
	close_bodies.erase(body)
	print("body exited")
