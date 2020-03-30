import sys
from pathlib import Path
from projectcontext import ProjectContext

class MakefileWriter:

	def __init__(self, bin_path: Path, cache_dir: Path, project_context: ProjectContext):
		self.bin_path = bin_path
		self.cache_dir = cache_dir
		self.project_context = project_context

		profiles = []
		for compile_profile in self.project_context.compile_profiles:
			profiles.append(" ".join(compile_profile['include']) + ": COMPILE_OPTIONS = " + compile_profile['options'])
		self.makefile_compile_profiles = "\n".join(profiles)

	def write(self):
		makefile_path = self.bin_path.joinpath("sources.makefile")
		out_makefile_path = self.cache_dir.joinpath("cobalt")
		with open(str(makefile_path), 'r') as makefile:
			with open(str(out_makefile_path), 'a') as out_makefile:
				for line in makefile:
					out_makefile.write(self._translate_line(line))

	def _translate_line(self, line: str) -> str:
		package_filename = self.project_context.package['filename']
		default_compile_options = self.project_context.default_compiler_options
		line = line.replace('{{packageFilename}}', package_filename)
		line = line.replace('{{compileOptions}}', default_compile_options)

		line = line.replace('{{profiledCompileOptions}}', self.makefile_compile_profiles)
		return line
