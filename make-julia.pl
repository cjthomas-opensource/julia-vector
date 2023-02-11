#!/usr/bin/perl
# Julia set vector-drawing generator. Written by Christopher Thomas.

#
# Includes

use strict;
use warnings;


#
# Documentation

my ($helpscreen);
$helpscreen = << 'Endofblock';

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

Endofblock


#
# Constants

# There are two problems with trying to use Argand coordinates in the SVG file.

# The first problem is that the canvas starts at 0,0, full stop. So, we'd have
# to offset the origin so that all coordinates were positive.

# The second problem is that some conversion tools insist on treating canvas
# coordinates as pixels, giving us an upscaling of a blurred 4-pixel picture
# even if other tools interpret the vector drawing correctly.

# So, we'll do the conversion explicitly, and flip the imaginary axis to
# to map Cartesian conventions to image file conventions while we're at it.

my ($svg_pixels, $argand_radius);

$svg_pixels = 800;
$argand_radius = 2.2;

# We're approximating curves using line segments, by deforming a circle.
# Choose an adequately-smooth number of line segments.

my ($circsegments);
#$circsegments = 36;
$circsegments = 72;
#$circsegments = 180;



#
# Functions


# This generates one or more curves representing the Julia set boundary at
# a given iteration depth.
# This actually walks through all depths from 0..N, but since each is twice
# as complicated as the previous one, the overhead for this is acceptable.
# Arg 0 is the real component of the set's C value.
# Arg 1 is the imaginary component of the set's C value.
# Arg 2 is the iteration depth (with iteration 0 being a circle of radius 2).
# Arg 3 is the number of line segments to use for the iteration 0 circle.
# This returns a reference to a list containing lists of closed curve vertices
# (stored as Ar, Ai, Br, Bi, Cr, Ci, ...).

