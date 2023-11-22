extends Button

export var saveGamePath = "user://save1"
var save:= SaveGame.new()

func saveGame():
	save.writeSaveGame(saveGamePath)

func _on_SaveGameButton_pressed():
	saveGame()
