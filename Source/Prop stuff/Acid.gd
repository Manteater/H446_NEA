extends Area2D

export var damage = 10
var doDamage = false#stores wether it is possible to apply damage to the body



func _on_Acid_body_entered(body):
	doDamage = true
	#this triggers when the player enters the tilemap collison area
	if body.is_in_group("Player"):#checks if it is the player
		while doDamage:#while the player is in the acid they take damage
			body.applyDamage(damage)
			yield(get_tree().create_timer(0.35), "timeout")#the script is paused for 0.35s


func _on_Acid_body_exited(body):
	#this triggers when the player leaves the tilemap collsiion area
	if body.is_in_group("Player"):#checks if it is the player
		doDamage = false#sets the doDamage to false

