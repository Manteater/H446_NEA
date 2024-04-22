extends Node

const roomFolderPath = "res://Source/Levels/Rooms/NormalRooms/"#the directory at which the rooms are stored
const startRoomPath= "res://Source/Levels/Rooms/startRoom.tscn"

var border : TileMap
var ground : TileMap
var watch_timer : Timer
var wall : TileMap
var collisionDetection : TileMap
var connectionArrows : TileMap
var objects : YSort
var unusedDoors = []
var roomAmount=8

enum Directions{down,left,right,up}

const downDirection = Vector2(0,1)
const leftDirection = Vector2(-1,0)
const upDirection = Vector2(0,-1)
const rightDirection = Vector2(1,0)

const roomPlaceFailed = Vector2(1.5,1.5)
const roomPlaceSuccess = Vector2(0.1,0.1)

const directionsVector = [downDirection,leftDirection,
			rightDirection,upDirection]

const directionsSTR = ["down","left","right","up"]

func _ready():
	randomize()
	
func loadRoomPaths(path):#fetches all tcsn files in a folder
	var result = []#array to store the rooms
	var dir = Directory.new()#creates a new directory
	if dir.open(path) == OK:#checks if the file directory exists
		dir.list_dir_begin()
		var fileName = dir.get_next()#goes to the next file in the directory
		while fileName != "":#if the file has a name
			if "import" in fileName:#skip the file if it is an import file
				continue
			if ".tscn" in fileName: result.append(path+fileName)#if it is a scene file then it is appened to the array
			fileName = dir.get_next()
	return result

func clearMap():
	border.clear()#clears all border tiles
	ground.clear()#clears all ground tiles
	collisionDetection.clear()#clears all collisions
	unusedDoors.clear()#clears all the unused doors
	wall.clear()#clears all walls
	connectionArrows.clear()#clears all connecting arrow pointers
	
#	for i in objects.get_children():
#		if i is Player:#removes the player if the player is still in the world
#			i.delete()
#			continue
#		i.queue_free()

func makeConnection(startCell:Vector2,direction = Directions.down,length=5):
	#makes a connection from a starting cell
	var newStartPos:Vector2
	#print("startCell ",startCell)
	for i in range(length):#makes the connection the specified length
		var directionVec = directionsVector[direction]#gets the direction vector e.g. right is (0,1) as only x increases
		#print("direction: ",directionVec)
		var coordX = startCell.x + (directionVec*i).x#updates the vector by moving it in the direction specified
		var coordY = startCell.y + (directionVec*i).y
		#print("coordinate (", coordX,",",coordY,")")
		ground.set_cell(coordX,coordY,1)
		if directionVec.y == 0:#if the y value doesnt change then the path must be horizontal
			#either up or down
			#puts tiles up and below the y coordinates
			border.set_cell(coordX,coordY+1,0)
			ground.set_cell(coordX,coordY+1,0)
			border.set_cell(coordX,coordY-1,0)
			ground.set_cell(coordX,coordY-1,0)
		else:	#otherwise it must be vertical
			#puts cells left and right of the coordinate
			border.set_cell(coordX+1,coordY,2)
			ground.set_cell(coordX+1,coordY,0)
			border.set_cell(coordX-1,coordY,1)
			ground.set_cell(coordX-1,coordY,0)

		ground.set_cell(coordX,coordY,0)
		if connectionArrows.get_cell(coordX,coordY) != -1: connectionArrows.set_cell(coordX,coordY,-1)
	
	newStartPos = startCell + directionsVector[direction]*length
	return newStartPos
	
func canPlaceTiles(startCoord:Vector2,tiles:Array)-> bool:
	#checks if the tiles can be placed where intended 
	#returns false when there is a collision detected
	for i in tiles:
		if (collisionDetection.get_cell(startCoord.x+i.x,startCoord.y+i.y) != -1
		or collisionDetection.get_cell(startCoord.x+i.x+1,startCoord.y+i.y) != -1
		or collisionDetection.get_cell(startCoord.x+i.x-1,startCoord.y+i.y) != -1
		or collisionDetection.get_cell(startCoord.x+i.x,startCoord.y+i.y+1) != -1
		or collisionDetection.get_cell(startCoord.x+i.x,startCoord.y+i.y-1) != -1):
			print("collision detected")
			return false
	return true

func getOppositeDirection(direction):	
	#returns the oppposite direction of what is passed in as a parameter
	if direction == Directions.down: return Directions.up
	if direction == Directions.up: return Directions.down
	if direction == Directions.left: return Directions.right
	if direction == Directions.right: return Directions.left



func saveRoomExits(_currentCoord:Vector2,room:Room_,exceptions = []):
	var exitCells = room.get_node("connections").get_used_cells()#gets the connections in the given room
	for i in exitCells:
		if i in exceptions: continue
		#adds the coordinate to the current cooridinate - making sure it is in relation to where the map is currently being generated
		unusedDoors.append({"coord":i, "direction":room.get_node("connections").get_cell(i.x,i.y)})
		
func getRandomDoor():
	var door = unusedDoors[randi()%unusedDoors.size()]#picks a random door from the unused doors list
	unusedDoors.erase(door)#the door is used so it is deletedfrom the unused door list
	return door

func isOverlapping(newRoomPosition,newRoomSize):
	var existingRooms = get_tree().get_nodes_in_group("rooms")#all existing rooms are stored in an array
	var newRoomRect = Rect2(newRoomPosition,newRoomSize)#the projection of the new room is calculated
	for room in existingRooms:
		var existingRoomRect = Rect2(room.coord, room.getRoomSize())#the exisitng room is turned into a rectangle
		if existingRoomRect.intersects(newRoomRect):#if they intersect then the room cannot be placed there
			return true
	return false

