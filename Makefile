COFFEE = node_modules/.bin/coffee
MOCHA = node_modules/.bin/mocha --compilers coffee:coffee-script/register

JS_FILES = $(patsubst src/%.coffee,lib/%.js,$(shell find src -type f))
FIXTURES = $(patsubst %,%.html,$(shell find test/fixtures -type f -not -name '*.html'))


.PHONY: all
all: $(JS_FILES)

lib/%.js: src/%.coffee
	mkdir -p $(@D)
	cat $< | $(COFFEE) --compile --stdio > $@


.PHONY: fixtures
fixtures: $(FIXTURES)

test/fixtures/%.html: test/fixtures/%
	curl "$(shell cat $<)" --output $@ --silent


.PHONY: clean
clean:
	rm -f $(JS_FILES)
	rm -f $(FIXTURES)


.PHONY: release-patch release-minor release-major
VERSION = $(shell node -p 'require("./package.json").version')
release-patch: NEXT_VERSION = $(shell node -p 'require("semver").inc("$(VERSION)", "patch")')
release-minor: NEXT_VERSION = $(shell node -p 'require("semver").inc("$(VERSION)", "minor")')
release-major: NEXT_VERSION = $(shell node -p 'require("semver").inc("$(VERSION)", "major")')
release-patch: release
release-minor: release
release-major: release

.PHONY: release
release:
	rm -rf lib
	make
	sed -i '' 's/"version": "[^"]*"/"version": "$(NEXT_VERSION)"/' package.json
	git commit --all --message $(NEXT_VERSION)
	git tag $(NEXT_VERSION)
	@echo 'remember to run `npm publish`'


.PHONY: setup
setup:
	npm install


.PHONY: test
test: all
	$(MOCHA) --grep '^\$$' --invert --timeout 5000


.PHONY: testcli
testcli: all
	$(MOCHA) --grep '^\$$' --timeout 10000
