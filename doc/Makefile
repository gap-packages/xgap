manual: manual.dvi

manual.dvi: 	gobject.msk posetops.msk xgap.msk usercomm.msk manual.tex \
		diffgap3.tex graphs.tex install.tex menus.tex posets.tex \
		savetime.tex sgrplats.tex sheets.tex whatis.tex manual.bib
	../../../etc/buildman.pe -f buildman.config
	tex manual
	bibtex manual
	tex manual
	makeindex manual
	tex manual
	tex manual

clean:
	rm -f manual.dvi

