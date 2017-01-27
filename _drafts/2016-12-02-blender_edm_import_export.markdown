---
layout: post
title:  "A Blender Import/Exporter for DCS World"
date:   2016-12-02 23:45:00 +0000
categories: python blender dcs edm
excerpt_separator: <!--more-->
private: true
---

Since I delved into the world of virtual reality after buying a Vive headset
earlier this year - using Brexit as an excuse (this reality sucks, therefore I
can buy an expensive new toy), I've been getting more into flight simulators,
and in particular [DCS World][dcs], a rather decent comprehensiev military
simulator that happened to be one of the first to jump onto the VR bandwagon.
Even with the low resolution afforded by current generation headsets, this is
clearly a genre made for VR, and the immersion is amazing.

Anyway, I started searching for some sort of documentation on the `.edm`
model format used by DCS, or an importer - initially as part of a plan to
measure some of the more complicated in-cockpit panels, to allow exact-scale
replication. Having found nothing but frustration that the only tools available
are the 3DS Max exporters, and that these were only available for the older
2014 edition, I decided to start having a poke at the file format.

The result was this Blender addon - [Blender_ioEDM][repo].

<!--more-->

I've been a big fan of [Blender][blender] for many years now - ever since they
changed to the 2.5 series and revamped the user interface - I had tried to get
into it before that, but prior versions really did seem to have an extremely
alien and pathologically unfriendly user interface. I've dabbled in modelling
and rendering over the years, and so whilst I'd not consider myself an expert,
I am at least familiar with most of the standard tools.

One of the great things about Blender is that the UI is very heavily moddable
with, and all of the capabilities exposed to - Python. This makes it very easy
to create a plugin to import and export, especially one that isn't a giant 
opaque binary blob.




[dcs]: https://www.digitalcombatsimulator.com
[repo]: https://github.com/ndevenish/Blender_ioEDM
[blender]: https://www.blender.org/
