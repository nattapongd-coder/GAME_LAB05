extends Node

@export var mob_scene: PackedScene


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accepts") and $UserInterface/ColorRect.visible:
		get_tree().reload_current_scene()

func _on_timer_mob_timeout() -> void:
		# Create a new instance of the Mob scene.
	var mob = mob_scene.instantiate()

	# Choose a random location on the SpawnPath.
	# We store the reference to the SpawnLocation node.
	var mob_spawn_location = get_node("Spawnpath/Pathlocation")
	# And give it a random offset.
	mob_spawn_location.progress_ratio = randf()

	var player_position = $Player.position
	mob.initialize(mob_spawn_location.position, player_position)
	mob.squashed.connect($UserInterface/Score._on_Mob_sqashed.bind())
	
	add_child(mob)
	


func _on_player_hit() -> void:
	$"Timer mob".stop()
	$UserInterface/ColorRect.show()
