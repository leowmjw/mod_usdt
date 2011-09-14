# All generated files go into the BUILD directory
BUILD		 = build

# Apache module name
MODNAME		 = dtprovider

# DTrace provider name
PROVIDER	 = http

# Compile flags
CC		 = gcc
AP_CPPFLAGS	:= $(shell apxs -q CPPFLAGS)
SOLDFLAGS	 = -shared -fPIC

# Source layout
CSRCS		 = src/$(MODNAME).c
SOFILE		 = $(BUILD)/mod_$(MODNAME).so
OBJFILES	 = $(CSRCS:src/%.c=$(BUILD)/%.o)
EXTRAOBJFILES	 = $(BUILD)/$(PROVIDER)_provider.o

all: $(SOFILE)

clean:
	-rm -rf $(BUILD)

$(BUILD):
	mkdir -p $(BUILD)

#
# The shared object combines the object files generated from C sources with the
# one generated by DTrace.
#
$(SOFILE): $(OBJFILES) $(EXTRAOBJFILES)
	$(CC) $(SOLDFLAGS) $(LDFLAGS) -o $@ $^

#
# Object files are generated either by building the corresponding source file
# or by running "dtrace -G" on the provider file using the other object files.
#
$(BUILD)/%.o: src/%.c | $(BUILD)
	$(CC) $(CFLAGS) $(CPPFLAGS) $(AP_CPPFLAGS) -c -o $@ $<

$(BUILD)/$(PROVIDER)_provider.o: src/$(PROVIDER)_provider.d $(OBJFILES) | $(BUILD)
	dtrace -xnolibs -G -o $@ -s $< $(OBJFILES)

#
# The provider header file is generated directly by "dtrace -h".
#
$(BUILD)/$(PROVIDER)_provider.h: src/$(PROVIDER)_provider.d | $(BUILD)
	dtrace -xnolibs -h -o $@ -s $<