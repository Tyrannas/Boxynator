extends KinematicBody2D


# Declare member variables here. Examples:
export var speed = 400
export var hook_size = 500

var screen_size
var casted = false
var hookeds = {
	"right": false,
	"left": false,
	"up": false,
	"down": false
}
var hooked = false
var timer
# var a = 2
# var b = "text"


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
	if Input.is_action_pressed("ui_accept"):
		if hooked == false:
			$RayCast2D.cast_to = Vector2(hook_size, 0)
			var res = $RayCast2D.get_collider()
			if res:
				print(res)
				res.set_target(self)
				hooked = true
				hookeds["right"] = res
			casted = true
			update()
#		elif $Right != null:
#			# if an object is hooked
#			# save pos
#			var obj = $Right
#			var pos = obj.get_global_transform().origin
#			remove_child(obj)
#			# free the child
#			get_parent().add_child(obj)
#			obj.global_transform.origin = pos
#			obj.move_away()
#			# create a time to allow grabbing only after 0.5s
#			timer = Timer.new()
#			timer.connect("timeout", self, "_on_timeout")
#			timer.wait_time = 0.5
#			add_child(timer)
#			timer.start()
			
	if Input.is_action_just_released("ui_accept"):
		casted = false
		update()
		
func _process(delta):
	_process_move(delta)
	_process_hook()

func _on_timeout():
	print("hello")
	hooked = false
	timer.stop()
	
func _draw():
	if casted:
		draw_line(Vector2(), Vector2(hook_size, 0), Color(0, 255, 0))
		


