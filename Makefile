.PHONY: default deploy build watch light-clean clean libs unix2dos dos2unix

# these variables keep our libraries pinned for us
LIBACE_URL := "https://github.com/WoWUIDev/Ace3/archive/refs/tags/Release-r1294.zip"
LIBDUALSPEC_URL := "https://github.com/AdiAddons/LibDualSpec-1.0/archive/refs/tags/v1.22.0.zip"
LIBDEFLATE_URL := "https://github.com/SafeteeWoW/LibDeflate/releases/download/1.0.2-release/LibDeflate-1.0.2-release.zip"
LIBDBICON_URL := "https://www.wowace.com/projects/libdbicon-1-0/files/4051008/download"

# build and install directories are separate because make really doesn't dig spaces
# spaces are fine in the install dir, but NOT okay in the target dir
NEURON_INSTALL_DIR ?= "/mnt/c/Program Files \(x86\)/World of Warcraft/_retail_/Interface/Addons/Neuron"
NEURON_TARGET_DIR ?= dist

# just set up the variables with the source files
SUB_DIRECTORIES := GUI Images Localizations Objects Utilities XML
SUB_DIRECTORY_TARGETS := $(SUB_DIRECTORIES:%=$(NEURON_TARGET_DIR)/%)
OUTPUTS := $(wildcard $(NEURON_TARGET_DIR)/*/*) $(wildcard $(NEURON_TARGET_DIR)/*)
LUA_SOURCES := $(filter-out $(OUTPUTS), $(wildcard *.lua) $(wildcard */*.lua))
LUA_TARGETS := $(LUA_SOURCES:%.lua=$(NEURON_TARGET_DIR)/%.lua)
TGA_SOURCES := $(filter-out $(OUTPUTS), $(wildcard *.tga) $(wildcard */*.tga))
TGA_TARGETS := $(TGA_SOURCES:%.tga=$(NEURON_TARGET_DIR)/%.tga)
XML_SOURCES := $(filter-out $(OUTPUTS), $(wildcard *.xml) $(wildcard */*.xml))
XML_TARGETS := $(XML_SOURCES:%.xml=$(NEURON_TARGET_DIR)/%.xml)
MISC_SOURCES := LICENSE Neuron.toc Libs/embeds.xml
MISC_TARGETS := $(MISC_SOURCES:%=$(NEURON_TARGET_DIR)/%)
ALL_TARGETS := $(LUA_TARGETS) $(TGA_TARGETS) $(XML_TARGETS) $(MISC_TARGETS)
LIB_ZIPS := libace.zip libdualspec.zip libdeflate.zip libdbicon.zip
ZIP_CACHES := $(LIB_ZIPS:%.zip=.libcache/%.zip)

# the default build deploys the addon and starts watching it for changes
default: light-clean $(ZIP_CACHES) libs
	# recursing ensures that if the target dir is local, it doesn't recopy itself
	make deploy
	fswatch -o -x -r --event Updated --event Created --event Renamed -e ".git/*" -e "$(NEURON_TARGET_DIR)/*" . | xargs -n1 -I{} $(MAKE) deploy

# keep build and deploy separate because down the road we will have
# other deploys that depend on build like bigwigsmod/packager and so on
deploy: build
	rsync -rvu --mkpath --delete "$(NEURON_TARGET_DIR)"/* "$(NEURON_INSTALL_DIR)"

build: $(NEURON_TARGET_DIR) $(NEURON_TARGET_DIR)/Libs $(SUB_DIRECTORY_TARGETS) $(ALL_TARGETS)

light-clean:
	rm -rf "$(NEURON_TARGET_DIR)"
clean: light-clean
	rm -rf .libcache
	rm -rf "$(NEURON_INSTALL_DIR)"

$(NEURON_TARGET_DIR):
	@echo "  $@"
	@mkdir -p "$(NEURON_TARGET_DIR)"


.libcache:
	@echo "  $@"
	@mkdir -p .libcache

# careful! this will create directories for files without rules
$(NEURON_TARGET_DIR)/%: %
	@echo "  $@"
	@mkdir -p "$@"

$(NEURON_TARGET_DIR)/%.lua: %.lua
	@echo "  $@"
	@cp "$<" "$@"
$(NEURON_TARGET_DIR)/%.tga: %.tga
	@echo "  $@"
	@cp "$<" "$@"
$(NEURON_TARGET_DIR)/%.xml: %.xml
	@echo "  $@"
	@cp "$<" "$@"

$(NEURON_TARGET_DIR)/LICENSE: LICENSE $(NEURON_TARGET_DIR)
	@echo "  $@"
	@cp "$<" "$@"
$(NEURON_TARGET_DIR)/Neuron.toc: Neuron.toc $(NEURON_TARGET_DIR)
	@echo "  $@"
	@cp "$<" "$@"

# makefile dependency means the zip will be outdated when changing it's url
.libcache/libace.zip: .libcache Makefile
	curl -L $(LIBACE_URL) -o "$@"
.libcache/libdualspec.zip: .libcache Makefile
	curl -L $(LIBDUALSPEC_URL) -o "$@"
.libcache/libdeflate.zip: .libcache Makefile
	curl -L $(LIBDEFLATE_URL) -o "$@"
.libcache/libdbicon.zip: .libcache Makefile
	curl -L $(LIBDBICON_URL) -o "$@"

libs: $(NEURON_TARGET_DIR)/Libs $(NEURON_TARGET_DIR)/Libs/LibDualSpec-1.0 .libcache/libace.zip .libcache/libdualspec.zip .libcache/libdeflate.zip .libcache/libdbicon.zip
	bsdtar --strip-components=1 -C "$(NEURON_TARGET_DIR)/Libs" -xzf .libcache/libace.zip "*/Ace*-*/*"
	bsdtar --strip-components=1 -C "$(NEURON_TARGET_DIR)/Libs" -xzf .libcache/libace.zip "*/LibStub/*"
	bsdtar --strip-components=1 -C "$(NEURON_TARGET_DIR)/Libs" -xzf .libcache/libace.zip "*/CallbackHandler-1.0/*"
	bsdtar --strip-components=1 -C "$(NEURON_TARGET_DIR)/Libs/LibDualSpec-1.0" -xzf .libcache/libdualspec.zip "*/Lib*"
	bsdtar -C "$(NEURON_TARGET_DIR)/Libs" -xzf .libcache/libdeflate.zip
	bsdtar --strip-components=1 -C "$(NEURON_TARGET_DIR)/Libs" -xzf .libcache/libdbicon.zip "*/LibDBIcon-1.0"
	bsdtar --strip-components=1 -C "$(NEURON_TARGET_DIR)/Libs" -xzf .libcache/libdbicon.zip "*/LibDataBroker-1.1"

$(NEURON_TARGET_DIR)/Libs:
	@echo "  $@"
	@mkdir -p "$(NEURON_TARGET_DIR)/Libs"
$(NEURON_TARGET_DIR)/Libs/LibDualSpec-1.0:
	@echo "  $@"
	@mkdir -p "$(NEURON_TARGET_DIR)/Libs/LibDualSpec-1.0"


# this codebase has a horrific mixture of line endings.
# the only way to solve this is in my experience is to
# have ci/cd stop it, or delete all windows boxes.
# this is a starting place for tossing it to ci/cd along
# with some tooling to help users manage it
unix2dos:
	find . -type f -exec sed -i 's/^\([^\r]*\)$$/\1\r/' {} \;
dos2unix:
	find . -type f -exec sed -i 's/\r$$//' {} \;
