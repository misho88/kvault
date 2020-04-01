SCRIPT=kvault
BIN ?=/usr/local/bin
all: requirements

requirements:
	pip install -r requirements.txt || echo "Maybe retry with sudo -H?"

install:
	install $(SCRIPT) $(BIN)

uninstall:
	rm -f $(BIN)/$(SCRIPT)
