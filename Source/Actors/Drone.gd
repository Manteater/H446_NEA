extends KinematicBody2D

#exported variables
export var speed = 225
export var playerPath := NodePath() #gives access to the player node if it is in the same tree

#nodes
onready var animPlayer = $AnimationPlayer#access to animation player
onready var lineOfSight = $RayCast2D#access to the RayCast2D
onready var agent = $NavigationAgent2D#access to the navigation
onready var pathTimer = $pathTimer#timer to update the pathfinding

#bools
var patrolling = true#this is the state that the drone spawns in at
var playerSpotted = false#determines wether the player is in sight
var playerInRange = false#determines if the player is in range to shoot at

#other
var velocity := Vector2.ZERO
var collider = null
