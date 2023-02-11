# Julia set vector-drawing generator - Testing Makefile.

default:
	@echo "Targets:  clean test docs"

clean:
	rm -f plots/*

plotdir: clean
	-rmdir plots
	mkdir plots

julia: clean plotdir
	./make-julia.pl plots/julia-connected.svg -1+0.34i 0 10
	./make-julia.pl plots/julia-disconnected.svg -1.5+1.1i 0 8

# NOTE - We need to bracket the help text in "```" for Markdown.
docs:
	rm -f auxiliary/*
	-rmdir auxiliary
	mkdir auxiliary
	@echo '```' > auxiliary/helpscreen-julia.md
	./make-julia.pl >> auxiliary/helpscreen-julia.md
	@echo '```' >> auxiliary/helpscreen-julia.md

# This is the end of the file.
