class_name EnumHelper


func random_value_from(_enum) -> Variant:
	return _enum.keys()[randi() % _enum.size()]
