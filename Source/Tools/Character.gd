extends Resource
class_name Character

export var speed := 400
export var dashSpeed := 1500
export var health: int

export var level := 3
export var xp := 20
export var xpPoints := 20
export var maxHealth := 100
export var xpNeeded = 100
export var money = 40

export var bulletSpeed = 500#the speed that the bullet will travel at
export var cooldown = 30#this is the cooldown in between shots
export var bulletLifetime = 200#this tracks how long the bullets are alive for
export var bulletBounces = 0
export var bulletAmount = 1
export var bulletDamage = 10

