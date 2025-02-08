extends MeshInstance3D


func _on_spherical_lamp_turned_off() -> void:
	get_mesh().surface_get_material(0).emission_enabled = false
	


func _on_spherical_lamp_turned_on() -> void:
	get_mesh().surface_get_material(0).emission_enabled = true
	