sub GetJuliaContours
{
  my ($creal, $cimag, $icount, $circsegcount, $pathlist_p);

  $pathlist_p = [];

  $creal = $_[0];
  $cimag = $_[1];
  $icount = $_[2];
  $circsegcount = $_[3];


  # Build the limiting circle.

  my ($circpath_p, $tinc, $tidx);

  $circpath_p = [];
  $tinc = 3.14159265 * 2.0 / $circsegcount;

  for ($tidx = 0; $tidx < $circsegcount; $tidx++)
  {
    $$circpath_p[$tidx + $tidx] = 2.0 * cos($tidx * $tinc);
    $$circpath_p[$tidx + $tidx + 1] = 2.0 * sin($tidx * $tinc);
  }

  $pathlist_p = [ $circpath_p ];


  # Iterate as many times as requested.

  my ($itidx, $test_re, $test_im, $test_mag2);
  my ($scratch);

  # Our test point starts at 0,0.
  $test_re = 0;
  $test_im = 0;

  for ($itidx = 0; $itidx < $icount; $itidx++)
  {
    # Move the test point. z <- z^2 + c.

    $scratch = $test_re * $test_re - $test_im * $test_im;
    $test_im = 2.0 * $test_re * $test_im;
    $test_re = $scratch;

    $test_re += $creal;
    $test_im += $cimag;

    # See if the test point is inside or outside the limiting circle.
    # This tells us if we're still connected.

    $test_mag2 = $test_re * $test_re + $test_im * $test_im;


    # Generate two new paths for each old path.
    # If we're connected, they get concatenated. Otherwise they get stored
    # separately.

    my ($oldpathlist_p, $pidx, $oldpath_p, $firstpath_p, $secondpath_p);
    my ($vidx, $old_re, $old_im, $old_mag, $old_ang, $new_re, $new_im);

    $oldpathlist_p = $pathlist_p;
    $pathlist_p = [];

    for ($pidx = 0; defined ($oldpath_p = $$oldpathlist_p[$pidx]); $pidx++)
    {
      # Initialize the two paths.
      $firstpath_p = [];
      $secondpath_p = [];


      # Build the first path from the positive roots.
      # Store the positive and negative roots in different lists.

      for ($vidx = 0; defined $$oldpath_p[$vidx]; $vidx += 2)
      {
        # If b = a^2 + c, then a = sqrt(b - c).

        $old_re = $$oldpath_p[$vidx];
        $old_im = $$oldpath_p[$vidx+1];

        $old_re -= $creal;
        $old_im -= $cimag;


        # FIXME - Brute force the square root in polar coordinates.
        # Solving it algebraically is faster than doing arctan but is a
        # pain in the tail.

        $old_mag = sqrt( $old_re * $old_re + $old_im * $old_im );
        # FIXME - Handle the undefined case by fiat.
        $old_ang = 0;
        if ( ($old_re * $old_re + $old_im * $old_im) > 1e-20 )
        { $old_ang = atan2($old_im, $old_re); } # Range is -pi..+pi.

        # Square root in polar coordinates.
        $old_mag = sqrt($old_mag);
        $old_ang = 0.5 * $old_ang;  # Range is -pi/2..+pi/2.

        # New point in the right half-plane.
        $new_re = $old_mag * cos($old_ang);
        $new_im = $old_mag * sin($old_ang);

        # Store the positive roots.
        $$firstpath_p[$vidx] = $new_re;
        $$firstpath_p[$vidx+1] = $new_im;
      }


      # Since the curve isn't guaranteed to be in the right half-plane,
      # flip the sign of points to minimize discontinuities.

      my ($listsize);
      my ($this_re, $this_im, $next_re, $next_im);
      my ($thisdiff, $flipdiff);

      for ($vidx = 2; defined $$firstpath_p[$vidx]; $vidx += 2)
      {
        $this_re = $$firstpath_p[$vidx-2];
        $this_im = $$firstpath_p[$vidx-1];
        $next_re = $$firstpath_p[$vidx];
        $next_im = $$firstpath_p[$vidx+1];

        $thisdiff = ($next_re - $this_re) * ($next_re - $this_re)
          + ($next_im - $this_im) * ($next_im - $this_im);
        # A - (-B) = A + B.
        $flipdiff = ($next_re + $this_re) * ($next_re + $this_re)
          + ($next_im + $this_im) * ($next_im + $this_im);

        if ($flipdiff < $thisdiff)
        {
          $$firstpath_p[$vidx] = - $next_re;
          $$firstpath_p[$vidx+1] = - $next_im;
        }
      }


      # Rotate the list so that the discontinuity between the first list
      # and the 180 degree flipped list is as small as possible.

      my ($bestdiff, $bestidx);
      my (@scratchpoints);

      $bestdiff = 100; # Actual limit is 4, within the bounding circle.
      $bestidx = undef;
      $listsize = scalar(@$firstpath_p);

      for ($vidx = 0; defined $$firstpath_p[$vidx]; $vidx += 2)
      {
        $this_re = $$firstpath_p[$vidx];
        $this_im = $$firstpath_p[$vidx+1];
        $next_re = - $$firstpath_p[($vidx+2) % $listsize];
        $next_im = - $$firstpath_p[($vidx+3) % $listsize];

        $thisdiff = ($next_re - $this_re) * ($next_re - $this_re)
          + ($next_im - $this_im) * ($next_im - $this_im);

        if ($thisdiff < $bestdiff)
        {
          $bestdiff = $thisdiff;
          # Store the location of the point _after_ the jump.
          $bestidx = ($vidx+2) % $listsize;
        }
      }

      # Perform the rotation.

      @scratchpoints = @$firstpath_p;
      $firstpath_p = [];

      for ($vidx = 0; $vidx < $listsize; $vidx++)
      {
        $$firstpath_p[$vidx] =
          $scratchpoints[ ($vidx + $bestidx) % $listsize ];
      }


      # Now that the endpoints are lined up, store negative roots in the
      # second path.

      for ($vidx = 0; defined $$firstpath_p[$vidx]; $vidx++)
      { $$secondpath_p[$vidx] = - $$firstpath_p[$vidx]; }


      # If we're connected, concatenate. Otherwise store them as two lists.

      if ($test_mag2 <= 4)
      {
        push @$firstpath_p, @$secondpath_p;
        push @$pathlist_p, $firstpath_p;
      }
      else
      {
        push @$pathlist_p, $firstpath_p;
        push @$pathlist_p, $secondpath_p;
      }
    }
  }


  return $pathlist_p;
}



