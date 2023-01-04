include <BOSL/constants.scad>;
use <BOSL/involute_gears.scad>;

/* [Global gear parameters] */
mm_per_tooth = 8;

/* [Horn gear] */
horn_gear_tooth_count = 30;
horn_gear_radius = pitch_radius(mm_per_tooth, horn_gear_tooth_count);
horn_shaft_diameter = 4;
horn_bearing_od = 11;

/* [Bobbins] */
bobbin_radius = 12.5;

/* [Bobbin plate] */
bobbin_guide_thickness = 5;
bobbin_plate_thickness = 5;
feedthrough_hole_diameter = 15;

/* [cam parameters] */
// -- must match cam profile generator --
horn_gear_count = 6;
horn_gear_angle = 360 / horn_gear_count;
// -- must match cam profile generator --
leadin_angle = 15;
cam_maximum_radius_pct = horn_gear_radius / cos(leadin_angle);
// Cam maximum radius is (input radius)/cos(leadin_angle), so compute what size
// the cam needs to be to leave a bobbin_guide_thickness gap between cams, plus
// some margin for the guides to float through
cam_base_radius = (horn_gear_radius - bobbin_guide_thickness/1.5) * cos(leadin_angle);

horn_gear_center_center = 2 * horn_gear_radius;
bobbin_plate_radius = horn_gear_center_center / (2 * sin(horn_gear_angle / 2));
