extends TextureButton
class_name SkillNode

onready var label = $Label
onready var line = $Line2D
var active = false
export var upgradeType:= ""#this will determine what part of the player is being upgraded
export var upgradeValue:= 0#this will determine how much this will be upgraded by
export var upgradeCost= 1

func _ready():
	var position = rect_global_position
	var size = rect_size
#	if get_parent().is_in_group("skillNodes"):#if it has a skillNode parent
#		line.add_point(position+size/2)#points at the centreof itself and it parent are added to the line which is automatically drawn
#		line.add_point(get_parent().rect_global_position+size/2)
#		line.set_as_toplevel(true)

func _on_TextureButton_pressed():
	if upgradeCost <= Global.characterSave.xpPoints:
		active = true
	if active:
		$Panel.show_behind_parent = true#this will make the button change color
		line.default_color = Color(1,1,0.25)#this will make the line yellow
		var skills = get_children()
		for skill in skills:
			if skill.is_in_group("skillNodes") and active:
				#if a child is a skillNode and the button is active then the child will be clickable
				skill.disabled = false
			match upgradeType:
				"speed": Global.characterSave.speed += upgradeValue
				"maxHealth": Global.characterSave.maxHealth += upgradeValue
				"bulletDamage": Global.characterSave.bulletDamage += upgradeValue
				"bulletSpeed": Global.characterSave.bulletSpeed += upgradeValue
				"bulletAmount": Global.characterSave.bulletAmount += upgradeValue
				
