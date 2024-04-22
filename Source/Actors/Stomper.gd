extends Actor
#exports


#Nodes
onready var pathTimer = $pathTimer#access to timer to update pathfinding

#other
var awoken = false
var moved = false
var attack = false


func _ready():
	los = $RayCast2D#acess to the Stompers line of sight
	agent = $NavigationAgent2D#access to the navigation
	animPlayer = $AnimationPlayer#access to animation player
	playerSpotted = false#by default player is not spotted
	updatePathfinding()#sets up the pathfinding loop
	pathTimer.connect("timeout",self,"updatePathfinding")#calls the updatepathfinding function everytime the timer timesout

func _physics_process(delta):#function calls every frame of the game
	if not dead:
		animate()
		if is_instance_valid(player):
			checkPlayer()
		
		if playerSpotted:
			move(delta)
		else:
			velocity = Vector2.ZERO
	elif not died:
		die()
		died = true
func animate():
	if not awoken:#if the stomper hasnt seen the player then it sleeps
			animPlayer.play("sleeping")
	elif moved:
		animPlayer.play("Awake")
		yield(animPlayer,"animation_finished")
		moved = false#moved is set back to false so the animation only plays once
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
		moved = true#this ameks sure that the awaken animation plays when it should but only once
		awoken = true#this controls when the stomper stops playing the sleep animation
	if not moved:#this is to make sure that the stomper only moves once the awakening animation is completed.
		var direction := global_position.direction_to(agent.get_next_location()) #sets the direction to the desired position
		var desiredVelocity := direction * speed #sets the speed of the stomper
		var steering = (desiredVelocity - velocity)*delta*4.0 #sets the speed in relation to current speed
		velocity += steering
		velocity = move_and_slide(velocity)#actually moves the stomper on the screen
	






func _on_playerKiller_body_entered(body):
	attack = true
	while attack:#while the player is in the attack range
		if body.is_in_group("Player"):
			body.applyDamage(35)#the player  takes damage
			yield(get_tree().create_timer(1),"timeout")#the stomper can only attack once per second


func _on_playerKiller_body_exited(_body):
	attack = false#attack is reset so the player doesnt take damage when out of range
