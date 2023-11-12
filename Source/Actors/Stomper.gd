extends Actor
#exports
export var maxSpeed: int  = 150
export var playerPath := NodePath()#allows importing of the player scene

#Nodes
onready var animPlayer = $AnimationPlayer #access to animation player
onready var player := get_node(playerPath)
onready var agent = $NavigationAgent2D# access to the navigation of the level
onready var pathTimer = $pathTimer#access to timer to update pathfinding
onready var los = $RayCast2D#acess to the Stompers line of sight

#other
var velocity := Vector2.ZERO
var playerSpotted = false
var collider = null
var awoken = false


func _ready():
	playerSpotted = false#by default player is not spotted
	updatePathfinding()#sets up the pathfinding loop
	pathTimer.connect("timeout",self,"updatePathfinding")#calls the updatepathfinding function everytime the timer timesout

func _physics_process(delta):#function calls every frame of the game
	animate()
	if is_instance_valid(player):
		checkPlayer()
	
	if playerSpotted:
		move(delta)
	else:
		velocity = Vector2.ZERO
	
func animate():
	if not awoken:#if the stomper hasnt seen the player then it sleeps
			animPlayer.play("sleeping")
	else:
		if velocity != Vector2.ZERO:#if the stomper is moving
			if velocity.x > 0:#if it is moving to the right
				animPlayer.play("run_right")
			else:#if it is moving to the left
				animPlayer.play("run_left")
		else:#if the stomper isnt moving then it plays the idle animation
			animPlayer.play("idle_right")
		
	
	
	
func move(delta):
	if agent.is_navigation_finished():#if the navigation is completed itg cancels the function
		return
	if not awoken:#if the stomper hasn't awoken before then it will do so now as the player must have been spotted
		awaken()
	awoken = true
	var direction := global_position.direction_to(agent.get_next_location()) #sets the direction to the desired position
	var desiredVelocity := direction * maxSpeed #sets the speed of the stomper
	var steering = (desiredVelocity - velocity)*delta*4.0 #sets the speed in relation to current speed
	velocity += steering
	velocity = move_and_slide(velocity)#actually moves the stomper on the screen
	

func awaken():
	print("awakening")
	animPlayer.play("Awake")
	yield(get_tree().create_timer(0.5),"timeout")# pauses the stomper as the animation plays

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
