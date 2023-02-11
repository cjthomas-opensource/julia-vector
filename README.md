# Fractal Vector Drawing Generator

## Overview

This is a collection of scripts that generate vector graphics of the
outlines of various fractals, in SVG format.

The motivation for this was to be able to import fractal curves into CAM
software to convert to toolpaths to stress-test accuracy. I considered
exporting to the DXF drawing format directly, but SVG had far fewer
headaches (and can be viewed in a web browser).

SVG can, of course, be converted into pretty pictures as well.

## Julia Set Script

This script renders Julia sets as SVG images.

Julia sets are fractals that look a bit like the more famous Mandelbrot set
(the Mandelbrot set is an index of all of the Julia sets, showing which are
connected and which are disconnected).

As you iterate the generator equation, the edge of the fractal gets more and
more detailed and convoluted.

### Script Documentation

<!-- NOTE - We have to copypasta this, since GitHub has no embed feature. -->
```

This program generates Julia set contours, saving the result in SVG format.

Usage: make-julia <output file> <C value> <first iteration> <last iteration>

The "C" value has the form "+/-AAA+/-BBBi" (e.g. "-0.5+0.3i"). This should
be inside a circle of radius 2 (i.e.: A^2 + B^2 < 4).

Iteration 0 is a circle of radius 2. Other iterations are connected or
disconnected curves nested inside each other (and inside this circle).


A Julia set is the set of starting points Z that do not escape to infinity
when iterating Z <- Z^2 + C, where Z and C are complex numbers (a + b*i).

The better-known Mandelbrot set is an index of Julia sets: Julia sets with
C values that are inside the body of the Mandelbrot set are connected, while
Julia sets that are outside the body start connected but become disconnected
after some number of iterations.

```

### Gallery

![A connected Julia set.](./plots/julia-connected.svg =400x400)
![A disconnected Julia set.](./plots/julia-disconnected.svg =400x400)

![An almost-connected Julia set.](./plots/julia-islands.svg =400x400)
![A tree-shaped Julia set.](./plots/julia-tree.svg 400x400)


_(This is the end of the file.)_
