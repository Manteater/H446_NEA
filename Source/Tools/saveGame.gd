class_name SaveGame
extends Resource 

export var character: Resource = Character.new()

func writeSaveGame(savePath):
	#always saves as tres not res beware
	ResourceSaver.save(savePath,self)#saves the player stats file as a savegame

static func loadSaveGame(savePath):
	if ResourceLoader.has_cached(savePath):
		return ResourceLoader.load(savePath,"",true)#loads the savegame into the game

