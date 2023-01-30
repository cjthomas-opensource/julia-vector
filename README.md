# Julia Set Vector Drawing Generator

## Overview

This script renders Julia sets as SVG images.

Julia sets are fractals that look a bit like the more famous Mandelbrot set
(the Mandelbrot set is an index of all of the Julia sets, showing which are
connected and which are disconnected).

As you iterate the generator equation, the edge of the fractal gets more and
more detailed and convoluted. This makes them a great stress-test for CNC
engraving and cutting machines.

The purpose of this script is to generate vector graphics that can be
imported into CAM software and converted into drawings and/or toolpaths. I
considered exporting to the DXF drawing format directly, but SVG had far
fewer headaches (and can be viewed in a web browser).


## Script Documentation

[[include:./auxiliary/helpscreen.md]]

## Gallery

![A connected Julia set.](./plots/julia-connected.svg)

![A disconnected Julia set.](./plots/julia-disconnected.svg)


_(This is the end of the file.)_
