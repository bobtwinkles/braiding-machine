import sympy as sp
sp.init_printing()

h = sp.Symbol("h")

a_0 = sp.Symbol("a_0")
v_0 = sp.Symbol("v_0")
r_0 = sp.Symbol("r_0")

seg_start, seg_width = sp.symbols('theta_0 beta')

theta = sp.Symbol("theta")
t = (theta - seg_start) / seg_width

def motion_equations(a):
    """
    Compute the motion equations of an object following the provided acceleration profile
    """
    vel = sp.integrate(a, (theta, seg_start, theta)) + v_0
    pos = sp.integrate(vel, (theta, seg_start, theta)) + r_0

    return {
        'r': pos,
        'v': vel,
        'a': a
    }

accel_linear = a_0
seg_linear = motion_equations(accel_linear)
print('Linear Segment equations computed')

accel_sin = a_0 * sp.sin(sp.pi * t / 2)
seg_sin = motion_equations(accel_sin)
print('Sin Segment equations computed')

accel_cos = a_0 * sp.cos(sp.pi * t / 2)
seg_cos = motion_equations(accel_cos)
print('Cos Segment equations computed')

accel_double_cos = a_0 * sp.cos(sp.pi * t)
seg_double_cos = motion_equations(accel_double_cos)
print('DoubleCos Segment equations computed')

def tagged_varname(tag, n):
    return n + '_' + tag

global_vars = {
    'theta'
}

def rename_all_free(f, tag, skip=global_vars):
    replacements = {}
    for symbol in f.free_symbols:
        if symbol.name in skip:
            continue
        replacements[symbol] = sp.Symbol(tagged_varname(tag, symbol.name))
    return f.subs(replacements)

class Segment:
    def __init__(self, motion_equations, tag):
        self.tag = tag
        self.motion_equations = {}
        for (n, f) in motion_equations.items():
            self.motion_equations[n] = rename_all_free(f, tag)

    def subs_all(self, consts):
        for (n, f) in self.motion_equations.items():
            self.motion_equations[n] = f.subs(consts)

    def sym(self, n):
        return sp.Symbol(tagged_varname(self.tag, n))

def c2_continuity(a, b):
    """
    Returns a list of equations representing the C2 continuity conditions
    between 2 Segments, mapping the end of A to the start of B.
    """
    theta_a_start = a.sym('theta_0')
    theta_b_start = b.sym('theta_0')
    beta_a = a.sym('beta')
    beta_b = b.sym('beta')
    theta_a_end = theta_a_start + beta_a
    theta_b_end = theta_b_start + beta_b
    # c0 continuity, start and end must align
    a_r = a.motion_equations['r']
    b_r = b.motion_equations['r']
    c0 = a_r.subs(theta, theta_a_end) - b_r.subs(theta, theta_b_start)
    c0 = sp.cancel(c0)
    c0 = sp.ratsimp(c0)

    # c1 continuity, start and end velocity must agree
    a_v = a.motion_equations['v']
    b_v = b.motion_equations['v']
    c1 = a_v.subs(theta, theta_a_end) - b_v.subs(theta, theta_b_start)
    c1 = sp.cancel(c1)
    c1 = sp.ratsimp(c1)

    # c2 continuity, start and end acceleration must agree
    a_a = a.motion_equations['a']
    b_a = b.motion_equations['a']
    c2 = a_a.subs(theta, theta_a_end) - b_a.subs(theta, theta_b_start)
    c2 = sp.cancel(c2)
    c2 = sp.ratsimp(c2)

    return [c0, c1, c2]

# Segments to solve for
segments = [
    Segment(seg_sin, 'A'),
    Segment(seg_linear, 'B'),
    Segment(seg_double_cos, 'C'),
    Segment(seg_linear, 'D'),
    Segment(seg_cos, 'E'),
]

# values for various constants
constants = {
    # Segment length constraints
    segments[0].sym('beta'): sp.Rational('1/8'),
    segments[1].sym('beta'): sp.Rational('1/4'),
    segments[2].sym('beta'): sp.Rational('1/4'),
    segments[3].sym('beta'): sp.Rational('1/4'),
    segments[4].sym('beta'): sp.Rational('1/8'),
    # Segment start location constraints
    segments[0].sym('theta_0'): 0,
    segments[1].sym('theta_0'): sp.Rational('1/8'),
    segments[2].sym('theta_0'): sp.Rational('3/8'),
    segments[3].sym('theta_0'): sp.Rational('5/8'),
    segments[4].sym('theta_0'): sp.Rational('7/8'),
}

# Apply to motion equations
for segment in segments:
    segment.subs_all(constants)

constraints = [
    # begin/end locations
    segments[0].motion_equations['r'].subs(theta, 0),
    segments[4].motion_equations['r'].subs(theta, 1) - h,
    # initial/final velocity
    segments[0].motion_equations['v'].subs(theta, 0),
    # Final velocity is up to the gods
    # segments[4].motion_equations['v'].subs(theta, 1),

    # Start and end accelerations are trivially 0, by structure of the sin/cos
    # lead-in/lead-out motion equations.
]

for (a, b) in zip(segments, segments[1:]):
    for constraint in c2_continuity(a, b):
        constraints.append(constraint.subs(constants))

# List of variables that fully constrain the 
characteristic_variables = list([
    v
    for s in segments
    for v in [s.sym('a_0'), s.sym('v_0'), s.sym('r_0')]
])

print('Attempt solve')
solns = sp.linsolve(constraints, characteristic_variables)
solns = list(solns)[0]

solved_variables = {
    v: s
    for (v, s) in zip(characteristic_variables, solns)
}

print('Plotting solution')

n_points = 1000
with open('data/modified_trapezoid.txt', 'w') as outf:
    outf.write('# theta r v a\n')
    for i in range(0, n_points):
        ni = i / (n_points - 1)
        r = 0
        v = 0
        a = 0
        for segment_idx in range(len(segments)):
            segment = segments[segment_idx]
            theta_0 = constants[segment.sym('theta_0')]
            beta = constants[segment.sym('beta')]
            if theta_0 < ni and ni <= theta_0 + beta:
                subs_group = {}
                subs_group.update(constants)
                subs_group.update(solved_variables)
                subs_group.update({h: 1, theta: ni})

                motion_equations = segment.motion_equations

                r = motion_equations['r'].evalf(subs=subs_group)
                v = motion_equations['v'].evalf(subs=subs_group)
                a = motion_equations['a'].evalf(subs=subs_group)
        outf.write(f'{ni} {r} {v} {a}\n')

print('Done')
