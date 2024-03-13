extends Node

func _ready():
	LevelGenerator.connectionArrows = $connections
	#LevelGenerator.wall = $wall
	LevelGenerator.ground = $ground
	LevelGenerator.border=$border
	LevelGenerator.generateMap(-11)#test
