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
