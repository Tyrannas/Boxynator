extends KinematicBody2D


# Declare member variables here. Examples:
export var speed = 400
export var hook_size = 500
export var repell_speed = 2000

var screen_size
var casted = false
var hook_dir = null

var hookeds = {
	"right": {
		"hookable": true,
		"hooked": false,
		"direction": Vector2.RIGHT,
		"timer": null
	},
	"left": {
		"hookable": true,
		"hooked": false,
		"direction": Vector2.LEFT,
		"timer": null
	},
	"up": {
		"hookable": true,
		"hooked": false,
		"direction": Vector2.UP,
		"timer": null
	},
	"down": {
		"hookable": true,
		"hooked": false,
		"direction": Vector2.DOWN,
		"timer": null
	}
}

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size

func _process_move(delta):
	var velocity = Vector2()
	if Input.is_action_pressed("ui_down"):
		velocity.y += 1
	if Input.is_action_pressed("ui_left"):
		velocity.x -= 1
	if Input.is_action_pressed("ui_up"):
		velocity.y -= 1
	if Input.is_action_pressed("ui_right"):
		velocity.x += 1
	
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		
	position += velocity * delta
	position.x = clamp(position.x, 0, screen_size.x)
	position.y = clamp(position.y, 0, screen_size.y)
	
func _process_hook():
	if Input.is_action_pressed("ui_shoot_left"):
		hook_dir = "left"
		_handle_hook("left")
	
	if Input.is_action_pressed("ui_shoot_right"):
		hook_dir = "right"
		_handle_hook("right")
	
	if Input.is_action_pressed("ui_shoot_up"):
		hook_dir = "up"
		_handle_hook("up")
	
	if Input.is_action_pressed("ui_shoot_down"):
		hook_dir = "down"
		_handle_hook("down")
			
	if Input.is_action_just_released("ui_shoot_left") or Input.is_action_just_released("ui_shoot_right") or Input.is_action_just_released("ui_shoot_up") or Input.is_action_just_released("ui_shoot_down"):
		casted = false
		hook_dir = null
		update()
		
func _handle_hook(direction):
	var target = hookeds[direction]
	# si on peut grabber à droite, et qu'on a rien grabé
	if target["hookable"] == true and not target["hooked"]:
		$RayCast2D.cast_to = hook_size * target["direction"]
		var res = $RayCast2D.get_collider()
		if res:
			print(res)
			res.set_target(self, {"name": direction, "direction": target["direction"]})
			target["hookable"] = false
			target["hooked"] = res
			$RayCast2D.add_exception(res)
		casted = true
		update()
	# si on peut grabber à droite et que l'on a un item grabbé
	elif target["hookable"] == true and target["hooked"]:
		target["hooked"].release(repell_speed * target["direction"])
		$RayCast2D.remove_exception(target["hooked"])
		target["hooked"] = false
		target["hookable"] = false
		var timer = Timer.new()
		timer.connect("timeout", self, "_on_timeout", [direction])
		timer.wait_time = 0.5
		add_child(timer)
		timer.start()
		target["timer"] = timer
			
			
func _process(delta):
	_process_move(delta)
	_process_hook()

# check when the hooked object arrives and allow to reactivate to release
func on_target_reached(direction):
	hookeds[direction]["hookable"] = true

# use a timer to prevent grabbing instantly a released object
func _on_timeout(direction):
	hookeds[direction]["hookable"] = true
	hookeds[direction]["timer"].stop()

# draw a line for the raycast
func _draw():
	if casted and hook_dir:
		draw_line(Vector2(), hook_size * hookeds[hook_dir]["direction"], Color(0, 255, 0))
		


