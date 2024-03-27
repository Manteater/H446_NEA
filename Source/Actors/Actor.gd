extends KinematicBody2D
class_name Actor

#properies
export var health : int = 100#healthof enemy
export var speed : int = 100#speed of enemy
export var damage := 10#damage enmy applies when attackingplayer
export var experienceDropped := 10#the experience the player gains when killing enemy
export var moneyDropped := 1#theamount of money the enemy drops on death
var Coin = preload("res://Source/Prop stuff/Coin.tscn")
var died = false

#bools
var dead = false#tracks whether the enmy is dead or not
var playerSpotted = false#determines wether the player is in sight

#nodes
onready var animPlayer : AnimationPlayer#the animation player to play the animations
var los : RayCast2D#the line thats tracks the player
var agent : NavigationAgent2D#the node that controls the navigation

#other
var player = null#the player
var collider = null#the collsiondetection of the line of sight
var velocity := Vector2.ZERO#the direction the enemy is moving


func _ready():
	player = get_tree().get_nodes_in_group("Player")[0]#gives the player node a value

func applyDamage(amount):
	health-=amount#reduces health by the damage
	if health < 0:
		dead = true#the enemy dies when health drops below 0
		

func die():
	animPlayer.play("Death")#the death animation calls the queue_free() function and delets the node
	var coin = Coin.instance()#instances a coin 
	coin.global_position = global_position#sets the global position of the coin
	coin.value = moneyDropped#gives the coin the correct money value
	get_node("/root").add_child(coin)#makes the coin a child of the root node
	Global.characterSave.xp += experienceDropped#adds the experience to the player 

func checkPlayer():
	los.look_at(player.global_position)
	collider = los.get_collider() #collidr is the hitbox of the raycast
	if collider and collider.is_in_group("Player"):#if the line of sight is inside of the player
		playerSpotted = true
	else:
		playerSpotted = false
		
func updatePathfinding():
	if playerSpotted:			#only sets a path when the player is spotted
		agent.set_target_location(player.global_position)	#sets target location of the path
		
