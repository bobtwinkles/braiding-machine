n = 256;
half_n_horns = 8;
shuttle_track_width = 10;

r = 30;

function major_radius(horn_radius) =
  horn_radius * 5.5;

module wiggleplate(
    resolution,
    half_horns,
    horn_radius
) {
    function nn(i) = i / (resolution - 1);

    function wiggle(i) =
        cos(360 * half_horns * nn(i)) * r;

    function px(i) =
        (major_radius(horn_radius) + wiggle(i)) *
        cos(360 * nn(i));

    function py(i) =
        (major_radius(horn_radius) + wiggle(i)) *
        sin(360 * nn(i));

    let (r = horn_radius)
    {
        polygon([ for (i = [0:n])
            [px(i), py(i)]
        ]);
    }
}


module wiggleplate_3d(resolution, horns, horn_radius) {
  difference() {
    linear_extrude(5, center=true)
      offset(shuttle_track_width / 2)
        wiggleplate(resolution, horns, horn_radius);
    linear_extrude(10, center=true)
      offset(-shuttle_track_width / 2)
        wiggleplate(resolution, horns, horn_radius);
  }
}

color("red")
  wiggleplate_3d(n, half_n_horns, r);

color("green")
  translate([0, 0, 3])
  rotate([0, 0, 360 / (2 * half_n_horns)])
    wiggleplate_3d(n, half_n_horns, r);

for (i = [0:(2*half_n_horns)])
    translate([
        major_radius(r) * cos(180 * i / half_n_horns),
        major_radius(r) * sin(180 * i / half_n_horns),
        0
    ])
        cylinder(h=20, r=(r - 10), center=true);
