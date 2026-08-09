/*
 * poly-partition-js v1.0.2 - https://github.com/x6ud/poly-partition-js
 * Modified from PolyPartition (https://github.com/ivanfratric/polypartition)
 * MIT License, Copyright (c) 2020 x6ud
 * Vendored as a UMD build exposing the global `PolyPartition`.
 */
!function(e){if("object"==typeof exports&&"undefined"!=typeof module)module.exports=e();else if("function"==typeof define&&define.amd)define([],e);else{var f;"undefined"!=typeof window?f=window:"undefined"!=typeof global?f=global:"undefined"!=typeof self&&(f=self),f.PolyPartition=e()}}(function(){
var exports = {};
"use strict";


// Signed area.
function area(a, b, c) {
    return (b.y - a.y) * (c.x - b.x) - (b.x - a.x) * (c.y - b.y);
}
// Whether corner of a counterclockwise polygon is convex.
function isConvex(p1, p2, p3) {
    return area(p1, p2, p3) < 0;
}
// Whether point is inside a corner of a counterclockwise polygon.
function inCone(p1, p2, p3, p) {
    var convex = isConvex(p1, p2, p3);
    if (convex) {
        return isConvex(p1, p2, p) && isConvex(p2, p3, p);
    }
    else {
        return isConvex(p1, p2, p) || isConvex(p2, p3, p);
    }
}
function equals(a, b) {
    return a.x === b.x && a.y === b.y;
}
// Check if two lines intersect.
function intersects(p11, p12, p21, p22) {
    if (equals(p11, p21) || equals(p11, p22) || equals(p12, p21) || equals(p12, p22)) {
        return false;
    }
    var v1ortX = p12.y - p11.y;
    var v1ortY = p11.x - p12.x;
    var v2ortX = p22.y - p21.y;
    var v2ortY = p21.x - p22.x;
    var v21X = p21.x - p11.x;
    var v21Y = p21.y - p11.y;
    var dot21 = v21X * v1ortX + v21Y * v1ortY;
    var v22X = p22.x - p11.x;
    var v22Y = p22.y - p11.y;
    var dot22 = v22X * v1ortX + v22Y * v1ortY;
    var v11X = p11.x - p21.x;
    var v11Y = p11.y - p21.y;
    var dot11 = v11X * v2ortX + v11Y * v2ortY;
    var v12X = p12.x - p21.x;
    var v12Y = p12.y - p21.y;
    var dot12 = v12X * v2ortX + v12Y * v2ortY;
    return !(dot11 * dot12 > 0 || dot21 * dot22 > 0);
}
function isClockwise(polygon) {
    var sum = 0;
    for (var i = 0, len = polygon.length; i < len; ++i) {
        var p1 = polygon[i];
        var p2 = polygon[(i + 1) % len];
        sum += (p2.x - p1.x) * (p2.y + p1.y);
    }
    return sum > 0;
}
exports.isClockwise = isClockwise;
/**
 * Removes holes from polygon by merging them with non-hole.
 */
function removeHoles(polygon, holes, doNotCheckOrdering) {
    if (doNotCheckOrdering === void 0) { doNotCheckOrdering = false; }
    if (!doNotCheckOrdering) {
        if (isClockwise(polygon)) {
            console.error('Polygon should be counterclockwise');
            throw new Error('Polygon should be counterclockwise');
        }
        holes.forEach(function (hole) {
            if (!isClockwise(hole)) {
                console.error('Hole should be clockwise');
                throw new Error('Hole should be clockwise');
            }
        });
    }
    holes = holes.slice();
    while (holes.length) {
        // find the hole point with the largest x
        var holeIndex = -1;
        var holePointIndex = -1;
        var holeLargestX = -Infinity;
        for (var i = 0, holesLen = holes.length; i < holesLen; ++i) {
            var hole_1 = holes[i];
            for (var j = 0, holeLen = hole_1.length; j < holeLen; ++j) {
                var point = hole_1[j];
                var x = point.x;
                if (x > holeLargestX) {
                    holeLargestX = x;
                    holeIndex = i;
                    holePointIndex = j;
                }
            }
        }
        // find the farthest polygon vertex on X axis, without polyPoint-holePoint intersects with any edge
        var holePoint = holes[holeIndex][holePointIndex];
        var polyLen = polygon.length;
        var polyPointIndex = -1;
        for (var i = 0; i < polyLen; ++i) {
            var p1 = polygon[(i + polyLen - 1) % polyLen];
            var p2 = polygon[i];
            var p3 = polygon[(i + 1) % polyLen];
            if (!inCone(p1, p2, p3, holePoint)) {
                continue;
            }
            var polyPoint = p2;
            if (polyPointIndex >= 0) {
                var bestPoint = polygon[polyPointIndex];
                var v1x = polyPoint.x - holePoint.x;
                var v1y = polyPoint.y - holePoint.y;
                var v1Len = Math.sqrt(v1x * v1x + v1y * v1y);
                var v2x = bestPoint.x - holePoint.x;
                var v2y = bestPoint.y - holePoint.y;
                var v2Len = Math.sqrt(v2x * v2x + v2y * v2y);
                if (v2x / v2Len > v1x / v1Len) {
                    continue;
                }
            }
            var pointVisible = true;
            for (var j = 0; j < polyLen; ++j) {
                var lineP1 = polygon[j];
                var lineP2 = polygon[(j + 1) % polyLen];
                if (intersects(holePoint, polyPoint, lineP1, lineP2)) {
                    pointVisible = false;
                    break;
                }
            }
            if (pointVisible) {
                polyPointIndex = i;
            }
        }
        if (polyPointIndex < 0) {
            console.error('Failed to find cutting point. There may be self-intersection in the polygon.');
            throw new Error('Failed to find cutting point. There may be self-intersection in the polygon.');
        }
        var newPoly = [];
        for (var i = 0; i <= polyPointIndex; ++i) {
            newPoly.push(polygon[i]);
        }
        var hole = holes[holeIndex];
        for (var i = 0, len = hole.length; i <= len; ++i) {
            newPoly.push(hole[(i + holePointIndex) % len]);
        }
        for (var i = polyPointIndex; i < polyLen; ++i) {
            newPoly.push(polygon[i]);
        }
        polygon = newPoly;
        holes.splice(holeIndex, 1);
    }
    return polygon;
}
exports.removeHoles = removeHoles;
function updateVertex(vertex, vertices) {
    if (!vertex.shouldUpdate) {
        return;
    }
    vertex.shouldUpdate = false;
    var v1 = vertex.prev.point;
    var v2 = vertex.point;
    var v3 = vertex.next.point;
    vertex.isConvex = isConvex(v1, v2, v3);
    var v1x = v1.x - v2.x;
    var v1y = v1.y - v2.y;
    var v1Len = Math.sqrt(v1x * v1x + v1y * v1y);
    v1x /= v1Len;
    v1y /= v1Len;
    var v3x = v3.x - v2.x;
    var v3y = v3.y - v2.y;
    var v3Len = Math.sqrt(v3x * v3x + v3y * v3y);
    v3x /= v3Len;
    v3y /= v3Len;
    vertex.angleCos = v1x * v3x + v1y * v3y;
    if (vertex.isConvex) {
        vertex.isEar = true;
        for (var i = 0, len = vertices.length; i < len; ++i) {
            var curr = vertices[i];
            if (!curr.isActive || curr === vertex) {
                continue;
            }
            if (equals(v1, curr.point) || equals(v2, curr.point) || equals(v3, curr.point)) {
                continue;
            }
            var areaA = area(v1, curr.point, v2);
            var areaB = area(v2, curr.point, v3);
            var areaC = area(v3, curr.point, v1);
            if (areaA > 0 && areaB > 0 && areaC > 0) {
                vertex.isEar = false;
                break;
            }
            if (areaA === 0 && areaB >= 0 && areaC >= 0) {
                if (area(v1, curr.prev.point, v2) > 0 || area(v1, curr.next.point, v2) > 0) {
                    vertex.isEar = false;
                    break;
                }
            }
            if (areaB === 0 && areaA >= 0 && areaC >= 0) {
                if (area(v2, curr.prev.point, v3) > 0 || area(v2, curr.next.point, v3) > 0) {
                    vertex.isEar = false;
                    break;
                }
            }
            if (areaC === 0 && areaA >= 0 && areaB >= 0) {
                if (area(v3, curr.prev.point, v1) > 0 || area(v3, curr.next.point, v1) > 0) {
                    vertex.isEar = false;
                    break;
                }
            }
        }
    }
    else {
        vertex.isEar = false;
    }
}
function removeCollinearOrDuplicate(start) {
    for (var curr = start, end = start;;) {
        if (equals(curr.point, curr.next.point)
            || area(curr.prev.point, curr.point, curr.next.point) === 0) {
            curr.prev.next = curr.next;
            curr.next.prev = curr.prev;
            curr.prev.shouldUpdate = true;
            curr.next.shouldUpdate = true;
            if (curr === curr.next) {
                break;
            }
            end = curr.prev;
            curr = curr.next;
            continue;
        }
        curr = curr.next;
        if (curr === end) {
            break;
        }
    }
}
/**
 * Triangulation by ear clipping.
 */
function triangulate(polygon, doNotCheckOrdering) {
    if (doNotCheckOrdering === void 0) { doNotCheckOrdering = false; }
    if (!doNotCheckOrdering) {
        if (isClockwise(polygon)) {
            console.error('Polygon should be counterclockwise');
            throw new Error('Polygon should be counterclockwise');
        }
    }
    if (polygon.length < 4) {
        return [polygon];
    }
    var len = polygon.length;
    var vertices = [];
    var triangles = [];
    // init
    for (var i = 0; i < len; ++i) {
        vertices.push({
            isActive: true,
            isConvex: false,
            isEar: false,
            point: polygon[i],
            angleCos: 0,
            shouldUpdate: true,
            index: i
        });
    }
    for (var i = 0; i < len; ++i) {
        var vertex = vertices[i];
        vertex.prev = vertices[(i + len - 1) % len];
        vertex.next = vertices[(i + 1) % len];
    }
    vertices.forEach(function (vertex) { return updateVertex(vertex, vertices); });
    for (var i = 0; i < len - 3; ++i) {
        var ear = null;
        // find the most extruded ear
        for (var j = 0; j < len; ++j) {
            var vertex = vertices[j];
            if (!vertex.isActive || !vertex.isEar) {
                continue;
            }
            if (!ear) {
                ear = vertex;
            }
            else if (vertex.angleCos > ear.angleCos) {
                ear = vertex;
            }
        }
        if (!ear) {
            for (var i_1 = 0; i_1 < len; ++i_1) {
                var vertex = vertices[i_1];
                if (vertex.isActive) {
                    var p1 = vertex.prev.point;
                    var p2 = vertex.point;
                    var p3 = vertex.next.point;
                    if (Math.abs(area(p1, p2, p3)) > 1e-5) {
                        console.error('Failed to find ear. There may be self-intersection in the polygon.');
                        throw new Error('Failed to find ear. There may be self-intersection in the polygon.');
                    }
                }
            }
            break;
        }
        triangles.push([ear.prev.point, ear.point, ear.next.point]);
        ear.isActive = false;
        ear.prev.next = ear.next;
        ear.next.prev = ear.prev;
        ear.prev.shouldUpdate = true;
        ear.next.shouldUpdate = true;
        removeCollinearOrDuplicate(ear.next);
        if (i === len - 4) {
            break;
        }
        for (var i_2 = 0; i_2 < len; ++i_2) {
            updateVertex(vertices[i_2], vertices);
        }
    }
    for (var i = 0; i < len; ++i) {
        var vertex = vertices[i];
        if (vertex.isActive) {
            vertex.prev.isActive = false;
            vertex.next.isActive = false;
            var p1 = vertex.prev.point;
            var p2 = vertex.point;
            var p3 = vertex.next.point;
            if (Math.abs(area(p1, p2, p3)) > 1e-5) {
                triangles.push([p1, p2, p3]);
            }
        }
    }
    return triangles;
}
exports.triangulate = triangulate;
/**
 * Convex partition using Hertel-Mehlhorn algorithm.
 */
function convexPartition(polygon, doNotCheckOrdering) {
    if (doNotCheckOrdering === void 0) { doNotCheckOrdering = false; }
    //check if the poly is already convex
    var convex = true;
    for (var i = 0, len = polygon.length; i < len; ++i) {
        if (!isConvex(polygon[(i + len - 1) % len], polygon[i], polygon[(i + 1) % len])) {
            convex = false;
            break;
        }
    }
    if (convex) {
        return [polygon];
    }
    var ret = [];
    var triangles = triangulate(polygon, doNotCheckOrdering);
    for (; triangles.length;) {
        var poly = triangles.splice(0, 1)[0];
        for (var iPoly = 0, polyLen = poly.length; iPoly < polyLen; ++iPoly) {
            var diag1 = poly[iPoly];
            var diag2 = poly[(iPoly + 1) % polyLen];
            // find diagonal
            var tri3 = null;
            var iTri2 = 0;
            for (; iTri2 < triangles.length; ++iTri2) {
                var triangle = triangles[iTri2];
                for (var i = 0; i < 3; ++i) {
                    var tri1 = triangle[i];
                    var tri2 = triangle[(i + 1) % 3];
                    if (equals(diag1, tri2) && equals(diag2, tri1)) {
                        tri3 = triangle[(i + 2) % 3];
                        break;
                    }
                }
                if (tri3) {
                    break;
                }
            }
            if (!tri3) { // not a diagonal
                continue;
            }
            if (area(poly[(iPoly + polyLen - 1) % polyLen], diag1, tri3) > 0) { // neither convex nor on the same line
                continue;
            }
            if (area(tri3, diag2, poly[(iPoly + 2) % polyLen]) > 0) {
                continue;
            }
            // merge triangle
            var newPoly = [];
            for (var i = (iPoly + 1) % polyLen; i != iPoly; i = (i + 1) % polyLen) {
                newPoly.push(poly[i]);
            }
            newPoly.push(diag1, tri3);
            poly = newPoly;
            polyLen = newPoly.length;
            iPoly = -1;
            triangles.splice(iTri2, 1);
        }
        ret.push(poly);
    }
    return ret;
}
exports.convexPartition = convexPartition;
return exports;
});
