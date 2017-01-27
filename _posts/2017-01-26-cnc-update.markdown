---
layout: post
title:  "CNC Update"
date:   2017-01-26 22:00:00 +0000
categories: cnc making
excerpt_separator: <!--more-->
private: true
---

So I spent some time today working with the CNC Machine, as I've got a project that I want to use it for (and am interested in getting finer-detail work done than with a 3D printer).

Firstly, I didn't actually get to cutting anything - the water cooling system looked mothballed - and without knowing if it's just not set up yet, or was done for a good reason, I didn't want to immediately plug it all in again. And with no idea about the specs or model of the spindle, I couldn't look up what would be safe to run with air-cooling only.

<!--more-->

What I decided to do instead with this limitation was [swap out][plotterish] the router bit for a sharpie - and use it as an elaborate plotter. This also means that accidents only killed a pen, rather than a potentially expensive drill bit and the table along with it (the table already shows evidence of such accidents!). 

This is also a useful capability because permanent sharpie apparently works well as etch-resist (for making custom PCBs). I managed to kill [three sharpies][deadsharpie] (and maimed one), but have a good handle on why, now, for which I'll go into detail below.

Here's a video of my final test (with the maimed sharpie, which is why the lines are so thick):
<iframe width="560" height="315" src="https://www.youtube.com/embed/UvXsnTRo4J0" frameborder="0" allowfullscreen></iframe>

It might have been partly to do with the sharpie, but I had to reasonably overcompensate the Z-position for drawing - pushing it down a bit far in certain places. This could be indication of an uneven bed, but only by a few fractions of a mm so probably not a big issue until we actually try fine machining - getting the basics is probably more important. If we actually want to use it for proper plotting, then a spring-loaded pen holder is probably better because it'll be mush less sensitive to this.

Note that the noise is rather immense - and this is without actual cutting. I suspect the joints need to be cleaned/lubricated, so researching the maintenance of these machines is going to be one of my next tasks.

Hardware
--------
Here's what I've been able to discern about the hardware:

