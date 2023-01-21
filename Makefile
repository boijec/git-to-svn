MAIN_SRC = ${PWD}/src/main
SHARED_SRC = ${PWD}/src/shared
INSTALLER_SRC = ${PWD}/src/installer
MODULES_SRC = ${PWD}/src/main/modules
TARGET_SRC = ${PWD}/target

TARGET_FILE = "${TARGET_SRC}/svn-to-git.sh"
TARGET_INSTALLER = "${TARGET_SRC}/installer.sh"

INSTALLER = "${INSTALLER_SRC}/installer-core.bash"
INST_ENV = "${INSTALLER_SRC}/installer-environment.bash"

PRJ_SYS_REQ = "${SHARED_SRC}/system-req-check.bash"

USAGE_TEXT = "${MAIN_SRC}/assets/usage.txt"

PRJ_ENV = "${MAIN_SRC}/application-environment.bash"
PRJ_SYS_INIT = "${MAIN_SRC}/system-init.bash"
PRJ_MAIN = "${MAIN_SRC}/main.bash"
PRJ_LOGGER = "${MAIN_SRC}/log.bash"

PRJ_LIB = $(shell ls -d ${MODULES_SRC}/*)
export PRJ_LIB

SHELL := /bin/env bash
all: create_output_dir prune_old write_headers define_core add_modules define_main invoke_main build_installer

create_output_dir:
	mkdir -p ${TARGET_SRC}

prune_old:
	rm -f ${TARGET_FILE}

write_headers:
	echo -e "#!/usr/bin/env bash\n" > ${TARGET_FILE}
	cat "${PRJ_ENV}" >> ${TARGET_FILE}
	echo -e "\n" >> ${TARGET_FILE}

define_main:
	echo -e "function main() {" >> ${TARGET_FILE}
	cat "${PRJ_SYS_REQ}" | grep -v '# Path' | sed -e 's/^/  /g' >> ${TARGET_FILE}
	cat "${PRJ_SYS_INIT}" | grep -v '# Path' | sed -e 's/^/  /g' >> ${TARGET_FILE}
	cat "${PRJ_MAIN}" | grep -v '# Path' | sed -e 's/^/  /g' >> ${TARGET_FILE}
	echo -e "}\n" >> ${TARGET_FILE}

invoke_main:
	echo "main \"\$$@\"" >> ${TARGET_FILE}

define_core:
	echo -e "function log() {" >> ${TARGET_FILE}
	cat ${PRJ_LOGGER} | grep -v '# Path' | sed -e 's/^/  /g' >> ${TARGET_FILE}
	echo -e "}\n" >> ${TARGET_FILE}
	echo -e "function printUsage() {" >> ${TARGET_FILE}
	while read line; do \
		if echo "$$line" | grep -q "{SCRIPTNAME}"; then \
			echo -e "echo -e \"$$line\"" | sed -e 's/{SCRIPTNAME}/$${SCRIPTNAME}/g' | sed -e 's/^/  /g' >> ${TARGET_FILE}; \
		else \
			echo -e "echo \"$$line\"" | sed -e 's/^/  /g' >> ${TARGET_FILE}; \
		fi \
	done < ${USAGE_TEXT}
	echo -e "}\n" >> ${TARGET_FILE}

add_modules:
	for filename in $${PRJ_LIB[*]}; do cat $${filename} | grep -v '# Path' >> ${TARGET_FILE}; echo >> ${TARGET_FILE}; done

build_installer:
	rm -f ${TARGET_INSTALLER}
	echo -e "#!/usr/bin/env bash\n" > ${TARGET_INSTALLER}
	cat "${INST_ENV}" >> ${TARGET_INSTALLER}
	echo -e "\n" >> ${TARGET_INSTALLER}
	echo -e "function log() {" >> ${TARGET_INSTALLER}
	cat ${PRJ_LOGGER} | grep -v '# Path' | sed -e 's/^/  /g' >> ${TARGET_INSTALLER}
	echo -e "}\n" >> ${TARGET_INSTALLER}
	echo -e "function main() {" >> ${TARGET_INSTALLER}
	cat "${PRJ_SYS_REQ}" | grep -v '# Path' | sed -e 's/^/  /g' >> ${TARGET_INSTALLER}
	cat "${INSTALLER}" | grep -v '# Path' | sed -e 's/^/  /g' >> ${TARGET_INSTALLER}
	echo -e "}\n" >> ${TARGET_INSTALLER}
	echo "main \"\$$@\"" >> ${TARGET_INSTALLER}