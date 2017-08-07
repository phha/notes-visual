PREFIX ?= /usr
DESTDIR ?=
BINDIR ?= $(PREFIX)/bin
LIBDIR ?= $(PREFIX)/lib
MANDIR ?= $(PREFIX)/share/man

all:
	@echo "Note store is a shell script, so there is nothing to do. Try \"make install\" instead."

install:
	install -v -d "$(DESTDIR)$(BINDIR)/" && install -m 0755 -v src/notes-visual.sh "$(DESTDIR)$(BINDIR)/nv"

uninstall:
	@rm -vrf \
		"$(DESTDIR)$(BINDIR)/nv" \

.PHONY: install uninstall
