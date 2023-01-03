.PHONY: all
.DEFAULT: all

PLOTS := \
	plots/out/cam_points.png \
	plots/out/cam_compare.png \
	plots/out/modified_trapezoid.png

DATAFILES := \
	data/cam_points.txt \
	data/cam_points_tangent.txt \
	data/modified_trapezoid.txt \

INTERMEDIATES := $(PLOTS) $(DATAFILES)

all: $(PLOTS)

clean:
	rm -r plots/out
	rm -r plots/datafiles

$(PLOTS) : plots/out
$(DATAFILES) : data/

################################################################################
# Plot rules
################################################################################

plots/out/modified_trapezoid.png : plots/plot_modified_trapezoid.gnuplot data/modified_trapezoid.txt
	gnuplot $<

plots/out/cam_points.png : plots/plot_cam_points.gnuplot data/cam_points.txt
	gnuplot $<

plots/out/cam_compare.png : plots/plot_cam_compare.gnuplot plots/out data/cam_points.txt data/cam_points_tangent.txt
	gnuplot $<

################################################################################
# Data rules
################################################################################

data/cam_points.txt data/cam_points_tangent.txt &: cam_design.py data/modified_trapezoid.txt
	python3 cam_design.py

data/modified_trapezoid.txt: generate_modified_trapezoid.py
	python generate_modified_trapezoid.py

################################################################################
# Directory rules
################################################################################
plots/out:
	mkdir -p $@

data:
	mkdir -p $@
