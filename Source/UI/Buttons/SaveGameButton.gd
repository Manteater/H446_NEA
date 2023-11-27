extends Button

export var saveGamePath = "user://save1.tres"#saves the file to the user 
var save:= SaveGame.new()#creates a new saveGame resource to save the game

func saveGame():
	var player = get_tree().get_nodes_in_group("Player")[0]#as the saevGame menu will always be in the
	#same tree as the player the player can simply be fetched
	save.character = player.stats#the players stat file is copied
	save.writeSaveGame(saveGamePath)#file is saved

func _on_SaveGameButton_pressed():
	saveGame()
