extends Actor

#nodes
onready var pathTimer = $pathTimer#timer to update the pathfinding

#properties

#bools
var attack = false#this controls when the runnerGuy can play his attack animation

func _ready():
	agent = $NavigationAgent2D#access to the navigation
	los = $lineOfSight#access to the RayCast2D
	animPlayer = $AnimationPlayer#access to animation player
	playerSpotted = false#by default player is not spotted
	updatePathfinding()#sets up the pathfinding loop
	pathTimer.connect("timeout",self,"updatePathfinding")#calls the updatepathfinding function everytime the timer timesout
	
func _physics_process(delta):
	if not dead:#when the runner is not dead he can do things
		if not attack:#the runnerguy only plays running animations when he is not currrently attacking. this is so the animations dont override each other
			animate()
		if is_instance_valid(player):#checks if the player is a valid node to stop crashing
			checkPlayer()#updates theline of sight
		if playerSpotted:
			updatePathfinding()#pathfinds to the player
			move(delta)#moves along the path
		else:
			velocity = Vector2.ZERO#doersnt move if no player is found
	else:
		die()#delets the node and triggers any other events such as giving poitns or money
	

func animate():
	if velocity != Vector2.ZERO:#if the stomper is moving
		if velocity.x > 0:#if it is moving to the right
			animPlayer.play("runRight")
		else:#if it is moving to the left
			animPlayer.play("runLeft")
	else:#if the stomper isnt moving then it plays the idle animation
		animPlayer.play("idle")




func move(delta):
	if agent.is_navigation_finished():#if the navigation is completed itg cancels the function
		return
	var direction := global_position.direction_to(agent.get_next_location()) #sets the direction to the desired position
	var desiredVelocity := direction * speed #sets the speed of the stomper
	var steering = (desiredVelocity - velocity)*delta*4.0 #sets the speed in relation to current speed
	velocity += steering
	velocity = move_and_slide(velocity)#actually moves the stomper on the screen


func _on_killArea_body_entered(body):
	attack = true
	while attack:
		if player.global_position.x<global_position.x:#makes sure the attack animation is playing in the same direction as the player is in relation to the runner
			animPlayer.play("shootLeft")
		else:
			animPlayer.play("shootRight")
		yield(animPlayer,"animation_finished")#waits for the animation to end before applying the damage
		body.applyDamage(20)#20 damage is applied to theplayer

func _on_killArea_body_exited(body):
	attack = false# when the player exits the area the runner can no longer attack
