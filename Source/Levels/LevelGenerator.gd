extends Node

const roomFolderPath = "res://Source/Levels/Rooms/NormalRooms/"#the directory at which the rooms are stored

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
	#makes a connection from a stating cell
	var newStartPos:Vector2
	
	for i in range(length):#makes the connection the specified length
		var directionVec = directionsVector[direction]
		var coordX = startCell.x + (directionVec*i).x#updates the vector by moving it in the direction specified
		var coordY = startCell.x + (directionVec*i).y
		
		border.set_cell(coordX,coordY,0)
		border.update_bitmask_area(Vector2(coordX,coordY))
		if directionVec.y == 0:
			#either up or down
			#puts tiles up and below the y coordinates
			border.set_cell(coordX,coordY+1,0)
			border.update_bitmask_area(Vector2(coordX,coordY+1))
			ground.set_cell(coordX,coordY+1,0)
			border.set_cell(coordX,coordY-1,0)
			border.update_bitmask_area(Vector2(coordX,coordY-1))
			ground.set_cell(coordX,coordY-1,0)
		else:
			#puts cells left and right of the coordinate
			border.set_cell(coordX+1,coordY,0)
			border.update_bitmask_area(Vector2(coordX,coordY+1))
			ground.set_cell(coordX+1,coordY,0)
			border.set_cell(coordX-1,coordY,0)
			border.update_bitmask_area(Vector2(coordX,coordY-1))
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

func saveRoomExits(currentCell:Vector2,room:Room_,exceptions = []):
	var exitCells = room.get_node("connections").get_used_cells()#gets the connections in the given room
	for i in exitCells:
		if i in exceptions: continue
		#adds the coordinate to the current cooridinate - makinbg sure it is in relation to where the map is currently being generated
		unusedDoors.append({"coord":currentCell+i, "direction":room.get_node("connections").get_cell(i.x,i.y)})
		
		
func drawRoom(curreenCell:Vector2,room:Room_):
	#fetch all of the tilemaps native to the room
	var borderCells = room.get_node("border").get_used_cells()
	var groundCells = room.get_node("ground").get_used_cells()
	var connectionCells = room.get_node("connections").get_used_cells()
	
	for i in borderCells:
		border.set_cell()












