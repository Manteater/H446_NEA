extends Actor

#exported variables
export var patrolSpeed = 150#this defines the speed of the drone when it is patrolling

#nodes
onready var pathTimer = $pathTimer#timer to update the pathfinding 
onready var bullet = preload("res://Source/Weapons/droneBullet.tscn")

#bools
var patrolling = true#this is the state that the drone spawns in at
var playerInRange = false#determines if the player is in range to shoot at
var collided = false#is used to detect when the drone has collided with a wall
var canShoot = false#determines if the drone can shoot at the player or not

#weapons
var projectiles = []#stores all of the drones projectiles

#other
var rng = RandomNumberGenerator.new() #used to make random numbers
var patrolDirection = null


func _ready():
	agent = $NavigationAgent2D#access to the navigation
	los = $lineOfSight#access to the RayCast2D
	animPlayer = $AnimationPlayer#access to animation player
	pathTimer.connect("timeout",self,"updatePathfinding")#calls the updatepathfinding function everytime the timer timesout
	rng.randomize()#resets the seed for the randomizer - else it would keep spitting out the same number as it is only pseudo random
	patrolDirection = rng.randi_range(1,2)#1 and 2 refer to x or y direction for patrolling

func _physics_process(delta):
	if not dead:
		if is_instance_valid(player):
			checkPlayer()#checks if the player is in sight
			if playerSpotted:
				patrolling = false
				updatePathfinding()#sets the target location of the path as the player
			if not patrolling:#if the drone has seen the player at least once
				if playerInRange:
					animPlayer.play("shootLeft")#the shootLeft animation calls the shoot function at the end so this just means the drone shoots#
				else:
					animate()#animates the drone as per usual
					move(delta)#the drone moves toward the player
		if patrolling:
			patrol(patrolDirection)#if the drone should be patrolling the procecdure is called
			animate()#plays the drones animations
		controlBullets(delta)
	else:
		die()

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



		
func shoot():
	var velocity = Vector2.ZERO#the velocity of the bullet
	var projectile = bullet.instance()#a new instance of the drone bullet is created
	projectile.rotation = los.rotation# the line of sight tracks the player so the bullets rotation can be simply set to this
	projectile.add_collision_exception_with(get_parent())#prevents the bullet from colliding with the parent
	projectile.global_position = global_position#bullet position is set to the same position as the drone
	get_node("/root").add_child(projectile)#the bullet is set as the child of the root node
	velocity = Vector2(500,0).rotated(projectile.rotation)#bullet velocity is at a speed of 500 in the direction of rotation
	projectiles.append({"projectile":projectile,"velocity":velocity,"ticks":0})#the bullet is stored in the diciotnary with its velocity and lifetime

func controlBullets(delta):
	for i in projectiles:#loop through the array
		var p = i["projectile"]#the bullet object is stored in the variable p
		var velocity = i["velocity"]
		if i["ticks"] >= 200:#checks if the game has ticked more than the bulletlifetime
			projectiles.erase(i)#the infromation is erased from the array
		var collision = p.move_and_collide(velocity*delta)#an in-built function is used to make the bullet move
		if (collision):#if a collsion is detected
			var collider = collision.collider
			if (collider.is_in_group("Player")):#if the collidr is the player then damage is applied to the player
				collider.applyDamage(damage)
			p.queue_free()
			projectiles.erase(i)#if the Sbullet collides then it is deleted
			
		i["ticks"]+=1#ticks are incremented
	
	


func _on_WallDetector_body_entered(body):
	collided = true#when a walls hitbox enters the drones hitbox this function is called


func _on_Range_body_entered(body):
	playerInRange = true#detects when the player moves into range


func _on_Range_body_exited(body):
	playerInRange = false#detects whn the player leaves the range
