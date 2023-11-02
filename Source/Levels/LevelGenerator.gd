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
	
	for i in objects.get_children():
		if i is Player:#removes the player if the player is still in the world
			i.delete()
			continue
		i.queue_free()

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
		border.set_cell(coordX,coordY,1)
		if directionVec.y == 0:#if the y value doesnt change then the path must be horizontal
			#either up or down
			#puts tiles up and below the y coordinates
			border.set_cell(coordX,coordY+1,0)
			ground.set_cell(coordX,coordY+1,0)
			border.set_cell(coordX,coordY-1,0)
			ground.set_cell(coordX,coordY-1,0)
		else:	#otherwise it must be vertical
			#puts cells left and right of the coordinate
			border.set_cell(coordX+1,coordY,0)
			ground.set_cell(coordX+1,coordY,0)
			border.set_cell(coordX-1,coordY,0)
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

func saveRoomExits(currentCoord:Vector2,room:Room_,exceptions = []):
	var exitCells = room.get_node("connections").get_used_cells()#gets the connections in the given room
	for i in exitCells:
		if i in exceptions: continue
		#adds the coordinate to the current cooridinate - making sure it is in relation to where the map is currently being generated
		unusedDoors.append({"coord":i, "direction":room.get_node("connections").get_cell(i.x,i.y)})
		
func getRandomDoor():
	print(unusedDoors.size())
	var door = unusedDoors[randi()%unusedDoors.size()]#picks a random door from the unused doors list
	unusedDoors.erase(door)#the door is used so it is deletedfrom the unused door list
	return door
	


func generateMap(numberOfRooms):
	var rooms= loadRoomPaths(roomFolderPath)#loads all of the rooms into an array
	var currentCoord = Vector2.ZERO#the current coord from which the room is spawned
	var currentCell = Vector2.ZERO
	var roomsLeft = numberOfRooms
	var door = null
	var separation = 1920#the distance between the centres of the rooms
	var direction = null
	var prevDirection = null
	var doorCoord = null
	var room: Room_
	var validDoor = false
	while roomsLeft>0:
		
		if roomsLeft == numberOfRooms:
			#the first room is placed
			room = load(startRoomPath).instance()#random room is picked from the list
			room.global_position = Vector2.ZERO#position is set to (0,0)
			saveRoomExits(currentCell,room)#the exits are saved
			get_tree().get_current_scene().add_child(room)#the room is placed
			print(unusedDoors)

		else:
			validDoor = false
			while not validDoor:
				#door is fetched
				door = getRandomDoor()
				direction = door["direction"]
				if direction != getOppositeDirection(prevDirection):
					validDoor = true
			#the direction of the door is determined
			#and the location of the next room is calculated
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
			#connection is drawn
			#coordinate of the door is calculated as a tilemap co-oridinate
			doorCoord = currentCell+door["coord"]
			makeConnection(doorCoord,door["direction"],10)#a path is made from the door and 10 cells into the doors direction
			#the room is placed at the end of the connection
			room = load(rooms[randi()%rooms.size()]).instance()#random room is picked from the list
			room.global_position = currentCoord#room position is set to current actual co-ordinate
			currentCell = border.world_to_map(currentCoord)#new cell is calculated from the position of the room
			saveRoomExits(currentCell,room)#the exits are saved into unusedDoors
			get_tree().get_current_scene().add_child(room)#the room is placed
			prevDirection = direction
			
		
		
		
		
		#print(unusedDoors)
		roomsLeft-=1#roomselft is reduced by one










