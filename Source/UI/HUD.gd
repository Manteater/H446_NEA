extends Control

onready var tree = get_tree()#this is the parent scene
onready var pauseOverlay = $PauseOverlay#fetches the pauseoverlay node
var paused := false setget setPaused#this calls the setPuased function everytime it is changed
onready var healthbar = $healthBar
onready var expBar = $xpBar
onready var playerStats = Global.characterSave
onready var xpLvl = $xpLvl
onready var xpPoints = $xpPoints

func _ready():
	healthbar.max_value = playerStats.maxHealth
	healthbar.value = playerStats.maxHealth
	


func _physics_process(_delta):
	playerStats = Global.characterSave
	healthbar.value = playerStats.health
	expBar.value = playerStats.xp
	xpLvl.text = "Lvl: "+ String(playerStats.level)
	xpPoints.text = "Pts: "+String(playerStats.xpPoints)
	if playerStats.xp == playerStats.xpNeeded:
		Global.characterSave.level += 1
		Global.characterSave.xpNeeded = Global.characterSave.level*10 +100
		Global.characterSave.xp = 0

func setPaused(value):
	#makes everything paused and causes the pause overly to be visible
	paused = value
	tree.paused = value
	pauseOverlay.visible = value

func toggleSkillTree():
	$skillTree.visible = true
	tree.paused = true

func _unhandled_input(event):#triggers when a button is pressed
	if event.is_action_pressed("escape"):#if that button is the escape key the game is paused
		self.paused = not paused
		tree.set_input_as_handled()

func _on_ContinueButton_button_up():#if the continue button is pressed the game is unpaused again
	self.paused = not paused
	tree.set_input_as_handled()


func _on_button_button_up():
	$saveGamesMenu.visible = true
