extends Node2D
class_name Room_

onready var border = $border #this is the part of the tilemap that outlines the room
onready var connection = $connections
export var avoid_collisions := true#this means the room avoids collisions with toher rooms
export var add_connections := true#this means that the room can accept new connections

enum Directions{down,left,right,up}#stores the connections in each direction

func getConnectionTiles():
	var result = {"up":[],"down":[],"left":[],"right":[]}#dictionary to store arrays of all connections in each direction
	
	for i in $connections.get_used_cells():#iterates over all used tiles in the tilemap of connections
		match $connections.get_cell(i.x,i.y):#fetches the x and y co-ordinates of each used cell
			Directions.down: result.down.append(i)#stores this is the dictionary
			Directions.left: result.left.append(i)
			Directions.right: result.right.append(i)
			Directions.up: result.up.append(i)
	
	return result
