class_name DoublyLinkedList
extends Object

# TODO: Convert this from generic dll to spell data one? 

# Sub-class for DLL Nodes
class DLLNode:
	var next: DLLNode = null
	var prev: DLLNode = null
	var value: Variant

	func _init(_value):
		value = _value

var head: DLLNode = null
var tail: DLLNode = null
var array: Array[SpellData]

func _init(_array: Array):
	for value in _array:
		insert(value)
	update_array()
	
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

func switch_left() -> void:
	# Make list circular
	tail.next = head
	head.prev = tail

	# Rotate 1 keft
	head = head.next
	tail = tail.next

	# Break circular connection
	tail.next = null
	head.prev = null
	update_array()

func switch_right() -> void:
	# Make list circular
	tail.next = head
	head.prev = tail

	# Rotate 1 right
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

func print_list() -> void:
	var curr = head
	while curr:
		curr = curr.next
