class_name DoublyLinkedList
extends Object

# Sub-class for DLL Nodes
class DLLNode:
	var next: DLLNode = null
	var prev: DLLNode = null
	var value: Variant

	func _init(_value):
		value = _value

var head: DLLNode = null
var tail: DLLNode = null
var array: Array[Variant]

func _init(_array: Array):
	for value in _array:
		insert(value)
	update_array()
	
## Insert a new node with specified value to the end of the list. Should probably be called append
func insert(_value: Variant) -> void:
	var new_node: DLLNode = DLLNode.new(_value)
	if head:
		var curr = head
		while curr.next:
			curr = curr.next
		curr.next = new_node
		tail = new_node
		tail.prev = curr

	else:
		head = DLLNode.new(_value)
		tail = new_node
	update_array()

func switch_right() -> void:
	# Make list circular
	tail.next = head
	head.prev = tail

	# Rotate 1 right
	head = head.next
	tail = tail.next

	# Break circular connection
	tail.next = null
	head.prev = null
	update_array()

func switch_left() -> void:
	# Make list circular
	tail.next = head
	head.prev = tail

	# Rotate 1 left
	head = head.prev
	tail = tail.prev

	# Break circular connection
	tail.next = null
	head.prev = null
	update_array()
	
func update_array() -> void:
	array = []
	var curr = head
	while curr:
		array.append(curr.value)
		curr = curr.next

## Set the first instance of _value to be head. If the value does not exist in the linked list, do nothing except push an error.
func set_value_as_head(target_value: Variant) -> void:
	var curr: DLLNode = head
	var distance_from_head: int = 0
	while curr != tail: # Iterate through full list
		print("LOoping!")
		if curr.value == target_value:
			break
		curr = curr.next
		distance_from_head += 1

	for i in range(distance_from_head):
		switch_right()

	# push_error("Target value '", target_value, "' not found in DoublyLinkedList")

func print_list() -> void:
	pass
	#print("[", head.value.perk_data.perk_name, ", ", head.next.value.perk_data.perk_name, ", ", head.next.next.value.perk_data.perk_name, "]")
	# var curr = head
	# while curr:
	# 	curr = curr.next
