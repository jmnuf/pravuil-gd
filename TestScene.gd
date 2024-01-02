extends Node2D

var schema := Prav.dict({
	"name": Prav.string(),
	"age": Prav.int(),
	"addr": Prav.dict({
		"number": Prav.int(),
		"street": Prav.string(),
	})
}, true)

var number_two := Prav.literal(2)

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
	
	result = number_two.parse(1)
	
	# False, same type but different values
	prints(result.ok, result.value)
	
	result = number_two.parse("Hello")
	
	# False, different types
	prints(result.ok, result.value)
	
	result = number_two.parse(2)
	
	# True, integer 2
	prints(result.ok, Schema.TYPES[typeof(result.value)], result.value)
