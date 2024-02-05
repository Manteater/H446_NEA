extends Button
export(String, FILE) var next_scene_path: = "res://Source/Levels/HUB.tscn"
export var saveGamePath = "user://save1.tres"
var save: SaveGame
signal loadGame(Save)

func _on_loadSaveGameButton_button_up():
	get_tree().change_scene(next_scene_path)#opens the hub scene as this will always be the case for any load game
	save = ResourceLoader.load(saveGamePath,"",true)#saves the game using the resourcesaver
	Global.characterSave = save.Character#copies the file to a global variable
	


