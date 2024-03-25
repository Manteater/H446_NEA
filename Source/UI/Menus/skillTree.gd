extends Control


func _on_button_pressed():
	visible = false
	get_tree().paused = false

func _physics_process(delta):
	$points.text = "Points: "+str(Global.characterSave.xpPoints)
