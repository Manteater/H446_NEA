extends KinematicBody2D
class_name Player

export var speed: = 300#determines speed of player
onready var anim_player: AnimationPlayer = $AnimationPlayer#fetches the animationplayer node
onready var tree = get_tree()#fetches access to the node tree
export onready var health = 3
onready var interactions = []#stores all the objects being interacted with in a stack
onready var interactLabel = $interactLabel
var player = null
var _velocity = Vector2.ZERO


func _ready():
	player = tree.get_nodes_in_group("Player")[0]#fetches the player node to access certain attributes
	updateInteractions()

func _physics_process(delta: float) -> void:
	if health == 0:
		die()
	#fetches the position vector of the cursor
	var mouse = get_global_mouse_position()
	#moves the player
	read_input(delta)
	#animates the players movements
	animate(mouse)
	
	

func get_direction() -> Vector2:#returns a vector2 for the direction of movement based on the input
	return Vector2(
		Input.get_action_strength("move_right")- Input.get_action_strength("move_left"),#value between 1 and -1
	Input.get_action_strength("move_down")- Input.get_action_strength("move_up"))#value between 1 and -1
		
func calculate_move_velocity(
	linear_velocity: Vector2,
	direction: Vector2,
	speed
	) -> Vector2:
		var out:=linear_velocity
		#multiplies the direction by the speed of the player
		out.x = speed*direction.x
		out.y = speed*direction.y
		return out

func read_input(delta):
	
	var direction = get_direction()#gets the direction the player is moving in
	_velocity = calculate_move_velocity(_velocity, direction,speed)#calculates the speed at which the player is moving
	_velocity = move_and_slide(_velocity)#moves the player with in-built function

	if Input.is_action_pressed("dash") and $dash_cooldown.time_left == 0:#if the dash key is pressed and cooldown has reset the player dashes
		dash()
	
	if Input.is_action_pressed("shoot"):
		var gun = $Gun
		gun.fire()
	
	if Input.is_action_just_pressed("Interact"):
		executeInteractions()

func dash():
	speed = speed*4#increases the speed of the player
	immune(true)#makes theplayer immune to damage
	#starts the timersS
	$dash_timer.start()
	$dash_cooldown.start()

func _on_dash_timer_timeout():
	speed=300#resets the speed of the player
	immune(false)#immunity is false
	

func _on_hit_detector_body_entered(body):#if a body enters the player's hitbox
	health -= 1
	

func animate(mouse):
	if _velocity != Vector2.ZERO:#when player IS moving
		if player.global_position.x < mouse.x:#if the mouse is to the right of the player
			anim_player.play("run_right")
		else:
			anim_player.play("run_left")
	else:#when player isnt moving
		if player.global_position.x < mouse.x:#if the mouse is to the right of the player
			anim_player.play("idle_right")
		else:
			anim_player.play("idle_left")



func immune(immunity)->void:
	if immunity:
		modulate.a = 0.5#makes the player slightly transparent to show the player that i frames are active
		$hit_detector/bullet_detector.disabled = true#disables the player's hitbox
	elif not immunity:
		modulate.a = 1.0#makes the player look normal again
		$hit_detector/bullet_detector.disabled = false#enables the player's hitbox

func die():
	anim_player.play("Death")#plays the death animation



func _on_interactionArea_area_entered(area):#when something enters the area
	interactions.insert(0,area)#adds the area object to the front of the list
	updateInteractions()


func _on_interactionArea_area_exited(area):#when something exits the area
	interactions.erase(area)#removes the area object from the list
	updateInteractions()

func updateInteractions():
	if interactions:
		interactLabel.text = interactions[0].interactLbl#fetches the object at index 0 and displays its text
	else:
		interactLabel.text = ""#resets the label

func executeInteractions():
	if interactions:
		var curInteraction = interactions[0]#fetches the object at index 0
		match curInteraction.interactValue:#matches the interact value with a given action
			"open Shop": print("shop is opening")#in this case the shop will open
		
	
