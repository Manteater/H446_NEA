extends Button
export(String, FILE) var next_scene_path: = ""
export var saveGamePath = "user://save1"
var save: SaveGame


func _on_loadSaveGameButton_button_up():
	get_tree().change_scene(next_scene_path)
	print("called")
	save = SaveGame.loadSaveGame(saveGamePath)
	_PlayerStats = save.Character
