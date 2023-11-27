extends Resource
class_name Character

export var speed := 300
export var dashSpeed := 1000

export var level := 1
export var xp := 0
export var maxHealth := 100

export var bulletSpeed = 1000#the speed that the bullet will travel at
export var cooldown = 10#this is the cooldown in between shots
export var bulletLifetime = 200#this tracks how long the bullets are alive for
export var bulletBounces = 2
export var bulletAmount = 1
export var bulletDamage = 10
