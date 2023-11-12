extends Area2D

export var damage = 10
var doDamage = false#stores wether it is possible to apply damage to the body
var Body = null#stores the node that is currently being damaged by the acid
var canDamage=true
func _physics_process(delta):
	if doDamage:
		if canDamage:
			Body.applyDamage(damage)#the bodie's applyDamage function is called in order to reduce its health
			doDamage = false
			yield(get_tree().create_timer(0.35), "timeout")#the script is paused for 0.35s
			#during this time the player cannot take damage
			doDamage = true

func _on_Acid_body_entered(body):
	#this triggers when the player enters the tilemap collison area
	if body.is_in_group("Player"):#checks if it is the player
		doDamage = true#sets the doDamage to true
		Body = body

func _on_Acid_body_exited(body):
	#this triggers when the player leaves the tilemap collsiion area
	if body.is_in_group("Player"):#checks if it is the player
		doDamage = false#sets the doDamage to false
		Body=body
