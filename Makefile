COFFEE := coffee
COFFEE_FLAGS := --compile --bare

# Setup file locations
SRC_DIR  := app
OUT_DIR  := target

# Glob all the coffee source
SRC := $(shell find app -name "*.coffee")
LIB := $(SRC:$(SRC_DIR)/%.coffee=$(OUT_DIR)/%.js)

.PHONY: all clean rebuild

# Phony all target
all: $(LIB)
	@-echo "Finished building footsy"

# Phony clean target
clean:
	@-echo "Cleaning *.js files"
	@-rm -f $(LIB)

# Phony rebuild target
rebuild: clean all

# Rule for all other coffee files
$(OUT_DIR)/%.js: $(SRC_DIR)/%.coffee
	@-echo "  Compiling $@"
	@$(COFFEE) $(COFFEE_FLAGS) -o $(shell dirname $@) $^

