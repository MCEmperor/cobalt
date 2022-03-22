PACKAGE_NAME := cobalt
VERSION := 1.0.0

SOURCE_DIR := src
TARGET_DIR := target

APPLICATION_DIR := opt/cobalt
SOURCE_FILES := $(wildcard ${SOURCE_DIR}/*)

DPKG_SOURCE_META_DIR := build/DEBIAN
DPKG_SOURCE_META_FILES := $(wildcard ${DPKG_SOURCE_META_DIR}/*)
DPKG_TARGET_BASE_DIR := ${TARGET_DIR}/${PACKAGE_NAME}_${VERSION}
DPKG_TARGET_FS_DIR := ${DPKG_TARGET_BASE_DIR}/${APPLICATION_DIR}
DPKG_TARGET_FS_FILES := $(addprefix ${DPKG_TARGET_FS_DIR}/,$(notdir ${SOURCE_FILES}))
DPKG_TARGET_META_DIR := ${DPKG_TARGET_BASE_DIR}/DEBIAN
DPKG_TARGET_META_FILES := $(addprefix ${DPKG_TARGET_META_DIR}/,$(notdir $(wildcard ${DPKG_SOURCE_META_DIR}/*)))

.PHONY : clean package-debian

package-debian : ${DPKG_TARGET_FS_FILES} ${DPKG_TARGET_META_FILES}
	@echo "Creating package ${PACKAGE_NAME}, version ${VERSION}"
	@cd ${TARGET_DIR} && dpkg-deb --build --root-owner-group $(notdir ${DPKG_TARGET_BASE_DIR})

clean :
	@echo "Cleaning target dir"
	@rm -fr target

${DPKG_TARGET_FS_DIR}/% : ${SOURCE_DIR}/%
	@mkdir -p ${DPKG_TARGET_FS_DIR}
	@cp $< $@

${DPKG_TARGET_META_DIR}/% : ${DPKG_SOURCE_META_DIR}/%
	@mkdir -p ${DPKG_TARGET_META_DIR}
	@cp $< $@
