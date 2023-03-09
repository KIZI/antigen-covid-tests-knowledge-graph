.DEFAULT_GOAL: pdf
.PHONY: clean

latex:
	pandoc \
		--filter pandoc-crossref \
		--citeproc \
		--from markdown+implicit_figures+backtick_code_blocks+smart+definition_lists \
		--output article.tex \
		--template template.tex \
		--variable citecolor=orange \
		--variable linkcolor=orange \
		--variable urlcolor=orange \
		metadata.yaml \
		article.md

latex2pdf:
	latexmk \
		-pdf \
		article.tex \
		&& \
	latexmk \
		-c \
		article.tex

pdf:
	pandoc \
		--filter pandoc-crossref \
		--citeproc \
		--from markdown+implicit_figures+backtick_code_blocks+smart+definition_lists \
		--output article.pdf \
		--pdf-engine xelatex \
		--template template.tex \
		--variable citecolor=orange \
		--variable linkcolor=orange \
		--variable urlcolor=orange \
		metadata.yaml \
		article.md

clean:
	rm -f article.pdf
