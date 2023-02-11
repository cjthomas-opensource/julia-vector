# Julia set vector-drawing generator - Testing Makefile.

default:
	@echo "Targets:  clean docs thumbnails julia"

clean:
	rm -f plots/*

plotdir: clean
	-rmdir plots
	-mkdir plots

julia: clean plotdir
	./make-julia.pl plots/julia-connected.svg -1+0.34i 0 10
	./make-julia.pl plots/julia-disconnected.svg -1.3+1.2i 0 8
	./make-julia.pl plots/julia-tree.svg -1.65+0i 0 10
	./make-julia.pl plots/julia-islands.svg -1+0.4i 0 10

auxdir:
	-rmdir auxiliary
	-mkdir auxiliary

# NOTE - We need to bracket the help text in "```" for Markdown.
docs: auxdir
	rm -f auxiliary/helpscreen*
	@echo '```' > auxiliary/helpscreen-julia.md
	./make-julia.pl >> auxiliary/helpscreen-julia.md
	@echo '```' >> auxiliary/helpscreen-julia.md

THUMBFLAGS=-resize 400x400
thumbnails: auxdir julia
	rm -f auxdir/thumbnail*
	convert $(THUMBFLAGS) \
		plots/julia-connected.svg auxiliary/julia-connected.png
	convert $(THUMBFLAGS) \
		plots/julia-disconnected.svg auxiliary/julia-disconnected.png
	convert $(THUMBFLAGS) \
		plots/julia-tree.svg auxiliary/julia-tree.png
	convert $(THUMBFLAGS) \
		plots/julia-islands.svg auxiliary/julia-islands.png

# This is the end of the file.
