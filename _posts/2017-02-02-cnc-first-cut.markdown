---
layout: post
title:  "CNC - First Cuts"
date:   2017-02-02 21:45:00 +0000
categories: cnc making 3d printing rml
excerpt_separator: <!--more-->
private: true
---

Spent some time today working on the dual extrusion 3D printer, and moving
forward with using the CNC.

<!--more-->

Delta Rostock mini G2S
----------------------
Spent some time working on the [G2S] dual extruder. Went through full 
calibration and configuration procedure, including updating the firmware
with calibrated hardware offsets. Using the manufacturer-provided firmware
for now, a version of [Marlin] labelled 1.0.3 - slightly odd as the last 
stable release was 1.0.2-2. Ended up changing the following definitions:

    Z_PROBE_OFFSET_FROM_EXTRUDER      3.8
    MANUAL_Z_HOME_POS               201.5

and changed the firmware-configuration author to my name, so that anyone in
the future knows who to blame! Also calibrated the offset screws that trigger
the XYZ carriage endstops, so that the z-offset is reasonably clear over the
bed (Ended up 0.2mm off in the center, but thought this was close enough to
not worry about convexity).

Attempted to heat the hotend in order test extrusion and loading of filament.
After getting above/around 50°C Octoprint suddenly disconnected and the LCD
shows the error <tt>Err: MINTEMP</tt>. This seems to indicate that the 
temperature sensor was suddenly reporting zero - disconnecting from the
processing board and testing the connection to the thermistor with a
multimeter - no continuity was detected, which seems to indicate that there
is a break.

Solution to be determined, but will probably involve dismantling this part of
the hotend and manually checking the connections.


CNC Cutting
-----------

Started by setting up the water cooling system. 7.5L was enough to cover the
top of the pump, and the outlet pipe was taped into place inside the reservoir
to avoid leaking water over the floor (it is a rather short pipe). Currently
the air compressor is disconnected because the plug is powering the water pump
- this means that the pump is not connected to the emergency cutoff.

Dug around in the spare materials and found a decently firm foam, which I
thought would be a good material to start with. Designed a simple 5cm circular
indent in Fusion 360 and cut with a 6mm end mill. The [result][firstCut]
worked quite well - measuring exactly 50mm across one dimension, but slightly
off in the other - visibly noticed some motion of the material in the later
test so not necessarily a positioning problem. Started at 9000rpm and a feed
of 1000mm/min, but raised the rpm to 10500rpm after observing the edges
looking a little untidy.

After some more CAM work decided to try a two-pass cut of an approximate mold
shape for my panel knob. The first was a simple adaptive clearing at 6mm, and
the  [second][KnobCAM] a radial finishing-cut with 3.175mm. Cut at around
10000rpm. With similar feed rates to the first cut, but the foam is a pretty
forgiving material, so the real problem of calculating feed rates will come up
when moving to harder materials. Even so, could definitely observe some
deformation of the foam block whilst being machined. I was still pleased by
the [result][FoamKnob], and feel definite progress has been made.

I also spent some time on Tuesday measuring the end mills that we posess with
the intention of putting them into a shared Fusion360 tool library. All sizes
in mm. The larger and stand-alone flat end mills:

| Size | Shaft | Flute Length | Total Length | Flutes |
|------|-------|--------------|--------------|--------|
| 12   |    12 |           30 |           82 |      3 |
| 11   |    12 |           26 |           83 |      3 |
| 10   |    10 |           22 |           73 |      3 |
|  9   |    10 |           22 |           72 |      3 |
|  8   |     8 |           19 |           63 |      3 |
|  7   |     8 |           16 |           60 |      3 |
|  6   |     6 |           20 |           52 |      3 |
|  6   |     6 |           13 |           52 |      3 |
|  5   |     6 |           13 |           57 |      3 |
|  3   |     6 |            8 |           52 |      3 |
|  2   |     6 |            7 |           51 |      3 |

Of which the 2x6x7 is a pack of five identical mills. The small box of flat
end mills with colored rings around them:

| Size | Shaft | Flute Length | Total Length | Flutes | Body Length |
|------|-------|--------------|--------------|--------|-------------|
|  1.2 |     3 |        10.16 |           38 |      2 |          21 |
|  1.1 |     3 |           10 |           38 |      2 |          21 |
|  1.0 |     3 |           10 |           38 |      2 |          21 |
|  0.9 |     3 |           10 |           38 |      2 |          21 |
|  0.8 |     3 |           10 |           38 |      2 |          21 |
|  0.7 |     3 |          8.5 |           38 |      2 |          21 |
|  0.6 |     3 |          8.5 |           38 |      2 |          21 |
|  0.5 |     3 |            7 |           38 |      2 |          21 |
|  0.4 |     3 |            5 |           38 |      2 |          21 |
|  0.3 |     3 |          5.5 |           38 |      2 |          21 |

Where the colored rings mean there is a definite point at which the mill fits
into the collett, changing the body length. There is also a small box with
copper-colored flat end mills in them:

| Size | Shaft | Flute Length | Total Length | Flutes |
|------|-------|--------------|--------------|--------|
|  1.5 |     3 |           10 |           38 |      2 |
|  1.6 |     3 |           10 |           38 |      2 |
|  1.7 |     3 |           10 |           38 |      2 |
|  1.8 |     3 |           10 |           38 |      2 |
|  1.9 |     3 |           10 |           38 |      2 |
|  2.0 |     3 |           10 |           38 |      2 |
|  2.4 |     3 |           10 |           38 |      2 |
|  2.5 |     3 |           12 |           38 |      2 |
|  3.0 |     3.175 |       12 |           38 |      2 |
| 3.175 |    3.175 |       12 |           38 |      2 |

With slightly higher uncertainty of the exact values (not marked on the mill
as they are too small). 

And there is a box of 0.2mm 30° PCB copper engraving bits, which I am
currently unsure on how to represent as a mill tool.

It's possible to export a tool library into a shareable file from Fusion, but
since feed rates seem to be per-tool it looks like each end is tied to a
particular material, so I need to work out how you are supposed to represent
a common set of tools.

[G2S]: http://reprap.org/wiki/Delta_Rostock_mini_G2s
[Marlin]: https://github.com/MarlinFirmware/Marlin
[firstCut]: /images/2017-02-02-CNC_firstCut.jpg
[KnobCAM]: /images/2017-02-02-CAM.jpg
[FoamKnob]: /images/2017-02-02-foam_knob.jpg
