
TARGET_DIR := target
SOURCE_DIR := src/main/cobol
COPYBOOK_DIR := src/main/cobol/copybook
COPYBOOK_DEPENDENCY_DIR := $(TARGET_DIR)/copybook-dependencies
OBJECT_DIR := $(TARGET_DIR)/objects

LSOURCES := $(wildcard $(SOURCE_DIR)/*.cbl)
LOBJECTS := $(notdir $(LSOURCES:.cbl=.acu))
USOURCES := $(wildcard $(SOURCE_DIR)/*.CBL)
UOBJECTS := $(notdir $(USOURCES:.CBL=.acu))

COMPILE_OPTIONS := -x -w -Cr -D1 -Di -Dz -Zz -Zl -Z91 -Sr -Vc

# Detect compiler
ifeq ($(OS),Windows_NT)
	COMPILER := ccbl32
	CBLUTIL := cblutl32
else
	COMPILER := ccbl
	CBLUTIL := cblutil
endif
vpath %.acu $(OBJECT_DIR)
vpath %.cbl $(SOURCE_DIR)
vpath %.CBL $(SOURCE_DIR)
vpath %.d $(COPYBOOK_DEPENDENCY_DIR)
vpath % $(COPYBOOK_DIR)

# Interpret the following targets as non-files
.PHONY: compile package clean

compile: $(LOBJECTS) $(UOBJECTS)

package: compile
	@echo Building package {{packageFilename}}
	@$(CBLUTIL) -lib -o "$(TARGET_DIR)/{{packageFilename}}.acu" $(OBJECT_DIR)/*.acu

clean:
	@echo "Deleting build directory"
	@rm -fr target

# Targets with special compile options
{{profiledCompileOptions}}

# Build object files from source code
%.acu: %.cbl
	@mkdir -p "$(COPYBOOK_DEPENDENCY_DIR)"
	@mkdir -p "$(OBJECT_DIR)"
	@echo "Generating dependencies"
	@echo -n "$@:" > "$(COPYBOOK_DEPENDENCY_DIR)/$(basename $@).d"
	@$(COMPILER) -Ms -Sp "$(COPYBOOK_DIR)" "$(SOURCE_DIR)/$(basename $@).cbl" | tr -d '\r' | tr '\n' ':' | "$(COBALT_BIN_DIR)/ccbltr.sh" >> "$(COPYBOOK_DEPENDENCY_DIR)/$(basename $@).d"
	@echo "Compiling $@..."
	@$(COMPILER) $(COMPILE_OPTIONS) -Sp "$(COPYBOOK_DIR)" -o "$(OBJECT_DIR)/$@" "$<"

%.acu: %.CBL
	@mkdir -p "$(COPYBOOK_DEPENDENCY_DIR)"
	@mkdir -p "$(OBJECT_DIR)"
	@echo "Generating dependencies..."
	@echo -n "$@:" > "$(COPYBOOK_DEPENDENCY_DIR)/$(basename $@).d"
	@$(COMPILER) -Ms -Sp "$(COPYBOOK_DIR)" "$(SOURCE_DIR)/$(basename $@).CBL" | tr -d '\r' | tr '\n' ':' | "$(COBALT_BIN_DIR)/ccbltr.sh" >> "$(COPYBOOK_DEPENDENCY_DIR)/$(basename $@).d"
	@echo "Compiling $@..."
	@$(COMPILER) $(COMPILE_OPTIONS) -Sp "$(COPYBOOK_DIR)" -o "$(OBJECT_DIR)/$@" "$<"

sinclude $(COPYBOOK_DEPENDENCY_DIR)/*.d
