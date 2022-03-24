PACKAGE_NAME := cobalt
VERSION := 1.0.0
DESCRIPTION := Cobalt - build tool for COBOL
URL := https://github.com/MCEmperor/cobalt
MAINTAINER := MC Emperor <dev@mcemperor.org>

SOURCE_DIR := src
BUILD_SOURCE_DIR := build
TARGET_DIR := target

APPLICATION_DIR := opt/cobalt
SOURCE_FILES := $(wildcard ${SOURCE_DIR}/*)
BUILD_SOURCE_FILES := $(wildcard ${BUILD_SOURCE_DIR}/*)
TARGET_SOURCE_DIR := ${TARGET_DIR}/${SOURCE_DIR}
TARGET_BUILD_DIR := ${TARGET_DIR}/${BUILD_SOURCE_DIR}
TARGET_SOURCE_FILES := $(addprefix ${TARGET_SOURCE_DIR}/,$(notdir ${SOURCE_FILES}))
TARGET_BUILD_FILES := $(addprefix ${TARGET_BUILD_DIR}/,$(notdir ${BUILD_SOURCE_FILES}))

.PHONY : clean package-debian

package-debian : ${TARGET_SOURCE_FILES} ${TARGET_BUILD_FILES}
	@echo "Creating package ${PACKAGE_NAME}, version ${VERSION}"
	@fpm \
		-s dir -t deb \
		-p ${TARGET_DIR}/${PACKAGE_NAME}-${VERSION}.deb \
		--name ${PACKAGE_NAME} \
		--license mit \
		--version ${VERSION} \
		--architecture all \
		--depends make --depends python3 \
		--after-install ${TARGET_BUILD_DIR}/postinst \
		--description "${DESCRIPTION}" \
		--url "${URL}" \
		--maintainer "${MAINTAINER}" \
		${TARGET_SOURCE_DIR}/=/${APPLICATION_DIR}

clean :
	@echo "Cleaning target dir"
	@rm -fr target

${TARGET_SOURCE_DIR}/% : ${SOURCE_DIR}/%
	@mkdir -p ${TARGET_SOURCE_DIR}
	@cp $< $@

${TARGET_BUILD_DIR}/% : ${BUILD_SOURCE_DIR}/%
	@mkdir -p ${TARGET_BUILD_DIR}
	@cp $< $@
