extends Spatial

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var animator = get_node("AnimationPlayer")
onready var stream = get_node("AudioStreamPlayer3D")

# Called when the node enters the scene tree for the first time.
func _ready():
	animator.play("cheering")

func pause():
	animator.stop()
	stream.stop()

func resume():
	animator.play("cheering")
	stream.play()

func _on_Area_body_entered(body):
	var pantin = body as Pantin
	var car = body as Car
	if not car and not pantin :
		return
	if !stream.playing :
		stream.play()


func _on_Area_body_exited(body):
	var pantin = body as Pantin
	var car = body as Car
	if not car and not pantin :
		return
	var tween = Tween.new()
	tween.interpolate_property(stream, "max_db", stream.get_max_db(), -100, 5, Tween.TRANS_SINE , Tween.EASE_IN_OUT)
	add_child(tween)
	tween.start()
