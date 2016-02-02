
SELENIUMVERSION=2.50
SELENIUMJAR=selenium-server-standalone-$(SELENIUMVERSION).1.jar
SELENIUMPID=$(shell ps -ef | grep  'selenium-server-standalone-$(SELENIUMVERSION).1.jar$$' | cut -d ' ' -f 2-3)

help:
	@echo "This Makefile is intended to execute the GUI tests."

all: test

# Update the node packages
update:
	sudo npm update

$(SELENIUMJAR):
	@echo "Getting selenium server $(SELENIUMJAR) ..."
	curl -O https://selenium-release.storage.googleapis.com/$(SELENIUMVERSION)/$(SELENIUMJAR)

launchselenium: $(SELENIUMJAR)
ifneq (,$(SELENIUMPID))
	@echo "Selenium server $(SELENIUMJAR) is already running. Process id: $(SELENIUMPID)"
else
	@echo "Starting selenium server $(SELENIUMJAR) ..."
	java -jar $(SELENIUMJAR) &
	sleep 5
endif

test: launchselenium
	npm test


.PHONY: all test update launchselenium
