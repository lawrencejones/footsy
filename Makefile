COFFEE := coffee
COFFEE_FLAGS := --compile --bare

# Setup file locations
SRC_DIR  := app
OUT_DIR  := target

# Glob all the coffee source
SRC := $(shell find app -name "*.coffee")
LIB := $(SRC:$(SRC_DIR)/%.coffee=$(OUT_DIR)/%.js)

# Glob web source
WEB := web/modules $(shell find web -name "*.coffee")

.PHONY: all clean rebuild

# Phony all target
all: $(LIB) public/app.js
	@-echo "Finished building footsy"

# Phony clean target
clean:
	@-echo "Cleaning *.js files"
	@-rm -f $(LIB) public/app.js

# Phony rebuild target
rebuild: clean all

# Rule for all other coffee files
$(OUT_DIR)/%.js: $(SRC_DIR)/%.coffee
	@-echo "  Compiling $@"
	@$(COFFEE) $(COFFEE_FLAGS) -o $(shell dirname $@) $^

# Rule for generating compiled web asset
public/app.js: $(WEB)
	@-echo "Compiling web asset $@"
	@$(COFFEE) -cj $@ $^
