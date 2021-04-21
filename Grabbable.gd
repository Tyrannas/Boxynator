extends RigidBody2D
class_name Grabbable

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var speed = 600

# Node when set, try to move toward this target 
var target
# side of the player the grab came from
# in the form of a dict
#{
#	"name": name of the side left / right / up / down
#	"direction": Vector2
#}
var side
# use to determine wether the collision with another ennemy should be considered as harmful for the ennemy
var is_projectile = false
signal hit

# Called when the node enters the scene tree for the first time.
func _ready():
	set_contact_monitor(true)
	set_max_contacts_reported(1)
	# on connecte le signal body_entered à la méthode on_collision with target
	connect("body_entered", self, "_on_collision_with_target")

func set_target(_node, player_side):
	target = _node
	side = player_side
	is_projectile = false

func release(direction):
	var scene = get_parent().get_parent()
	var pos = get_global_transform().origin
	get_parent().remove_child(self)
	scene.add_child(self)
	global_transform.origin = pos
	set_mode(RigidBody.MODE_RIGID)
	linear_velocity = direction
	side = null
	is_projectile = true
	
func _on_collision_with_target(node):
	# on fait ça parceque les modifications de physique dans un callback de collision ça plante
	# donc il faut faire en call_deferred
	self.call_deferred("_handle_collision", node)
		
func _handle_collision(node):
	# si le noeud qu'on collide c'est le joueur
	if node == target:
		# on enleve le noeud actuel de son parent (la scène)
		get_parent().remove_child(self)
		# on ajoute le noeud en tant que child du joueur
		target.add_child(self)
		# on calcul l'offset pour bien le positionner
		var offset = target.get_node("CollisionShape2D").shape.extents
		position = offset.x * 2 * side["direction"]
		rotation = 0
		target = null
		# on change le type de body pour pouvoir collider
		set_mode(RigidBody2D.MODE_KINEMATIC)
		# on appelle le parent pour réautoriser le hook
		get_parent().on_target_reached(side["name"])
		# on se met sur le layer de collision 3 pour ne plus collisioner avec le joueur
		set_collision_layer(4)
		# on met le masque de collision 2 pour collisioner uniquement avec les ennemis
		set_collision_mask(2)
	# a priori si autre collision c'est avec un autre ennemy
	else:
		if is_projectile:
			emit_signal("hit")
		
func _physics_process(delta):
	if target:
		var direction = (target.position - position).normalized()
		set_linear_velocity(direction*speed)
		update()
		
func _draw():
	if target:
		draw_line(Vector2(), target.position - position, Color(255, 0, 0))


