# Directories
SRC_DIR = benches
GHC_DIR = ghc
FL_DIR = fl

# Compiler options
GHC_FLAGS = -Wall -fno-prof-count-entries -rtsopts -Wno-unused-matches -Wno-missing-signatures
GHC_PAR_FLAGS = -threaded
FL_FLAGS = -s -i1 -h3 -r6:3:2:1:2:16
FL = flite
HERON = heron

# Source files
SOURCES = $(wildcard $(SRC_DIR)/*.hs)

# Compiled files
GHC_BINS_PAR = $(patsubst $(SRC_DIR)/%.hs, $(GHC_DIR)/par/%  , $(SOURCES))
GHC_BINS_SEQ = $(patsubst $(SRC_DIR)/%.hs, $(GHC_DIR)/seq/%  , $(SOURCES))
FL_SRCS_PAR = $(patsubst $(SRC_DIR)/%.hs, $(FL_DIR)/par/%.fl, $(SOURCES))
FL_SRCS_SEQ = $(patsubst $(SRC_DIR)/%.hs, $(FL_DIR)/seq/%.fl, $(SOURCES))
FL_TMPLS_PAR = $(patsubst $(SRC_DIR)/%.hs, $(FL_DIR)/par/%.tmpl, $(SOURCES))
FL_TMPLS_SEQ = $(patsubst $(SRC_DIR)/%.hs, $(FL_DIR)/seq/%.tmpl, $(SOURCES))
FL_BINS_PAR = $(patsubst $(SRC_DIR)/%.hs, $(FL_DIR)/par/%.bin, $(SOURCES))
FL_BINS_SEQ = $(patsubst $(SRC_DIR)/%.hs, $(FL_DIR)/seq/%.bin, $(SOURCES))

# Runtime profile logs
GHC_LOGS_PAR = $(patsubst $(SRC_DIR)/%.hs, $(GHC_DIR)/par/%.log  , $(SOURCES))
GHC_LOGS_SEQ = $(patsubst $(SRC_DIR)/%.hs, $(GHC_DIR)/seq/%.log  , $(SOURCES))

all: dirs $(GHC_BINS_PAR) $(GHC_BINS_SEQ) $(FL_TMPLS_PAR) $(FL_TMPLS_SEQ) $(FL_BINS_PAR) $(FL_BINS_SEQ) $(FL_SRCS_PAR) $(FL_SRCS_SEQ)

fl_bins: dirs $(FL_BINS_PAR) $(FL_BINS_SEQ)
fl_tmpls: dirs $(FL_TMPLS_PAR) $(FL_TMPLS_SEQ)
fl_srcs: dirs $(FL_SRCS_PAR) $(FL_SRCS_SEQ)

ghc_logs: dirs $(GHC_LOGS_PAR) $(GHC_LOGS_SEQ)

# Rule for building GHC sources
$(GHC_DIR)/par/%.hs: $(SRC_DIR)/%.hs
	haskell-mustache $< config/ghc_par.json > $@
$(GHC_DIR)/seq/%.hs: $(SRC_DIR)/%.hs
	haskell-mustache $< config/ghc_seq.json > $@

# Rule for building F-lite sources
$(FL_DIR)/par/%.fl: $(SRC_DIR)/%.hs
	haskell-mustache $< config/heron_par.json > $@
$(FL_DIR)/seq/%.fl: $(SRC_DIR)/%.hs
	haskell-mustache $< config/heron_seq.json > $@

# Rule for building GHC binaries
$(GHC_DIR)/par/%: $(GHC_DIR)/par/%.hs
	ghc -o $@ $(GHC_FLAGS) $(GHC_PAR_FLAGS) $<
$(GHC_DIR)/seq/%: $(GHC_DIR)/seq/%.hs
	ghc -o $@ $(GHC_FLAGS) $<

# Rule for compiling F-lite templates
$(FL_DIR)/par/%.tmpl: $(FL_DIR)/par/%.fl
	$(FL) $(FL_FLAGS) $< > $@
$(FL_DIR)/seq/%.tmpl: $(FL_DIR)/seq/%.fl
	$(FL) $(FL_FLAGS) $< > $@

# Rule for compiling F-lite binary templates
$(FL_DIR)/par/%.bin: $(FL_DIR)/par/%.fl
	$(HERON) -d $< > $@
$(FL_DIR)/seq/%.bin: $(FL_DIR)/seq/%.fl
	$(HERON) -d $< > $@

# Rule for running GHC benchmarks
$(GHC_DIR)/par/%.log: $(GHC_DIR)/par/%
	./ghc_speedups.sh    -f $< > $@
$(GHC_DIR)/seq/%.log: $(GHC_DIR)/seq/%
	./ghc_speedups.sh -b -f $< > $@

# Make sure the build directories exist
dirs: $(GHC_DIR)/par $(FL_DIR)/par $(GHC_DIR)/seq $(FL_DIR)/seq
$(GHC_DIR)/par:
	mkdir -p $@
$(FL_DIR)/par:
	mkdir -p $@
$(GHC_DIR)/seq:
	mkdir -p $@
$(FL_DIR)/seq:
	mkdir -p $@

clean:
	rm -r $(GHC_DIR) $(FL_DIR)
