TEXMK := "latexmk"
TEXOUTDIR := "latex.out"
TEXFLAGS := "-pdflua -output-directory=" + TEXOUTDIR

_default:
    @just template

# {{{ pdf

[private]
pdf basename:
    {{ TEXMK }} {{ TEXFLAGS }} {{ basename }}.tex
    {{ TEXMK }} {{ TEXFLAGS }} {{ basename }}.tex
    @cp {{ TEXOUTDIR }}/{{ basename }}.pdf .

[doc("Build template example")]
template:
    @just pdf template

[doc("Compile preview for template")]
preview: template
    magick \
        -verbose \
        template.pdf \
        -quality 100 \
        -flatten \
        -sharpen 0x1.0 \
        -geometry 1024x \
        template.png

# }}}

# {{{ assets

[doc("Swap the blue with white in a given logo")]
white logo:
    magick {{ logo }}.png \
        -fuzz 10% \
        -channel RGB \
        -fill '#FFFFFF' -opaque '#306BB3' \
        {{ logo }}-white.png

[doc("Trim a given logo")]
trim logo:
    magick {{ logo }}.png -trim +repage {{ logo }}.png

[doc("Trim and square a given logo")]
square logo:
    magick {{ logo }}.png -trim +repage \
        -set option:side "%[fx:max(w,h)]" \
        -gravity center -background none -extent "%[side]x%[side]" \
        -resize 1024x1024 \
        {{ logo }}.png

# }}}

# {{{ linting

[doc("Format source files")]
format: yamlfmt mdformat justfmt

[doc("Format tex files with badness")]
texfmt:
    badness format template.tex uvt-letterhead.sty
    @echo -e "\e[1;32mbadness clean!\e[0m"

[doc("Format YAML files with yamlfmt")]
yamlfmt:
    yamlfmt -gitignore_excludes .
    @echo -e "\e[1;32myamlfmt clean!\e[0m"

[doc("Format markdown files with mdformat")]
mdformat:
    python -m mdformat .
    @echo -e "\e[1;32mmdformat clean!\e[0m"

[doc("Run just --fmt over the justfile")]
justfmt:
    just --unstable --fmt
    @echo -e "\e[1;32mjust --fmt clean!\e[0m"

[doc("Run all linting checks over the source code")]
lint: typos badness

[doc("Check for typos (using typos)")]
typos:
    typos --sort --config typos.toml
    @echo -e "\e[1;32mtypos clean!\e[0m"

[doc("Lint using badness")]
badness:
    badness lint template.tex beamercolorthemeuvtposter.sty
    @echo -e "\e[1;32mbadness clean!\e[0m"

# }}}

# {{{ develop

[doc("Update license text")]
license:
    python -m reuse download CC-BY-4.0 MIT
    cp LICENSES/CC-BY-4.0.txt LICENSE
    cp LICENSES/MIT.txt LICENSE.MIT
    @rm -rf LICENSES

[doc("Create a convenient zip file with the template files")]
zip:
    zip -9 -r "$(basename $(pwd)).zip" assets *.sty template.tex

[doc("Remove temporary compilation files")]
clean:
    rm -rf {{ TEXOUTDIR }}
    rm -rf *.aux *.log *.out

[doc("Remove all generated files")]
purge: clean
    rm -rf *.png *.pdf

# }}}
