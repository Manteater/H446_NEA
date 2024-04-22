extends TextureButton
class_name SkillNode

onready var line = $Line2D
var active = false
export var upgrade: Resource

func _ready():
	#var position = rect_global_position#position of the button
	#var size = rect_size#size of the button
	#if get_parent().is_in_group("skillNodes"):#if it has a skillNode parent
		#line.add_point(position+size/2)#points at the centreof itself and it parent are added to the line which is automatically drawn
		#line.add_point(get_parent().rect_global_position+size/2)
		#line.set_as_toplevel(true)
		#line.visible = false
	$Cost.text = "Cost: "+str(upgrade.upgradeCost)#sets the cost equal to the upgradeCost
	$Name.text = upgrade.upgradeName#displays the name of the upgrade




func _on_TextureButton_pressed():
	print(upgrade.upgradeValue)
	if not active:#if the button has not been clicked before, this ensures it can obly be clicked once to get the upgrade
		if upgrade.upgradeCost <= Global.characterSave.xpPoints:#if the player can afford the upgrade
			Global.characterSave.xpPoints -= upgrade.upgradeCost#reduces xp points available to the player
			active = true#sets active to true so the button cant be pressed again
		if active:
			$Panel.show_behind_parent = true#this will make the button change color
			line.default_color = Color(1,1,0.25)#this will make the line yellow
			var skills = get_children()#fetches all the child nodes
			for skill in skills:
				if skill.is_in_group("skillNodes") and active:#if a child node is a skillNode
					#if a child is a skillNode and the button is active then the child will be clickable
					skill.disabled = false#the child is no longer disabled
			match upgrade.upgradeType:#applies the effect of the upgrade to the character script.
				"speed": Global.characterSave.speed += upgrade.upgradeValue
				"maxHealth": Global.characterSave.maxHealth += upgrade.upgradeValue
				"bulletDamage": Global.characterSave.bulletDamage += upgrade.upgradeValue
				"bulletSpeed": Global.characterSave.bulletSpeed += upgrade.upgradeValue
				"bulletAmount": Global.characterSave.bulletAmount += upgrade.upgradeValue
				"cooldown":Global.characterSave.cooldown= (Global.characterSave.cooldown*upgrade.upgradeValue)
				
