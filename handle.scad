// handle
$fs = 1;
$fa = 5; 

function ang2vec(a) = [cos(a), sin(a)];
function normalize(v) = v/norm(v);  

h_internal = 33; 
h_thick = 17;
h_base = 20;
h_wide = 26; 
h_hole = 130;
r_internal = 16; 
a_flare = 10; 
r_fillet_int = 6;
r_fillet_ext = 3; 
d_hole = 6; 
d_counter = 10;
h_counter = 20;

at = tan(a_flare);
ac = cos(a_flare);
as = sin(a_flare);

off = r_internal*2; 
p0 = [-off,-off];
p1 = [-off, h_internal-r_internal];
p2 = [0.5*(h_hole-h_base) - p1[1]*at - r_internal/ac, p1[1]]; 
p3 = [p2[0]+(p1[1]+off)*at, -off];

p4 = p2 + ang2vec(a_flare)*(r_internal+h_base*ac);
v1 = ang2vec(180-(0.5*(90+46+a_flare)-10));
r_large = ((h_internal+h_thick - p4[1])/v1[1])/(2*sin(0.5*(90-46-a_flare)));
p5 = p4 + r_large*ang2vec(180+a_flare);
p6 = p5+h_hole*[-1,0]+h_internal*[0,-1];
p7 = p5+h_hole*[-1,0];
p8 = p5 + h_internal*ang2vec(270+a_flare);


color("tomato")
rotate([90,0,0])
copy_mirror([1,0,0])
difference() {
    intersection() {
        minkowski() {
            linear_extrude(h_wide-2*r_fillet_int+0.01, center=true)
            difference() {
                square([h_hole+2*h_base,2*(h_internal+h_thick)]);
                offset(delta=r_fillet_int)
                minkowski() {
                    polygon([p0, p1, p2, p3]);
                    circle(r=r_internal);
                }
            }
            sphere(r=r_fillet_int);
        }
        minkowski() {
            linear_extrude(h_wide-2*r_fillet_ext, center=true)
            offset(delta = -r_fillet_ext)
            minkowski() {
                polygon([p6, p7, p5, p8]); 
                circle(r=r_large);
            }
            sphere(r=r_fillet_ext);
        }
        translate([0,0,-h_wide])
        cube([h_hole+h_base*2, h_internal+h_thick, h_wide*2]);
    }

    copy_mirror([0,0,1])
    translate(normalize([0, -1, 1])*(r_fillet_ext*5))
    translate([-1, h_internal+h_thick, h_wide/2 - r_fillet_ext])
    rotate([-45, 0, 0])
    cube([h_hole+h_base*2+1, r_fillet_ext*10, r_fillet_ext*10]);
    
    translate([h_hole/2, 0, 0])
    rotate([-90, 0, 0])
    cylinder(d=d_hole, h=(h_internal+h_thick)*3, center=true);
    
    translate([h_hole/2, h_counter, 0])
    rotate([-90, 0, 0])
    cylinder(d=d_counter, h=(h_internal+h_thick)*3);
}

module copy_mirror(vec=[0,1,0]) {
    children();
    if (vec != [0,0,0]) 
    mirror(vec) 
    children();
} 
