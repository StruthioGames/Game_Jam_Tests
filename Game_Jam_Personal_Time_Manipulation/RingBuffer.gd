class_name RingBuffer

var buffer = []
var capacity
var current_index = 0
var count = 0

func _init(size):
	capacity = size
	buffer.resize(size)

func add_item(item):
	buffer[current_index] = item
	current_index = (current_index + 1) % capacity
	if count < capacity:
		count += 1

func pop_last():
	if count == 0:
		return null
	current_index = (current_index - 1 + capacity) % capacity
	count -= 1
	return buffer[current_index]

func size():
	return count
