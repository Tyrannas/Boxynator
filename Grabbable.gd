extends RigidBody2D
class_name Grabbable

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var speed = 600

# Node when set, try to move toward this target 
var target

# Called when the node enters the scene tree for the first time.
func _ready():
	set_contact_monitor(true)
	set_max_contacts_reported(1)
	# on connecte le signal body_entered à la méthode on_collision with target
	connect("body_entered", self, "_on_collision_with_target")

func set_target(_node):
	target = _node

func _on_collision_with_target(node):
	# si le noeud qu'on collide c'est le joueur
	if node == target:
		# on enleve le noeud actuel de son parent (la scène)
		get_parent().remove_child(self)
		# on ajoute le noeud en tant que child du joueur
		target.add_child(self)
		# on calcul l'offset pour bien le positionner
		var offset = target.get_node("CollisionShape2D").shape.extents
		position = Vector2(offset.x * 2, 0)
		target = null
		# on change le type de body pour pouvoir collider
		set_mode(RigidBody2D.MODE_KINEMATIC)
		
func _physics_process(delta):
	if target:
		var direction = (target.position - position).normalized()
		set_linear_velocity(direction*speed)
		update()
		
func _draw():
	if target:
		draw_line(Vector2(), target.position - position, Color(255, 0, 0))


