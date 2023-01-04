include <gen/cam_points.scad>;
include <parameters.scad>;

include <BOSL/constants.scad>;
use <BOSL/masks.scad>;
use <BOSL/transforms.scad>;
use <BOSL/shapes.scad>;
use <BOSL/involute_gears.scad>;

// Clearance hole for an M3 screw
module mounting_screw_clearance_hole() {
  cylinder(r=2.7, h=1000, center=true);
}

// Hole dimensioned for an alignment pin
module alignment_hole() {
  // TODO: figure out the tolerances here, the hole size probably needs to be
  // adjusted. Also adjust alignment_slot when that's figured out
  // Currently sized for a 1/8" diameter pin
  cylinder(r=3.175, h=1000, center=true);
}

// Slot for an alignment pin
// Generates along the +X direction
module alignment_slot(length) {
  slot([0, 0, 0], [length, 0, 0], r=3.175, h=1000);
}

/// Generates a 3D solid of the cam profile, using the specified base radius
module cam_profile(height, base_radius, center=true) {
  // rotation is to get nice alignment when zring'ing
  rotate([0, 0, 180 + (360 / horn_gear_count)])
  linear_extrude(height, center=center)
  // magic 100 here is from the cam profile generator
  scale(base_radius / (100))
  polygon(points=cam_points);
}

/// Model of the full cam, including mounting features
module cam() {
  difference() {
    // The base profile
    cam_profile(bobbin_plate_thickness, cam_base_radius, center=false);

    // Central hole, where the horn bearing runs
    cylinder(d=horn_bearing_od, h=100, center=true);

    // Mounting hole
    ymove(15)
    mounting_screw_clearance_hole();

    // alignment pin
    xmove(20) alignment_hole();

    // alignment slot
    xmove(-20) alignment_slot(8);
  }
}

// All the cams, for visualization
module all_cams() {
  color("green")
  zring(n=horn_gear_count, r=bobbin_plate_radius) {
    cam();
  }
}

// central guide
module central() {
  color("orange")
  difference() {
    // Base cylinder
    cylinder(r=bobbin_plate_radius + horn_gear_radius + 10, h=bobbin_plate_thickness);

    // Cutout all the bobbin paths
    zring(n=horn_gear_count, r=bobbin_plate_radius) {
      cam_profile(1000, cam_base_radius + bobbin_guide_thickness, center=true);
    }

    // Central hole for feeding material in to the machine
    cylinder(d=feedthrough_hole_diameter, h=1000, center=true);

    // Mounting screw clearance holes
    zring(n=3, r=feedthrough_hole_diameter + 10) mounting_screw_clearance_hole();

    // Cut the sharp corners between cams, as those are difficult to manufacture
    // and hopefully aren't required.
    zrot(horn_gear_angle / 2)
    zring(
      n=horn_gear_count,
      r=bobbin_plate_radius * cos(horn_gear_angle / 2)
    )
    let (r = bobbin_guide_thickness,
         o = bobbin_guide_thickness * 1.4)
    {
      // outer
      xmove(o) zrot(45) fillet_mask(r=r, l=100, center=true);

      // inner
      xmove(-o) zrot(45) fillet_mask(r=r, l=100, center=true);
    }

    //
    // alignment features
    //
    zrot(60)
    xmove(feedthrough_hole_diameter + 15)
      alignment_hole();

    xmove(-feedthrough_hole_diameter - 5)
      zrot(180)
      alignment_slot(10);
  }
}

module cam_follower() {
  intersection() {
    let (l = 2 * bobbin_guide_thickness) hull() {
      ymove(-l) cylinder(d=0.9*bobbin_guide_thickness);
      ymove( l) cylinder(d=0.9*bobbin_guide_thickness);
    }

    xmove(-cam_base_radius + bobbin_guide_thickness / 2)
      cylinder(r=cam_base_radius, h=150, center=true);
    xmove(cam_base_radius - bobbin_guide_thickness / 2)
      cylinder(r=cam_base_radius, h=150, center=true);
  }
  zmove(-10)
  color("purple")
  cylinder(d=bobbin_guide_thickness * 2);
}

module top_level() {
  all_cams();
  central();
}

projection(cut=true)
  top_level();

/*
ymove(bobbin_plate_radius * cos(horn_gear_angle/2)) {
  zrot(leadin_angle + 4)
  cam_follower();
}

zrot(90)
ymove(bobbin_plate_radius) {
  zrot($t * 90)
  zring(n=4)
  zmove(15)
  xmove(cam_base_radius + bobbin_guide_thickness / 2)
  cam_follower();
}

zrot(150)
ymove(bobbin_plate_radius) {
  zrot($t * -90)
  zring(n=4)
  zmove(15)
  xmove(cam_base_radius + bobbin_guide_thickness / 2)
  cam_follower();
}
*/

/*
zmove(-8)
zring(n=horn_gear_count, r=bobbin_plate_radius)
zrot(90/horn_gear_tooth_count)
gear(
  thickness=8,
  mm_per_tooth,
  number_of_teeth=horn_gear_tooth_count,
  hole_diameter=horn_shaft_diameter
);
*/


/*
// Bobbin assembly standins
color("purple")
zring(n=horn_gear_count, r=bobbin_plate_radius) {
  zring(n=4, r=horn_gear_radius, sa=(($idx % 2) == 0 ? 90 : -90)*$t)
    cylinder(r=bobbin_radius, h=40);
}

#zring(n=horn_gear_count, r=bobbin_plate_radius)
  difference() {
    cylinder(h=15, r=horn_gear_radius + bobbin_guide_thickness/2, center=true);
    cylinder(h=16, r=horn_gear_radius - bobbin_guide_thickness/2, center=true);
  }
*/
