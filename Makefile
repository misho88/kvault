BIN ?=/usr/local/bin
all: requirements

requirements:
	pip install -r requirements.txt || echo "Maybe retry with sudo -H?"

install:
	install kvault $(BIN)
	install kpassgen $(BIN)

uninstall:
	rm -f $(BIN)/$(SCRIPT)
