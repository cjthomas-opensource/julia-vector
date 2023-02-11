# Julia set vector-drawing generator - Testing Makefile.

default:
	@echo "Targets:  clean docs julia"

clean:
	rm -f plots/*

plotdir: clean
	-rmdir plots
	mkdir plots

julia: clean plotdir
	./make-julia.pl plots/julia-connected.svg -1+0.34i 0 10
	./make-julia.pl plots/julia-disconnected.svg -1.3+1.2i 0 8
	./make-julia.pl plots/julia-tree.svg -1.65+0i 0 10
	./make-julia.pl plots/julia-islands.svg -1+0.4i 0 10

# NOTE - We need to bracket the help text in "```" for Markdown.
docs:
	rm -f auxiliary/*
	-rmdir auxiliary
	mkdir auxiliary
	@echo '```' > auxiliary/helpscreen-julia.md
	./make-julia.pl >> auxiliary/helpscreen-julia.md
	@echo '```' >> auxiliary/helpscreen-julia.md

# This is the end of the file.
