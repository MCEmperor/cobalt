import os
import sys
from makefilewriter import MakefileWriter
from pathlib import Path
from pathlib import WindowsPath
from projectcontext import ProjectContext
from projectreader import ProjectReader

# The dir with binaries
bin_dir = Path(sys.argv[1])
# Cache dir
cache_dir = Path(sys.argv[2])
# The root path of the project
root_path = Path(sys.argv[3])

project_context = ProjectReader(root_path).read()

# Read file
makefile_writer = MakefileWriter(bin_dir, cache_dir, project_context)
makefile_writer.write()