func calcNewPosition(door,currentCoord,separation=1920):
	#calculates the new co ordinate of the room
	if door["direction"]==0:
		#down
		currentCoord.y+=separation#creates the separation between the rooms
	elif door["direction"]==1:
		#left
		currentCoord.x-=separation
	elif door["direction"]==2:
		#right
		currentCoord.x+=separation
	else:
		#up
		currentCoord.y-=separation
	return currentCoord

func removeCollisions(room):
	var roomBorderTiles = room.get_node("border")#the tilemap for the walls is fetched from the room node
	var roomGroundtiles = room.get_node("floor")
	var roomGroundUsed  = roomGroundtiles.get_used_cells()
	var roomBorderUsed= roomBorderTiles.get_used_cells()
	for cell in roomBorderUsed:#each potential door is iterated over
		var worldPos = roomBorderTiles.to_global(roomBorderTiles.map_to_world(cell))#the global position of each cell in the room node is calculated
		var localCell = ground.world_to_map(worldPos)#the map position of the cell that this co ordinate corresponds to is calculated
		if (ground.get_cell(localCell.x, localCell.y) != -1)and(border.get_cell(localCell.x,localCell.y)==-1):#if the cell is set then it means that tiles are overlapping
			roomBorderTiles.set_cell(cell.x, cell.y, -1)#then the room tile is set to dissapear
	for cell in roomGroundUsed:#every room cell used it iterated over
		var worldPos = roomGroundtiles.to_global(roomGroundtiles.map_to_world(cell))#the global co ordinates of the tile is calculated
		var localCell = border.world_to_map(worldPos)#the corresponding cell from the connection is fetched
		if border.get_cell(localCell.x, localCell.y) != -1:#if the cell is collifding then it is removed 
			border.set_cell(localCell.x,localCell.y,-1)


func calcConnectionLength(room,direction,separation):
	var radius = null
	match direction:
		0: radius = room.upRadius
		1: radius = room.rightRadius
		2: radius = room.leftRadius
		3: radius = room.downRadius
	var length = (separation - (radius*96))/96
	return length

func calcSeparation(room,prevRoom,direction):
	var radius = null#radius of the new room
	var prevRadius = null#radius of the old room
	match direction:#matches the directio0n with the radius in
		# the oppposite direction as this will be the side of the room facing to the door
		0: radius = room.upRadius
		1: radius = room.rightRadius
		2: radius = room.leftRadius
		3: radius = room.downRadius
	match direction:#matches the direction with the radius in the same direction as it is the same door,
		0:prevRadius = prevRoom.downRadius
		1:prevRadius = prevRoom.downRadius
		2:prevRadius = prevRoom.downRadius
		3:prevRadius = prevRoom.downRadius
	var separation = (96*radius)+(96*prevRadius)+(10*96)#everything is in multiples of 96 as the tileset is 96x96
	return separation



func generateMap(numberOfRooms):
	var rooms= loadRoomPaths(roomFolderPath)#loads all of the rooms into an array
	var currentCoord = Vector2.ZERO#the current coord from which the room is spawned
	var currentCell = Vector2.ZERO
	var roomsLeft = numberOfRooms
	var door = null
	var separation = 1920#the distance between the centres of the rooms
	var direction = null
	var doorCoord = null
	var validDoor = false
	var room: Room_
	var prevRoom:Room_
	while roomsLeft>0:
		
		if roomsLeft == numberOfRooms:
			#the first room is placed
			room = load(startRoomPath).instance()#random room is picked from the list
			room.global_position = Vector2.ZERO#position is set to (0,0)
			room.coord = Vector2(0,0)
			saveRoomExits(currentCell,room)#the exits are saved
			get_tree().get_current_scene().add_child(room)#the room is placed
			prevRoom = room

		else:
			#the direction of the door is determined
			#and the location of the next room is calculated
			validDoor = false
			room = load(rooms[randi()%rooms.size()]).instance()#random room is picked from the list
			while not validDoor:
				door = getRandomDoor()# a new door is fetched
				direction = door["direction"]
				separation = calcSeparation(prevRoom,room,direction)
				var newCoord = calcNewPosition(door,currentCoord,separation)#the estimated new co ordinate is calculated
				if not isOverlapping(newCoord,room.getRoomSize()):#the collision is checked
					validDoor = true
					currentCoord = newCoord
			
			
			var connectionLength = calcConnectionLength(room,direction,separation)
			#connection is drawn
			#coordinate of the door is calculated as a tilemap co-oridinate
			doorCoord = border.world_to_map(border.map_to_world(currentCell)+border.map_to_world(door["coord"]))
			#print(unusedDoors)
			makeConnection(doorCoord,direction,connectionLength)#a path is made from the door and 10 cells into the doors direction
			removeCollisions(prevRoom)
			#the room is placed at the end of the connection
			room.global_position = currentCoord#room position is set to current actual co-ordinate
			currentCell = border.world_to_map(currentCoord)#new cell is calculated from the position of the room
			saveRoomExits(currentCell,room)#the exits are saved into unusedDoors
			get_tree().get_current_scene().add_child(room)#the room is placed
			room.coord = currentCoord
			removeCollisions(room)
			prevRoom = room
		roomsLeft-=1#roomselft is reduced by one
	print(unusedDoors)










