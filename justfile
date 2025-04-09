TEXMK := "latexmk"
TEXOUTDIR := "latex.out"
TEXFLAGS := "-pdflua -output-directory=" + TEXOUTDIR

_default:
    @just --list

[private]
pdf basename:
    {{ TEXMK }} {{ TEXFLAGS }} {{ basename }}.tex
    {{ TEXMK }} {{ TEXFLAGS }} {{ basename }}.tex
    @cp {{ TEXOUTDIR }}/{{ basename }}.pdf .

[doc("Build template example")]
build:
    @just pdf template

[doc("Update license text")]
license:
    python -m reuse download CC-BY-4.0
    cp LICENSES/CC-BY-4.0.txt LICENSE
    @rm -rf LICENSES

[doc("Remove temporary compilation files")]
clean:
    rm -rf {{ TEXOUTDIR }}
    rm -rf *.aux *.log *.out

[doc("Remove all generated files")]
purge: clean
    rm -rf *.pdf
