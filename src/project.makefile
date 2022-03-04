
PROJECT_FILE := cobalt.json

vpath % $(PROJECT_CACHE_DIR)
vpath % $(PROJECT_ROOT_DIR)

cobalt: $(PROJECT_FILE)
	@bash "$(COBALT_BIN_DIR)/genmakefile.sh"

