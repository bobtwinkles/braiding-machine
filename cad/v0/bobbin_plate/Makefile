.PHONY: all clean

all: gen/cam_points.scad

clean:
	rm -r gen

########################################
## bobbin guide plate
########################################

gen/cam_points.scad: src_data/cam_points.txt gen
	@echo '// GENERATED FILE, DO NOT EDIT' > $@; \
	echo 'cam_points = [' >> $@; \
	cat $< | awk '{printf "[ %s, %s ],\n", $$3, $$4}' >> $@; \
	echo ']' >> $@

gen:
	mkdir -p gen
