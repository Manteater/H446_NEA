extends Enemy
#exported variables
#this defines the speed of the drone when it is chasing the player
export var patrolSpeed = 150#this defines the speed of the drone when it is patrolling
export var playerPath := NodePath() #gives access to the player node if it is in the same tree

#nodes
onready var animPlayer = $AnimationPlayer#access to animation player
onready var lineOfSight = $lineOfSight#access to the RayCast2D
onready var agent = $NavigationAgent2D#access to the navigation
onready var pathTimer = $pathTimer#timer to update the pathfinding
onready var player := get_node(playerPath)

#bools
var patrolling = true#this is the state that the drone spawns in at
var playerSpotted = false#determines wether the player is in sight
var playerInRange = false#determines if the player is in range to shoot at
var collided = false#is used to detect when the drone has collided with a wall
var canShoot = false#determines if the drone can shoot at the player or not

#other
var velocity := Vector2.ZERO
var collider = null
var rng = RandomNumberGenerator.new() #used to make random numbers
var patrolDirection = null

func _ready():
		pathTimer.connect("timeout",self,"updatePathfinding")#calls the updatepathfinding function everytime the timer timesout
		rng.randomize()#resets the seed for the randomizer - else it would keep spitting out the same number as it is only pseudo random
		patrolDirection = rng.randi_range(1,2)#1 and 2 refer to x or y direction for patrolling

func _physics_process(delta):
	if is_instance_valid(player):
		checkPlayer()#checks if the player is in sight
	if patrolling:
		patrol(patrolDirection)#if the drone should be patrolling the procecdure is called
	animate()#plays the drones animations
	if playerSpotted:
		patrolling = false
		updatePathfinding()#sets the target location of the path as the player 
	if not patrolling:#if the drone has seen the player at least once
		move(delta)

func move(delta):
	if agent.is_navigation_finished():#if the navigation is completed it cancels the function
		return
	var direction := global_position.direction_to(agent.get_next_location()) #sets the direction to the desired position
	var desiredVelocity = direction * speed #sets the speed of the drone
	var steering = (desiredVelocity - velocity)*delta*4.0 #sets the speed in relation to current speed
	velocity += steering
	velocity = move_and_slide(velocity)#actually moves the drone on the screen

func patrol(direction):
	if direction == 1:#1 means x -axis
		if collided:#if the drone has hit a wall then it turns around
			patrolSpeed = -1*patrolSpeed#speed is flipped
			collided = false#collided must be reset back to false in order to stop drone switching direction again
		velocity.x = patrolSpeed
		move_and_slide(velocity)#the drone is moved
	elif direction == 2:#same thing for the y - axis
		if collided:
			patrolSpeed = -1*patrolSpeed
			collided = false
		velocity.y =patrolSpeed
		move_and_slide(velocity)

func animate():
	if velocity != Vector2.ZERO:#if the drone is moving
			if velocity.x > 0:#if it is moving to the right
				animPlayer.play("flyRight")
			else:#if it is moving to the left
				animPlayer.play("flyLeft")
	else:#if the drone isnt moving then it plays the idle animation
		animPlayer.play("idle")

func updatePathfinding():
	if playerSpotted:#only sets a path when the player is spotted
		agent.set_target_location(player.global_position)#sets target location of the path

func checkPlayer():
	lineOfSight.look_at(player.global_position)#the raycast looks at the players position
	collider = lineOfSight.get_collider() #collider is the hitbox of the raycast
	if collider and collider.is_in_group("Player"):#if the line of sight is inside of the player
		playerSpotted = true
	else:
		playerSpotted = false
		

func _on_WallDetector_body_entered(body):
	collided = true#when a walls hitbox enters the drones hitbox this function is called
