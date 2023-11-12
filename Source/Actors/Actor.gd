extends KinematicBody2D
class_name Actor

export var health : int = 100
export var speed : int = 200


func applyDamage(amount):
	print(health)
	health-=amount
	if health < 0:
		queue_free() 

