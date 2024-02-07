extends Actor
export var playerPath := NodePath()#allows importing of the player scene
onready var player := get_node(playerPath)
#nodes
onready var animPlayer = $AnimationPlayer#access to animation player
onready var los = $lineOfSight#access to the RayCast2D
onready var agent = $NavigationAgent2D#access to the navigation
onready var pathTimer = $pathTimer#timer to update the pathfinding

#properties
var collider = null
var velocity = Vector2.ZERO

#bools
var playerSpotted = false
var attack = false

func _ready():
	playerSpotted = false#by default player is not spotted
	updatePathfinding()#sets up the pathfinding loop
	pathTimer.connect("timeout",self,"updatePathfinding")#calls the updatepathfinding function everytime the timer timesout
	
func _physics_process(delta):
	if not dead:
		if not attack:
			animate()
		if is_instance_valid(player):
			checkPlayer()
		if playerSpotted:
			updatePathfinding()
			move(delta)
		else:
			velocity = Vector2.ZERO
	else:
		die()
	

func animate():
	if velocity != Vector2.ZERO:#if the stomper is moving
		if velocity.x > 0:#if it is moving to the right
			animPlayer.play("runRight")
		else:#if it is moving to the left
			animPlayer.play("runLeft")
	else:#if the stomper isnt moving then it plays the idle animation
		animPlayer.play("idle")


func updatePathfinding():
	if playerSpotted:			#only sets a path when the player is spotted
		agent.set_target_location(player.global_position)	#sets target location of the path

func checkPlayer():
	los.look_at(player.global_position)
	collider = los.get_collider() #collidr is the hitbox of the raycast
	if collider and collider.is_in_group("Player"):#if the line of sight is inside of the player
		playerSpotted = true
	else:
		playerSpotted = false

func move(delta):
	if agent.is_navigation_finished():#if the navigation is completed itg cancels the function
		return
	var direction := global_position.direction_to(agent.get_next_location()) #sets the direction to the desired position
	var desiredVelocity := direction * speed #sets the speed of the stomper
	var steering = (desiredVelocity - velocity)*delta*4.0 #sets the speed in relation to current speed
	velocity += steering
	velocity = move_and_slide(velocity)#actually moves the stomper on the screen


func die():
	animPlayer.play("Death")#the death animation calls the queue_free() function and delets the node


func _on_killArea_body_entered(body):
	attack = true
	while attack:
		if player.global_position.x<global_position.x:
			animPlayer.play("shootLeft")
		else:
			animPlayer.play("shootRight")
		yield(animPlayer,"animation_finished")
		body.applyDamage(20)

func _on_killArea_body_exited(body):
	attack = false
