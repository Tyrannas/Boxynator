extends Grabbable


export var min_speed = 100  # Minimum speed range.
export var max_speed = 200  # Maximum speed range.

var screen_size
var can_be_delete = false

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# check global position to see if needs to be delete cause out of screen
	if can_be_delete:
		var pos = get_global_transform().origin
		var size = $CollisionShape2D.shape.extents + Vector2(50, 50)
		if pos.x > screen_size.x + size.x or pos.x < -size.x or pos.y > screen_size.y + size.y or pos.y < -size.x:
			queue_free()
		
# use a timer to prevent deleting an ennemy that pops out of screen
func _on_Timer_timeout():
	can_be_delete = true
