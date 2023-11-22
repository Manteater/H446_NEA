extends Button
export(String, FILE) var next_scene_path: = ""



func _on_changeSceneButton_button_up():
	get_tree().change_scene(next_scene_path)
