class_name NodeLib extends Node
## Static helper methods for working with nodes.


## Call [method queue_free] on each child of [param node].
static func queue_free_children(node:Node):
	for child in node.get_children():
		child.queue_free()


## Same as [method free_node], but allows freeing the node by providing the parent node and name of 
## the child node to be freed.
static func free_node_name(parent:Object, node_name:String):
	if is_instance_valid(parent) and parent.has_node(node_name):
		var node = parent.get_node(node_name)
		free_node(node)


## Remove [param node] from its parent and free the node. This is intended to prevent errors
## occuring after `node.queue_free()` is called, but before the node is actually freed.
static func free_node(node:Node):
	if is_instance_valid(node):
		node.get_parent().remove_child(node)
		node.queue_free()


	## Look at the children of [param node] and return the first child found whose class type
	## matches [param class_name_].
static func get_first_child_of_type(node:Node, class_name_:String) -> Node:
	for child in node.get_children():
		if child.is_class(class_name_):
			return child
	return null


	## Look at the parent of [param node] and return the first parent found whose global name 
	## matches [param class_name_].
static func get_first_parent_of_type(node:Node, type:String) -> Node:
	## TODO: Match this functionality with get_first_child_of_type()
	var parent = null
	while node.get_path() != NodePath("/root"):
		node = node.get_parent()
		if node == null:
			break
		if not node.get_script():
			continue
		if node.get_script().get_global_name() == type:
			parent = node
			break
	return parent


## Get the value of a property from a tscn file.
static func get_value_from_tscn(tscn_path:String, property_name:String):
	var state:SceneState = load(tscn_path).get_state()
	for p in range(state.get_node_property_count(0)):
		if state.get_node_property_name(0, p) == property_name:
			return state.get_node_property_value(0, p)


## Unparent [param node] from its current parent and reparent it under [param new_parent].
static func reparent_node(node:Node, new_parent:Node) -> void:
	node.get_parent().remove_child(node)
	new_parent.add_child(node)
