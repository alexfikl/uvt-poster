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

[doc("Compile assets for example")]
assets: build
    @mkdir -p images
    magick \
        -verbose \
        -density 300 \
        template.pdf \
        -quality 100 \
        -flatten \
        -sharpen 0x1.0 \
        -geometry 2048x \
        images/template.png

[doc("Update license text")]
license:
    python -m reuse download CC-BY-4.0 MIT
    cp LICENSES/CC-BY-4.0.txt LICENSE
    cp LICENSES/MIT.txt LICENSE.MIT
    @rm -rf LICENSES

[doc("Remove temporary compilation files")]
clean:
    rm -rf {{ TEXOUTDIR }}
    rm -rf *.aux *.log *.out

[doc("Remove all generated files")]
purge: clean
    rm -rf *.pdf
