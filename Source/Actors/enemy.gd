class_name Enemy
extends KinematicBody2D



var health : int = 100
var speed : int = 200


func applyDamage(amount):
	print(health)
	health-=amount
	if health < 0:
		queue_free() 

