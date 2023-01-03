// Based on "trapezoid curve" from:
// Ma et. al., Mathematical Models in Engineering Dec 2015
// Vol 1 Issue 2

// Center-to-center distance between horns
horn_center_center = 110;
// Specify half number of horns to enforce evenness
half_n_horns = 8;

////////////////////////////////////////
// Derived quantities
////////////////////////////////////////
n_horns = 2 * half_n_horns;
horn_radius = horn_center_center / 2;
// angle between the x axis anad the horn.
// phi in the paper
horn_io_angle = 360 / (n_horns * 2);

module track_profile(
  // Radius of the primary motion
  radius=100,
  // Angle to the next segment
  io_angle=15,
  // portion of the circle devoted to the transition to the
  // next segment
  transition_region_angle=15,
  // Number of segments to use when rendering
  n=360,
) {
  function nn(i) = i / (n - 1);
  function ia(i) = 360 * i / (n - 1);

  function r(i) = (ia(i) > 2 * io_angle) ?
    radius : (
      ((2 * radius) / (PI + 2)) *
      (ia(i) / transition_region_angle)
    );

  function px(i) =
    r(i) * cos(ia(i));

  function py(i) =
    r(i) * sin(ia(i));

  polygon([for (i = [0:n])
    [px(i), py(i)]
  ]);
}

track_profile();
