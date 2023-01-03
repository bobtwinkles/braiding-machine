import numpy as np

trap_curve = np.loadtxt('data/modified_trapezoid.txt')

# number of horns
n_horns = 12
assert (360 % n_horns) == 0
# Proportion of the circle to use as a transition between the radial travel
# path and the tangent handoff
leadin_angle_degrees = 25
# assuming the clockwise cam is oriented horizontally, the angle from
# horizontal to the counterclockwise cam
handoff_angle_degrees = 360 // n_horns
# radius of the constant arc
horn_radius = 100
# half the width of the bobbin carrier pin
track_radius = 10
# radius at the peak of the handoff point
handoff_r = horn_radius / np.cos(np.deg2rad(leadin_angle_degrees))

################################################################################
## profile section definitions
################################################################################
def interp_trap(thetas, theta_0, theta_1, r_0, r_1):
    """
    Interpolate between (theta_0, r_0) and (theta_0, r_1) using the modified
    trapezoid acceleration curve outputing the radius values for the given
    thetas
    """
    theta_range = theta_1 - theta_0
    r_range = r_1 - r_0
    xs = (thetas - theta_0) / theta_range

    return np.interp(xs, trap_curve[:,0], trap_curve[:,1]) * r_range + r_0

def interp_tangent(thetas, theta_0, theta_1, r):
    """
    Generates a line tangent to the circle of radius r starting at theta_0 and
    ending at theta_1
    """
    beta = theta_1 - theta_0
    thetas = thetas - theta_1
    return r / np.cos(np.deg2rad(thetas))

def interp_constant(thetas, r_0):
    """
    Generate a constant radius for each of the supplied theta values
    """
    return np.full_like(thetas, r_0)

# Segments around the bobbin path, from the point of view of a cam sitting at
# (0,0).
# Adjacent cams are:
#  - 0 degrees (the "clockwise" cam)
#  - 180 + handoff_angle_degrees (the "counterclockwise" cam)
#
# List format is (segment length, segment function), ordered in ccw
# takeup/handoff terminology assumes the horn gear for this cam is rotating ccw
#
# The segment function takes a start and end argument specifying the theta range,
# to evaluate at and a vector of theta values requesting specific points
def seg_trap_cw(s, e, v):
    return interp_trap(v, s, e, handoff_r, horn_radius)

def seg_trap_ccw(s, e, v):
    # use the symetry of the trapezoid to avoid needing to reverse the thetas list
    return interp_trap(v, e, s, handoff_r, horn_radius)

def seg_tangent_cw(s, e, v):
    return interp_tangent(v, s, e, horn_radius)

def seg_tangent_ccw(s, e, v):
    # use the symetry of the trapezoid to avoid needing to reverse the thetas list
    return interp_tangent(v, e, s, horn_radius)

def seg_constant(s, e, v):
    return interp_constant(v, horn_radius)

def plot_curve(segments, outf_name):
    total_deg = 0
    with open(outf_name, 'w') as outf:
        for (angle, type) in segments:
            s_total_deg = total_deg
            e_total_deg = total_deg + angle
            print(f'{s_total_deg:3} - {total_deg:3} {type}')

            thetas = np.linspace(s_total_deg, e_total_deg)
            rs = type(s_total_deg, e_total_deg, thetas)
            rs_inner = rs - track_radius
            rs_outer = rs + track_radius

            rad_thetas = np.deg2rad(thetas)
            xs = rs * np.cos(rad_thetas)
            ys = rs * np.sin(rad_thetas)
            xs_inner = rs_inner * np.cos(rad_thetas)
            ys_inner = rs_inner * np.sin(rad_thetas)
            xs_outer = rs_outer * np.cos(rad_thetas)
            ys_outer = rs_outer * np.sin(rad_thetas)
            for (theta, r, x, y, x_i, y_i, x_o, y_o) in zip(thetas, rs, xs, ys, xs_inner, ys_inner, xs_outer, ys_outer):
                outf.write(f'{theta} {r} {x} {y} {x_i} {y_i} {x_o} {y_o }\n')

            total_deg = e_total_deg

segments = [
    # takeup from the cw cam, for bobbins ccw bobbins
    (leadin_angle_degrees, seg_trap_cw),
    # outer arc (ccw bobbin path)
    (180 + handoff_angle_degrees - 2 * leadin_angle_degrees, seg_constant),
    # handoff to the ccw cam for ccw bobbins
    (leadin_angle_degrees, seg_trap_ccw),
    # takeup from the ccw cam for cw bobbins
    (leadin_angle_degrees, seg_trap_cw),
    # inner arc (cw bobbin path)
    (180 - handoff_angle_degrees - 2 * leadin_angle_degrees, seg_constant),
    # handoff to the cw cam for cw bobbins
    (leadin_angle_degrees, seg_trap_ccw),
]

plot_curve(segments, 'cam_points.txt')

segments = [
    # takeup from the cw cam, for bobbins ccw bobbins
    (leadin_angle_degrees, seg_tangent_cw),
    # outer arc (ccw bobbin path)
    (180 + handoff_angle_degrees - 2 * leadin_angle_degrees, seg_constant),
    # handoff to the ccw cam for ccw bobbins
    (leadin_angle_degrees, seg_tangent_ccw),
    # takeup from the ccw cam for cw bobbins
    (leadin_angle_degrees, seg_tangent_cw),
    # inner arc (cw bobbin path)
    (180 - handoff_angle_degrees - 2 * leadin_angle_degrees, seg_constant),
    # handoff to the cw cam for cw bobbins
    (leadin_angle_degrees, seg_tangent_ccw),
]

plot_curve(segments, 'cam_points_tangent.txt')
