// ===== INFORMATION ===== //
/* 
Handle meant to be printed with the large top face on the baseplate.
See accompanying engineering drawing for parameter definitions. 
Set T-Slot variables to zero to exclude them from the model. 
Set mouse ears diameter to zero to exclude them (you probably want them to reduce warping at the corners)

https://github.com/kennetek/parametric-handle
*/

// ===== FUNCTIONS ===== //
function ang2vec(a) = [cos(a), sin(a)];
function normalize(v) = v/norm(v);  

// ===== PARAMETERS ===== //

/* [Setup Parameters] */
$fs = 1;
$fa = 5; 

/* [General Settings] */
h_internal = 33;  // 0.01
h_thick = 17; // 0.01
h_base = 20; // 0.01
h_wide = 26;  // 0.01
h_hole = 140; // 0.01
r_internal = 16;  // 0.01
a_flare = 10; // [0:40]
a_draft = 3;  // 0.01
r_fillet_int = 6; // 0.01
r_fillet_ext = 3;  // 0.01
d_hole = 6;  // 0.01
d_counter = 12; // 0.01
h_counter = 10; // 0.01
h_layer = 0.3;  // 0.01

/* [T-Slot Pegs] */
h_slot_width = 0;  // 0.01
h_slot_depth = 0;  // 0.01

/* [Mouse Ears] */
d_mouse = 0;  // 0.01


// ===== CALCULATIONS ===== //

at = tan(a_flare);
ac = cos(a_flare);
as = sin(a_flare);

off = r_internal*2; 
p0 = [-off,-off];
p1 = [-off, h_internal-r_internal];
p2 = [0.5*(h_hole-h_base) - p1[1]*at - r_internal/ac, p1[1]]; 
p3 = [p2[0]+(p1[1]+off)*at, -off];

p4 = p2 + ang2vec(a_flare)*(r_internal+h_base*ac);
v1 = ang2vec(180-(0.5*(90+45+a_flare)-10));
r_large = ((h_internal+h_thick - p4[1])/v1[1])/(2*sin(0.5*(90-46-a_flare)));
p5 = p4 + r_large*ang2vec(180+a_flare);
p6 = p5+h_hole*[-1,0]+h_internal*[0,-1];
p7 = p5+h_hole*[-1,0];
p8 = p5 + h_internal*ang2vec(270+a_flare);


// ===== IMPLEMENTATION ===== //

color("tomato")
rotate([90,0,0])
copy_mirror([1,0,0])
difference() {
    intersection() {
        
        // internal profile
        minkowski() {
            difference() {
                linear_extrude(h_wide-2*r_fillet_int+0.01, center=true)
                difference() {
                    translate([0,-h_slot_depth])
                    square([h_hole+2*h_base,2*(h_internal+h_thick+h_slot_depth)]);
                    offset(delta=r_fillet_int)
                    minkowski() {
                        polygon([p0, p1, p2, p3]);
                        circle(r=r_internal);
                    }
                }
                copy_mirror([0,0,1])
                taper(r_fillet_int);
            }
            sphere(r=r_fillet_int);
        }
        
        // external profile
        minkowski() {
            difference() {
                linear_extrude(h_wide-2*r_fillet_ext, center=true)
                offset(delta = -r_fillet_ext)
                minkowski() {
                    polygon([p6, p7, p5, p8]); 
                    circle(r=r_large);
                }
                copy_mirror([0,0,1])
                taper(r_fillet_ext);
            }
            sphere(r=r_fillet_ext);
        }
        
        // cut to size
        translate([0,-h_slot_depth,-h_wide])
        cube([h_hole+h_base*2, h_internal+h_thick+h_slot_depth, h_wide*2]);
    }
    
    // top chamfer
    copy_mirror([0,0,1])
    translate(normalize([0, -1, 1])*(r_fillet_ext*5))
    translate([-1, h_internal+h_thick, h_wide/2 - r_fillet_ext - (h_internal+h_thick)*tan(a_draft)])
    rotate([-45, 0, 0])
    cube([h_hole+h_base*2+1, r_fillet_ext*10, r_fillet_ext*10]);
    
    // hole
    translate([h_hole/2, 0, 0])
    rotate([-90, 0, 0])
    cylinder(d=d_hole, h=(h_internal+h_thick)*3, center=true);
    
    // counterbore
    translate([h_hole/2, h_counter, 0])
    rotate([-90, 0, 0])
    cylinder(d=d_counter, h=(h_internal+h_thick)*3);
    
    // slit for printable hole
    translate([h_hole/2, h_counter-h_layer, 0])
    rotate([-90, 0, 0])
    intersection() {
        cylinder(d=d_counter, h=(h_internal+h_thick)*3);
        cube([d_hole, d_counter*3, (h_internal+h_thick)*4],center=true); 
    }
    
    // Alignment tabs for attaching to aluminum extrusion
    if (h_slot_depth > 0 || h_slot_width > 0) {
        intersection() {
            union() {
                copy_mirror([0,0,1])
                mirror([0,1,0])
                translate([0,-d_hole,h_slot_width/2])
                cube([h_hole+h_base*2, (h_slot_depth+d_hole)*2, h_wide]);
                
                translate([h_hole/2, 1.1*d_hole/2, -h_wide])
                rotate([0,0,-135])
                cube([h_slot_depth*10, h_slot_depth*10, h_wide*2]);
            }
            mirror([0,1,0])
            translate([-h_base*0.5,0,-h_wide*5])
            cube([h_hole+h_base*3, (h_slot_depth+d_hole)*4, h_wide*10]);
        }
    }
}

// mouse ears to prevent warping at corners
if (d_mouse > 0)
copy_mirror([0,1,0])
copy_mirror([1,0,0])
translate([p5[0]+r_large/sqrt(2),h_wide/2-(h_internal+h_thick)*tan(a_draft)-r_fillet_ext,h_internal+h_thick-h_layer-0.001])
cylinder(d=d_mouse, h=h_layer);


// ===== MODULES ===== //

module copy_mirror(vec=[0,1,0]) {
    children();
    if (vec != [0,0,0]) 
    mirror(vec) 
    children();
} 

module taper(off = 0) {
    if (a_draft > 0) {
        translate([0, 0, h_wide/2-off])
        rotate([-a_draft, 0, 0])
        translate([-5*h_hole, -5*(h_internal+h_thick), 0])
        cube([h_hole*10, (h_internal+h_thick)*10, h_wide*3]);
    }
}
