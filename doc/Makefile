.DEFAULT_GOAL: pdf
.PHONY: clean

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
