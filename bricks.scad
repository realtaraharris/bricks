brickHeight = 0.75;
brickWidth = 1;
mortarThickness = 1 / 10;
brickLength = (2 * brickWidth) + mortarThickness;
bm = brickLength + mortarThickness;

w = (10 * bm) - mortarThickness;
d = (10 * bm) - mortarThickness;

simple = [[0, 0], [w, 0], [w, d], [0, d]];
complex = [[0, 0], [w, 0], [w, d], [0, d],
          [0, 8.5 * bm], [8.5 * bm, 8.5 * bm], [8.5 * bm, 4.95 * bm], [0, 4.95 * bm],
          [0, 3.5 * bm], [8.5 * bm, 3.5 * bm], [8.5 * bm, 1.45 * bm], [0, 1.45 * bm]];
secondWythe = [[-0.1, -0.1], [-0.1, d + 0.1], [w + 0.1, d + 0.1], [w + 0.1, -0.1]];

dispv(complex);
for (i = [0 : 10]) {
    wallify(complex, i * (brickHeight + mortarThickness), i % 2, false);
}

translate ([30, 0, 0]) {
    dispv(simple);
    for (i = [0 : 20]) {
        wallify(simple, i * (brickHeight + mortarThickness), i % 2, false);
        wallify(secondWythe, i * (brickHeight + mortarThickness), i % 2, true);
    }
}

module wallify (v, h, isCourseEven, insideOut) {
    length = len(v) - 1;
    for (i = [0 : length]) {
        if (i < length) {
            course(concat(v[i], [h]), concat(v[i + 1], [h]), isCourseEven, i % 2, insideOut);
        } else {
            course(concat(v[length], [h]), concat(v[0], [h]), isCourseEven, i % 2, insideOut);
        }
    }
}

module course(p1, p2, isCourseEven, isWallEven, insideOut) {
    // translate line to angles. why is this function not built-in to OpenSCAD?
    Xdist = p2[0] - p1[0];
    Ydist = p2[1] - p1[1];
    Zdist = p2[2] - p1[2];
    length = norm([Xdist, Ydist, Zdist]); // radial distance
    b = acos(Zdist / length); // inclination angle
    c = atan2(Ydist, Xdist); // azimuthal angle

    translate(p1) {
        rotate([0, b, c]) {
            if (!insideOut) {
                halfStepLength = (brickLength + mortarThickness) / 2;
                adjWallOffset = isWallEven
                    ? halfStepLength
                    : 0;

                offset = isCourseEven
                    ? ((brickLength - mortarThickness) / 2) + mortarThickness
                    : 0;

                if (isCourseEven) {
                    runningBond(length - offset, offset - adjWallOffset);
                } else {
                    runningBond(length - offset - adjWallOffset, offset + adjWallOffset);
                }
            } else {
                halfStepLength = (brickLength - mortarThickness) / 2;

                if (isCourseEven) {
                    runningBond(length - mortarThickness, !isWallEven ? - halfStepLength : mortarThickness);
                } else {
                    runningBond(length - mortarThickness, isWallEven ? - halfStepLength : mortarThickness);
                }
            }
        }
    }
}

module runningBond(length, offset) {
    delta = brickLength + mortarThickness;
    start = offset;

    for (i = [start : delta : length]) {
        translate([- brickHeight, 0, i]) {
            color("#8b4f39", 1.0) { cube([brickHeight, brickWidth, brickLength]); }
        }
    }
}

module dispv (v) {
    indi = [[for (i = [0: len(v) - 1]) i]];

    color("gray", 1.0) {
        translate([0, 0, -0.5]) {
            // hull()
            polygon(points = v, paths = indi);
        }
    }
}
