extends Area2D

export var scene: PackedScene

func _on_Teleporter_body_entered(body):
	if body.is_in_group("Player"):
		get_tree().change_scene_to(scene)
