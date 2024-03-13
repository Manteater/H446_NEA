extends Resource
class_name Character

export var speed := 1000
export var dashSpeed := 1000
export var health: int

export var level := 3
export var xp := 20
export var xpPoints := 20
export var maxHealth := 100
export var xpNeeded = 100
export var money = 40

export var bulletSpeed = 1000#the speed that the bullet will travel at
export var cooldown = 5#this is the cooldown in between shots
export var bulletLifetime = 200#this tracks how long the bullets are alive for
export var bulletBounces = 3
export var bulletAmount = 3
export var bulletDamage = 10

