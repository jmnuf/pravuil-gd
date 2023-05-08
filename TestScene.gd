extends Node2D

var schema := Prav.dict({
	"name": Prav.string(),
	"age": Prav.int(),
	"addr": Prav.dict({
		"number": Prav.int(),
		"street": Prav.string(),
	})
}, true)

func _ready() -> void:
	var result := schema.parse({
		"name": "John",
		"age": 23,
		"addr": {
			"number": 14,
			"street": "Maystreet",
			"number2": 36,
			"street2": "Maple",
		},
	})
	
	# True, with all the data passed
	prints(result.ok, result.value)
	
	result = schema.parse(23)
	
	# False, error message
	prints(result.ok, result.value)
