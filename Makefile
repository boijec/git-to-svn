MAIN_SRC = ${PWD}/src/main
SHARED_SRC = ${PWD}/src/shared
INSTALLER_SRC = ${PWD}/src/installer
MODULES_SRC = ${PWD}/src/main/modules
TARGET_SRC = ${PWD}/target

TARGET_FILE = "${TARGET_SRC}/svn-to-git.sh"
TARGET_FILE_TEMP = "${TARGET_SRC}/svn-to-git.sh.tmp"
TARGET_INSTALLER = "${TARGET_SRC}/installer.sh"
TARGET_INSTALLER_TEMP = "${TARGET_SRC}/installer.sh.tmp"

INSTALLER = "${INSTALLER_SRC}/installer-core.bash"
INST_ENV = "${INSTALLER_SRC}/installer-environment.bash"

PRJ_SYS_REQ = "${SHARED_SRC}/system-req-check.bash"

USAGE_TEXT = "${MAIN_SRC}/assets/usage.txt"

PRJ_ENV = "${MAIN_SRC}/application-environment.bash"
PRJ_SYS_INIT = "${MAIN_SRC}/system-init.bash"
PRJ_MAIN = "${MAIN_SRC}/main.bash"
PRJ_LOGGER = "${SHARED_SRC}/log.bash"

BUILD_VERSION = Alpha-0.5
BUILD_STAMP = $(shell date +%s%3N)
PRJ_LIB = $(shell ls -d ${MODULES_SRC}/*)
export PRJ_LIB

SHELL := /bin/env bash
all: prune_old create_output_dir write_headers define_core add_modules define_main invoke_main build_installer clean_all package

create_output_dir:
	mkdir -p ${TARGET_SRC}

prune_old:
	rm -f ${TARGET_SRC}/*

write_headers:
	echo -e "#!/bin/bash\n" > ${TARGET_FILE_TEMP}
	cat "${PRJ_ENV}" >> ${TARGET_FILE_TEMP}
	echo -e "\nSCRIPTVERSION=\"${BUILD_VERSION}.${BUILD_STAMP}\"" >> ${TARGET_FILE_TEMP}
	echo -e "\n" >> ${TARGET_FILE_TEMP}

define_main:
	echo -e "function main() {" >> ${TARGET_FILE_TEMP}
	cat "${PRJ_SYS_REQ}" | grep -v '#--' | sed -e 's/^/  /g' >> ${TARGET_FILE_TEMP}
	cat "${PRJ_SYS_INIT}" | grep -v '#--' | sed -e 's/^/  /g' >> ${TARGET_FILE_TEMP}
	cat "${PRJ_MAIN}" | grep -v '#--' | sed -e 's/^/  /g' >> ${TARGET_FILE_TEMP}
	echo -e "}\n" >> ${TARGET_FILE_TEMP}

invoke_main:
	echo "main \"\$$@\"" >> ${TARGET_FILE_TEMP}

define_core:
	cat ${PRJ_LOGGER} | grep -v '#-- Path' >> ${TARGET_FILE_TEMP}
	echo -e "function printUsage() {" >> ${TARGET_FILE_TEMP}
	while read line; do \
  		TARGET_LINE=$$(echo "$$line"); \
		if echo "$$TARGET_LINE" | grep -q "\{[[:upper:]]*\}"; then \
			TARGET_LINE=$$(echo -e "$$TARGET_LINE" | sed -e 's/{SCRIPTNAME}/$${SCRIPTNAME}/g' | sed -e 's/{SCRIPTVERSION}/$${SCRIPTVERSION}/g'); \
		fi; \
		if echo "$$TARGET_LINE" | grep -q "COL "; then \
			TARGET_LINE=$$(echo -e "$$TARGET_LINE" | sed -e 's/COL //g' | awk -F"\t" '{printf "\t%-25s %-25s\n", $$1, $$2}'); \
		fi; \
		echo -e "echo -e \"$$TARGET_LINE\"" | sed -e 's/^/  /g' >> ${TARGET_FILE_TEMP}; \
	done < ${USAGE_TEXT}
	echo -e "}\n" >> ${TARGET_FILE_TEMP}

add_modules:
	for filename in $${PRJ_LIB[*]}; do cat $${filename} | grep -v '#-- Path' >> ${TARGET_FILE_TEMP}; echo >> ${TARGET_FILE_TEMP}; done

build_installer:
	echo -e "#!/bin/bash\n" > ${TARGET_INSTALLER_TEMP}
	cat "${INST_ENV}" >> ${TARGET_INSTALLER_TEMP}
	echo -e "\n" >> ${TARGET_INSTALLER_TEMP}
	cat ${PRJ_LOGGER} | grep -v '#--' >> ${TARGET_INSTALLER_TEMP}
	echo -e "function main() {" >> ${TARGET_INSTALLER_TEMP}
	cat "${PRJ_SYS_REQ}" | grep -v '#--' | sed -e 's/^/  /g' >> ${TARGET_INSTALLER_TEMP}
	cat "${INSTALLER}" | grep -v '#--' | sed -e 's/^/  /g' >> ${TARGET_INSTALLER_TEMP}
	echo -e "}\n" >> ${TARGET_INSTALLER_TEMP}
	echo "main \"\$$@\"" >> ${TARGET_INSTALLER_TEMP}

clean_all:
	cat "${TARGET_FILE_TEMP}" | grep -v '#--' > "${TARGET_FILE}"
	cat "${TARGET_INSTALLER_TEMP}" | grep -v '#--' > "${TARGET_INSTALLER}"
	rm -f ${TARGET_FILE_TEMP} ${TARGET_INSTALLER_TEMP}

package:
	shc -f ${TARGET_FILE}
	mv ${TARGET_FILE}.x ${TARGET_SRC}/svn-to-git
	#rm -f ${TARGET_FILE} ${TARGET_FILE}.x.c
	zip -r target/bundle.zip target/*