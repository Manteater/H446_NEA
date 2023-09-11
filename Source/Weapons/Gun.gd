extends Sprite

onready var player = get_parent()
var bullet = preload("res://Source/Weapons/PlayerBullet.tscn")

export var bulletSpeed = 1000#the speed that the bullet will travel at
export var cooldown = 25#this is the cooldown in between shots
export var bulletLifetime = 50#this tracks how long the bullets are alive for
var reloadTimer = 0#this is the timer that tracks when the cooldown is over
var projectiles = []#the array to store all of the bullets


func _ready():
	set_as_toplevel(true)
	
func _physics_process(delta: float)-> void:
	reloadTimer+=1
	position.x = lerp(position.x,get_parent().position.x,0.5)#adjusts the position of the gun to stay with the parent
	position.y = lerp(position.y,get_parent().position.y+10,0.5)
	var mouse = get_global_mouse_position()
	look_at(mouse)# makes the gun look towards the cursor
	animate(mouse)
	for i in projectiles:#loop through the array
		var p = i["projectile"]#the bullet object is stored in the variable p
		if i["ticks"] >= bulletLifetime:#checks if the game has ticked more than the bulletlifetime
			p.queue_free()#the projectile is destroyed
			projectiles.erase(i)#the infromation is erased from the array
		var collision = p.move_and_collide(i["velocity"]*delta)#an in-built function is used to make the bullet move
		
		if (collision):
			print("collided")
			var collider = collision.collider
			print(collider.get_class())
			if (collider.get_class()=="Enemy"):
				print("hit")
				collider.applyDamage(50)
			p.queue_free()#the projectile is destroyed
			projectiles.erase(i)#the infromation is erased from the array
		
		i["ticks"]+=1#ticks are incremented



func animate(mouse):
	if get_parent().global_position.x > mouse.x:#this stops the gun from being the wrong way around when shooting in the other direction
		flip_v = true
	else:
		flip_v = false
	
func fire():
	if reloadTimer < cooldown: return#this makes sure the gun can only shoot when the cooldown is over
	else: reloadTimer = 0
	var velocity = Vector2.ZERO
	var projectile = bullet.instance()#creates an instance of the bullet scene
	projectile.add_collision_exception_with(get_parent())#prevents the bullet from colliding with the parent
	projectile.rotation=rotation#rotates the bullet to face the same way as the gun
	projectile.global_position = $Muzzle.global_position#the bullet is moved to the position of the muzzle
	get_node("/root").add_child(projectile)#the bullet is set as the child of the parent node
	velocity = Vector2(bulletSpeed,0).rotated(projectile.rotation)#the bullet is set to move at a certain speed
	projectiles.append({"projectile":projectile,"velocity":velocity,"ticks":0})#the information about the bullet is stored in the array as a dictionary
	
	
	
