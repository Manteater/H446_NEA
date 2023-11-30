extends Sprite

onready var player = get_parent()
var bullet = preload("res://Source/Weapons/PlayerBullet.tscn")

var reloadTimer = 0#this is the timer that tracks when the cooldown is over
var projectiles = []#the array to store all of the bullets
var angles = [0,0.1,-0.1,0.2,-0.2,0.4,-0.3,0.4,-0.4]
onready var stats = Global.characterSave

func _ready():
	set_as_toplevel(true)
	#print(player.stats)
	
func _physics_process(delta: float)-> void:
	reloadTimer+=1
	position.x = lerp(position.x,get_parent().position.x,0.5)#adjusts the position of the gun to stay with the parent
	position.y = lerp(position.y,get_parent().position.y+10,0.5)
	var mouse = get_global_mouse_position()
	look_at(mouse)# makes the gun look towards the cursor
	animate(mouse)
	for i in projectiles:#loop through the array
		var p = i["projectile"]#the bullet object is stored in the variable p
		var velocity = i["velocity"]
		if i["ticks"] >= stats.bulletLifetime:#checks if the game has ticked more than the bulletlifetime
			p.get_node("AnimationPlayer").play("Collide")
			projectiles.erase(i)#the infromation is erased from the array
		var collision = p.move_and_collide(velocity*delta)#an in-built function is used to make the bullet move
		
		if (collision):
			#print("collided")
			var collider = collision.collider
			#print(collider.get_class())
			if (collider.is_in_group("enemy")):
				#print("hit")
				collider.applyDamage(stats.bulletDamage)
				p.get_node("AnimationPlayer").play("Collide")
				projectiles.erase(i)#the infromation is erased from the array
			elif i["bounces"]>0:
				i["velocity"] = velocity.bounce(collision.normal)#new velocity is set
				i["bounces"]-=1
			else:
				p.get_node("Sprite").offset.x = -25
				p.get_node("AnimationPlayer").play("Collide")#plays the collsion animation
				#p.queue_free()#the projectile is destroyed
				projectiles.erase(i)#the infromation is erased from the array
		
		i["ticks"]+=1#ticks are incremented


func animate(mouse):
	if get_parent().global_position.x > mouse.x:#this stops the gun from being the wrong way around when shooting in the other direction
		flip_v = true
	else:
		flip_v = false
	
func fire():
	if reloadTimer < stats.cooldown: return#this makes sure the gun can only shoot when the cooldown is over
	else: reloadTimer = 0
	var bulletsLeft = stats.bulletAmount#tracks how many bullets there are left to fire
	var bulletNum = 0#tracks which bullet is being fired
	while bulletsLeft > 0:#while there are still bullets left to be shot
		bulletsLeft-=1
		var angle = angles[bulletNum]#chosses the angle from the angles stored in the array
		bulletNum+=1
		var velocity = Vector2.ZERO
		var projectile = bullet.instance()#creates an instance of the bullet scene
		projectile.add_collision_exception_with(get_parent())#prevents the bullet from colliding with the parent
		projectile.rotation=rotation+angle#rotates the bullet to face the same way as the gun and taking into account the spread.
		projectile.global_position = $Muzzle.global_position#the bullet is moved to the position of the muzzle
		get_node("/root").add_child(projectile)#the bullet is set as the child of the parent node
		velocity = Vector2(stats.bulletSpeed,0).rotated(projectile.rotation)#the bullet is set to move at a certain speed
		projectiles.append({"projectile":projectile,"velocity":velocity,"ticks":0,"bounces":stats.bulletBounces})#the information about the bullet is stored in the array as a dictionary
	
	
	
