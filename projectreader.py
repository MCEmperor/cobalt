import hashlib
import json
from pathlib import Path
from projectcontext import ProjectContext

class ProjectReader:

	def __init__(self, root_dir: Path):
		self.root_dir = root_dir

	def read(self) -> ProjectContext:
		"""
		Read the Cobalt project from the current directory.

		This function searches for the 'cobalt.json' project file, and if found, builds a ProjectContext object,
		containing all project properties.

		:return A ProjectContext instance.
		"""
		cobalt_project_file = self.root_dir.joinpath("cobalt.json")
		project_md5_checksum = self.md5(cobalt_project_file)
		with open(str(cobalt_project_file), 'r') as project_file:
			cobalt = json.load(project_file)

			project_context = ProjectContext(self.root_dir)
			project_context.checksum = project_md5_checksum
			project_context.project_name = cobalt.get('projectName', self.root_dir.stem)

			compile_node = cobalt.get('compile', {})

			project_context.default_compiler_options = compile_node.get('options', "")

			# Get the compile profiles
			compile_profiles = []
			for profile_node in compile_node.get('profiles', {}):
				compile_profile_options = profile_node.get('options', "")
				compile_profile_include = profile_node.get('include', [])
				include_entries = []
				for include_entry in compile_profile_include:
					include_entries.append(include_entry + ".acu")
				compile_profiles.append({
					'options': compile_profile_options,
					'include': include_entries
				})
			project_context.compile_profiles = compile_profiles

			# Get the package contents defined in the project file
			project_file_package = cobalt.get('package', {})
			package = {
				"filename": project_file_package.get('filename', self.root_dir.stem),
				"name": project_file_package.get('name', self.root_dir.stem),
				"version": project_file_package.get('version', "1")
			}
			dependencies = cobalt.get('dependencies', {})
			project_context.package = package
			project_context.dependencies = dependencies

		return project_context

	def md5(self, file : Path):
		hash_md5 = hashlib.md5()
		with open(str(file), "rb") as f:
			for chunk in iter(lambda: f.read(4096), b""):
				hash_md5.update(chunk)
		return hash_md5.hexdigest()
