COFFEE := coffee
COFFEE_FLAGS := --compile --bare

# Setup file locations
SRC_DIR  := app

# Glob all the coffee source
SRC := $(shell find app -name "*.coffee") server.coffee
LIB := $(SRC:.coffee=.js)

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
%.js: %.coffee
	@-echo "  Compiling $@"
	@$(COFFEE) $(COFFEE_FLAGS) -o $(shell dirname $@) $^

