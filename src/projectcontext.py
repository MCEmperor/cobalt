import platform
from pathlib import Path

class ProjectContext:

	def __init__(self, root_path: Path):
		self.root_path = root_path
		self.project_name = ""
		self.package = {
			'name': "default-project",
			'version': "1"
		}

	def resolve_package_filename(self):
		"""
		Extract the name and version of the packaging info from the project file, and returns a string containing the
		filename of the package to be created when packaging the project.

		:return A string containing the filename.
		"""
		name = self.package.get('name')
		version = self.package.get('version')
		return name + "-" + version + ".acu"


	def get_compiler_options(self, filename: str):
		return self.compiler_options.get(filename, self.default_compiler_options)
