extends KinematicBody2D
class_name Enemy


var health : int = 100
var speed : int = 200


func applyDamage(amount):
	health-=amount
	if health < 0:
		queue_free() 

