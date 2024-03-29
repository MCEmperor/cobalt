
TARGET_DIR := target
SOURCE_DIR := src/main/cobol
COPYBOOK_DIR := src/main/cobol/copybook
COPYBOOK_DEPENDENCY_DIR := $(TARGET_DIR)/copybookdependencies
OBJECT_DIR := $(TARGET_DIR)/objects
FD_DIR := $(TARGET_DIR)/fd

LSOURCES := $(wildcard $(SOURCE_DIR)/*.cbl)
LOBJECTS := $(notdir $(LSOURCES:.cbl=.acu))
USOURCES := $(wildcard $(SOURCE_DIR)/*.CBL)
UOBJECTS := $(notdir $(USOURCES:.CBL=.acu))

COMPILE_OPTIONS := {{compileOptions}}
COMPILE_FD_STRING := {{compileFdString}}
FINGERPRINT_SUPPLIER := {{fingerprintSupplier}}

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
.PHONY: compile package deploy .validatefingerprint

compile: $(LOBJECTS) $(UOBJECTS)

package: compile
	@echo Building package {{packageFilename}}
	@$(CBLUTIL) -lib -o "$(TARGET_DIR)/{{packageFilename}}.acu" $(OBJECT_DIR)/*.acu

deploy: compile
	@echo "Building deploy-ready package {{packageFilename}}"
	@$(CBLUTIL) -lib -c "$(shell $(COBALT_BIN_DIR)/fingerprint.sh $(FINGERPRINT_SUPPLIER))" -o "$(TARGET_DIR)/{{packageFilename}}.acu" $(OBJECT_DIR)/*.acu

.validatefingerprint:
	@$(COBALT_BIN_DIR)/validatefingerprint.sh $(FINGERPRINT_SUPPLIER)

# Targets with special compile options
{{profiledCompileOptions}}

# Build object files from source code
%.acu: %.cbl
	@mkdir -p '$(COPYBOOK_DEPENDENCY_DIR)'
	@mkdir -p '$(OBJECT_DIR)'
	@mkdir -p '$(FD_DIR)'
	@echo 'Generating dependencies for $@'
	@echo -n '$@:' > '$(COPYBOOK_DEPENDENCY_DIR)/$(basename $@).d'
	@$(COMPILER) -Ms -Sp '$(COPYBOOK_DIR)' '$(SOURCE_DIR)/$(basename $@).cbl' | tr -d '\r' | tr '\n' ':' | '$(COBALT_BIN_DIR)/ccbltr.sh' >> '$(COPYBOOK_DEPENDENCY_DIR)/$(basename $@).d'
	@echo 'Compiling $@'
	@$(COMPILER) $(COMPILE_FD_STRING) $(COMPILE_OPTIONS) -Sp '$(COPYBOOK_DIR)' -o '$(OBJECT_DIR)/$@' '$<'

%.acu: %.CBL
	@mkdir -p '$(COPYBOOK_DEPENDENCY_DIR)'
	@mkdir -p '$(OBJECT_DIR)'
	@mkdir -p '$(FD_DIR)'
	@echo 'Generating dependencies for $@'
	@echo -n '$@:' > '$(COPYBOOK_DEPENDENCY_DIR)/$(basename $@).d'
	@$(COMPILER) -Ms -Sp '$(COPYBOOK_DIR)' '$(SOURCE_DIR)/$(basename $@).CBL' | tr -d '\r' | tr '\n' ':' | '$(COBALT_BIN_DIR)/ccbltr.sh' >> '$(COPYBOOK_DEPENDENCY_DIR)/$(basename $@).d'
	@echo 'Compiling $@'
	@$(COMPILER) $(COMPILE_FD_STRING) $(COMPILE_OPTIONS) -Sp '$(COPYBOOK_DIR)' -o '$(OBJECT_DIR)/$@' '$<'

sinclude $(COPYBOOK_DEPENDENCY_DIR)/*.d
