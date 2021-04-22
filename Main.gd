extends Node2D

var ennemy = preload('res://Ennemy.tscn')
var player_class = preload('res://Player.tscn')

var player
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var screen_size
var game_time = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	screen_size = get_viewport_rect().size
	player = player_class.instance()
	add_child(player)
	player.position = screen_size / Vector2(2,2)
	$UserInterface/PlayerLives.text = "Lives: %s" % player.lives
	player.connect("player_hit", $UserInterface/PlayerLives, "_on_player_hit")
	player.connect("game_over", self, "_on_game_over")
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_game_over():
	$UserInterface/ScoreLabel._on_game_over()
	$UserInterface/GameOver.show()
	$MobTimer.stop()
	
func _on_MobTimer_timeout():
	# Choose a random location on Path2D.
	$MobPath/MobSpawnLocation.offset = randi()
	# Create a Mob instance and add it to the scene.
	var mob = ennemy.instance()
	add_child(mob)
	# Set the mob's direction perpendicular to the path direction.
	# Set the mob's position to a random location.
	mob.position = $MobPath/MobSpawnLocation.position
	
	var direction = mob.position.direction_to(player.position)
	# Set the velocity (speed & direction).
	var mob_speed = rand_range(mob.min_speed, mob.max_speed)
	mob.linear_velocity = direction * Vector2(mob_speed, mob_speed)
	mob.connect("hit", $UserInterface/ScoreLabel, "_on_mob_hit")
	player.connect("game_over", mob, "queue_free")


func _on_GameDuration_timeout():
	game_time += 1
	$MobTimer.set_wait_time(3 - log(game_time))
