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
	_test_dictionary()
	_test_literal()

func _test_dictionary() -> void:
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


func _test_literal() -> void:
	var number_two := Prav.literal(2)
	var result := number_two.parse(1)
	# False, same type but different values
	prints(result.ok, result.value)
	result = number_two.parse("Hello")
	# False, different types
	prints(result.ok, result.value)
	result = number_two.parse(2)
	# True, integer 2
	prints(result.ok, Schema.typeof(result.value), result.value)
	
	var one_two_three := Prav.literal([1, 2, 3])
	# { ok: false } type error, these are floats not integers
	prints(one_two_three.parse([1.0, 2.0, 3.0]))
	# { ok: false } array mismatch, lengths are not the same
	prints(one_two_three.parse([3, 4]))
	# { ok: true } same length and same values
	prints(one_two_three.parse([1, 2, 3]))
	
	var alts := Prav.literal({ "foo": 0, "bar": -1, "baz": "bbb" })\
					.alt(Prav.literal(69))
	
	# { ok: false } "foo" is wrong
	prints(alts.parse({ "foo": 1, "bar": -1, "baz": "bbb" }))
	# { ok: false } "bar" is wrong
	prints(alts.parse({ "foo": 0, "bar": 0, "baz": "bbb" }))
	# { ok: false } "baz" is wrong
	prints(alts.parse({ "foo": 0, "bar": -1, "baz": "aaa" }))
	# { ok: true } alternative schema allows literal 69
	prints(alts.parse(69))
	
	prints(alts)