- The frame appears to be an [OpenBuilds C-Beam Platemaker][cnc]
- Plugging into the USB gives serial access to a [GRBL][grbl]-firmware device. This firmware is slightly out-of-date (0.9 vs the current 1.1) but means that controlling the frame is pretty well supported
- A Huanyang [VFD] (Variable frequency drive) drives the spindle. A copy of the manual can be found [here][VFDmanual], though I assume the settings are correct and locked (need to confirm this and make a copy of them). This isn't CNC-controlled at the moment, so RPM needs to be dialled in manually - but it is theoretically possible to tie into the GRBL firmware.
- An unlabelled spindle. It seems similar in appearance to most chinese water-cooled spindles, but without markings I have no way to verify the spec (there may be some covered up by the mount, but I didn't want to dismantle this to check). Assuming that the VFD is configured properly most the specs should be retrievable.
- A water pump and reservoir (plastic crate) under the table. This is currently not connected.
- A Wooden box. This restricts the Z carriage movement to what looks like half of it's range


Software
--------
The CNC uses [G-Code][GCode], similarly to a 3D Printer. Because CNC is somewhat more complicated than 3D printing, I've been finding it helpful to use a simple program to send commands - because it's clear exactly what is going on and what commands are being sent. I've been using [Universal G-Code Sender][Universal], but also tried [bCNC]. Everything I've seen has capabilities for moving the mill head, and resetting the working
coordinate system. 

The rough set of steps that I've been following:

1. Generate the G-Code file from your CAM package (see below). This means you should be aware of where the CAM package expected the origin to be, and what sort of stock you are cutting into
2. In a convenient X-Y position, carefully lower the Z-axis until the tool is touching (barely!) the top of your work material. Using the pen, as it approached the board I went down to 0.1mm steps until a piece of paper left a consistent pen streak whilst being moved. Then, zero the Z-axis *only*. 
3. Move the Z-axis up out of the way
4. Position the tool X and Y positions to match the expected origin point over the workpiece. Depending on what you are doing, this may not need to be so precise - e.g. for plotting you don't care *precisely* where on the paper the design is plotted. Then zero the X and Y axes.
5. Steps 2-4 can be done at the same time if the exact origin position is appropriate
6. Optionally, move the mill to a neutral position
7. Load the G-Code file, and view (or activate) the visualizer. UniversalGCodeSender has a specific line in the visualization that appears to draw from the origin along to the start point and up, so when e.g. plotting you can see if this makes sense (and doesn't go below zero).
6. Send the G-Code file, but be ready to hit the "cut power" button if anything unexpected happens, like plowing into the bed or damaging the tip. It's better to have to set the working space up again than to break something.

It's important to be precise setting the Z-axis, because being wrong can cause the tool to crash into the material (and e.g. kill the sharpie. You **don't** want to kill a metal tip rotating at several thousand RPM). If you aren't exactly sure on this, you can place the Z-axis higher than the deepest cut, and do a 'test run' - I used this to test plotting, watching the machine position to ensure that it didn't go into negative working space.

G28 Issue
---------
I'd urge anyone using the CNC, especially with Fusion360, to watch the following video on the [G28] command and machine position - it certainly cleared a few things up from me.

<iframe width="560" height="315" src="https://www.youtube.com/embed/jgnR0LKIBAQ" frameborder="0" allowfullscreen></iframe>

Fusion 360, by default, issues G28 at the start of the exported G-Code file, which is very likely to either crash the head or hit an axis limit - destroying any working space calibration. Unless deliberately using this, I'd advise issuing the `G28.1` command immediately upon startup because then it'll be zero relative to the initial machine position.


Generating G-Code
-----------------
I've been using [Fusion360] for most of my CAD, and since it has pretty comprehensive CAM module I thought I'd try and leverage that. This wasn't simple, because simply, fusion is designed to work with 3D objects and you have to jump through lots of hoops to get a decent, properly positioned 2D toolpath. [Inkscape] has a [GCodeTools][InkscapeTools] extension that claims to convert arbitrary paths - but I couldn't get this to work today. There also claim to be several other packages that do this, but I didn't try anything else, and muddled through with fusion (which has many excellent options for 3D otherwise).

Things I learnt to check when doing 2D CAM in Fusion:

- I had good results with the 2D "Contour" action, because this traces along line edges rather than cuts inside of them
- Click the "Heights" tab when settings up the action, and make sure that the 'cutting' (e.g. drawing) level is level with the origin of your system. You may need to set up the origin to be level with the stock (and because it isn't designed for 2D, you need to have stock). And simulate with the sender before sending - mismatches here were the cause of almost all the pen-kills.
- Vertical lead-in radius can be very useful, because it means that rather than thumping the pen down on the page it uses a curve to move it towards the paper, and when lifting from the paper

Summary of issues
=================
- The wooden box built around it seems to limit the Z-movement to about half of it's range. This might be a problem using larger router bits. It's certainly a problem with some reset commands that e.g. try to move the axis to the extreme +Z
- GRBL firmware is out-of-date - without knowing any custom settings or alterations (if any) I don't want to just clear it
- Motion can be VERY noisy - especially at low x (furthest from the stepper). 
- No water cooling connected

Questions for moving forwards:

- What is the spindle model/specs?
- Is the water-cooling disconnected for a reason?
- Is there any custom firmware alterations?



[cnc]: http://openbuilds.org/builds/c-beam%E2%84%A2-machine-plate-maker.2020/
[grbl]: https://github.com/gnea/grbl
[VFD]: https://en.wikipedia.org/wiki/Variable-frequency_drive
[VFDmanual]: http://www.cnczone.com/forums/spindles-vfd/117782-huanyang-chinese-vfd-settings-manual.html


<!-- ![Swift and Python combined output](/images/PTS_output.png) -->


[deadsharpie]: /images/2017-01-26%2017.53.52.jpg
[plotterish]: /images/2017-01-26%2015.58.06.jpg



[GCode]: https://en.wikipedia.org/wiki/G-code
[Universal]: https://github.com/winder/Universal-G-Code-Sender
[bCNC]: https://github.com/vlachoudis/bCNC
[G28]: http://www.linuxcnc.org/docs/2.5/html/gcode/gcode.html#sec:G28-G28_1
[Fusion360]: http://www.autodesk.com/products/fusion-360/overview
[Inkscape]: https://inkscape.org/en/
[InkscapeTools]: https://github.com/cnc-club/gcodetools
