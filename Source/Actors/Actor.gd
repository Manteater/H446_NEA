extends KinematicBody2D
class_name Actor

export var health : int = 100
export var speed : int = 200
var dead = false

func applyDamage(amount):
	print(health)
	health-=amount
	if health < 0:
		dead = true
		

	

