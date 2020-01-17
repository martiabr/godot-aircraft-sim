extends Spatial

export var period = 60  # period of first octave of noise 
export var octaves = 5  # how many octaves of noise we add together
export var persistence = 0.4  # the multiplier between each octave 
export var lacunarity = 2.0  # the increase in frequency between each octave
export var amplitude = 140  # maximum noise value

var noise

func _ready():
	randomize()
	
	generate_map()

func generate_map():
	noise = OpenSimplexNoise.new()
	noise.seed = randi()
	noise.period = period
	noise.octaves = octaves
	noise.persistence = persistence
	noise.lacunarity = lacunarity
	
	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = Vector2(400, 400)
	plane_mesh.subdivide_depth = 400
	plane_mesh.subdivide_width = 400
	
	var surface_tool = SurfaceTool.new()
	surface_tool.create_from(plane_mesh, 0)
	
	var array_plane = surface_tool.commit()
	
	var data_tool = MeshDataTool.new()
	data_tool.create_from_surface(array_plane, 0)
	
	for i in range(data_tool.get_vertex_count()):
		var vertex = data_tool.get_vertex(i)
		vertex.y = noise.get_noise_3d(vertex.x, vertex.y, vertex.z) * amplitude
		data_tool.set_vertex(i, vertex)
#
	for i in range(array_plane.get_surface_count()):
		array_plane.surface_remove(i)
#
	data_tool.commit_to_surface(array_plane)
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface_tool.create_from(array_plane, 0)
	surface_tool.generate_normals()
#
	var mesh_instance = MeshInstance.new()
	mesh_instance.mesh = surface_tool.commit()
	mesh_instance.set_surface_material(0, load("res://assets/shader.material"))
	mesh_instance.create_trimesh_collision()
	add_child(mesh_instance)
	


