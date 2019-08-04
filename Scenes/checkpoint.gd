extends Spatial

signal checkpoint_hit

func _on_Area_body_entered(body):
	print("checkpoint_hit")
	var car := body as Car
	if not car :
		print("not car")
		return
	elif not car.player :
		print("not player car")
		return
	emit_signal("checkpoint_hit")