# This converts a list of Julia set paths into one or more SVG polygons.
# Arg 0 points to a list of lists containing real and imaginary coordinates
# of points on the paths (stored as Ar, Ai, Br, Bi, Cr, Ci, ...).
# Arg 1 is the width of the SVG image in user units (pixels).
# Arg 2 is the radius of the region of interest on the Argand plane.
# This returns a string containing svg <polygon /> elements.

sub GetSVGPolygons
{
  my ($pathlist_p, $svg_width, $argand_rad, $svg_text);
  my ($pidx, $thispoly_p, $vidx, $thisline);
  my ($thisx, $thisy, $svg_mid, $scale_factor);

  $svg_text = '';

  $pathlist_p = $_[0];
  $svg_width = $_[1];
  $argand_rad = $_[2];


  $svg_mid = int($svg_width / 2);
  $scale_factor = $svg_mid / $argand_rad;

  for ($pidx = 0; defined ($thispoly_p = $$pathlist_p[$pidx]); $pidx++)
  {
    $thisline = '<polygon points="';

    for ($vidx = 0; defined $$thispoly_p[$vidx]; $vidx += 2)
    {
      if ($vidx > 0)
      { $thisline .= ' '; };

      $thisline .= sprintf( '%.3f',
        $svg_mid + $$thispoly_p[$vidx] * $scale_factor );
      # Flip the Y axis to go from Cartesian to image coordinates.
      $thisline .= sprintf( ',%.3f',
        $svg_mid - $$thispoly_p[$vidx+1] * $scale_factor );
    }

    $thisline .= '" fill="none" stroke="black"/>' . "\n";

    $svg_text .= $thisline;
  }

  return $svg_text;
}



#
# Main Program

my ($oname, $ctext, $ifirst, $ilast);
my ($need_help, $is_ok);
my ($creal, $cimag);


# Fetch arguments.

$oname = $ARGV[0];
$ctext = $ARGV[1];
$ifirst = $ARGV[2];
$ilast = $ARGV[3];


# Sanity check this to death.

$need_help = 0;
$is_ok = 0;

if ( (defined $oname) && (defined $ctext)
  && (defined $ifirst) && (defined $ilast) )
{
  if ($ctext =~ m/^([+-]?(\d\.)?\d+)([+-](\d\.)?\d+)i$/)
  {
    $creal = $1;
    $cimag = $3;

    if ( ($ifirst =~ m/^\d+$/) && ($ilast =~ m/^\d+$/) )
    {
      # Promote explicitly, before arithmetic checks.
      $ifirst = int($ifirst);
      $ilast = int($ilast);

      if ( ($ifirst >= 0) && ($ilast >= $ifirst) )
      {
        # Everything looks okay.
        $is_ok = 1;
      }
      else
      {
        print "###  \"$ifirst to $ilast\" doesn't look like a valid"
          . " iteration count range.\n";
      }
    }
    else
    {
      print "###  Iteration counts \"$ifirst\" and \"$ilast\""
        . " don't look like numbers.\n";
    }
  }
  else
  {
    print "###  Couldn't parse \"$ctext\" as a complex number.\n";
  }
}
else
{ $need_help = 1; }



if ($need_help)
{
  print $helpscreen;
  $is_ok = 0;
}


if ($is_ok)
{
  if (!open(OUTFILE, ">$oname"))
  {
    print "###  Couldn't write to \"$oname\".\n";
  }
  else
  {
    my ($pathlist_p);
    my ($itidx);

    print OUTFILE '<svg width="' . $svg_pixels . '" height="' . $svg_pixels
      . '" viewbox="0 0 ' . $svg_pixels . ' ' . $svg_pixels
      . '" xmlns="http://www.w3.org/2000/svg">' . "\n";

    for ($itidx = $ifirst; $itidx <= $ilast; $itidx++)
    {
      $pathlist_p = GetJuliaContours($creal, $cimag, $itidx, $circsegments);
      print OUTFILE GetSVGPolygons($pathlist_p, $svg_pixels, $argand_radius);
    }

    print OUTFILE '</svg>' . "\n";
  }
}


#
# This is the end of the file.
