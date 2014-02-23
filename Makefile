COFFEE := coffee
COFFEE_FLAGS := --compile --bare

# Setup file locations
SRC_DIR  := src
LIB_DIR  := lib
TEST_DIR := test

# Glob all the coffee source
SRC := $(wildcard $(SRC_DIR)/*.coffee | sort)
LIB := $(SRC:$(SRC_DIR)/%.coffee=$(LIB_DIR)/%.js)

.PHONY: all clean rebuild

# Phony all target
all: $(LIB_DIR) $(LIB)
	@-echo "Finished building watchme."
 
# Produces folder for js
$(LIB_DIR):
	@mkdir $@

# Phony clean target
clean:
	@-echo "Cleaning *.js files"
	@-rm -f $(LIB)

# Phony rebuild target
rebuild: clean all

# Rule for all other coffee files
lib/%.js: src/%.coffee
	@-echo "  Compiling $@"
	@$(COFFEE) $(COFFEE_FLAGS) -o $(LIB_DIR) $^

