#
# Run all tests
#
test:
	node test/server.js

#
# Run jasmine-test
#
jasmine:
	node test/jasmine-test/server/specRunner.js
#
# Run code coverage and generate report
#
coverage:
	cover run test/server.js && cover report && cover report html

#
# Run the benchmarks
#
bench:
	node benchmark/server.js

#
# Build the docs
#
docs:
	node docs/build.js

#
# Build the parser
#
parser:
	node src/build.js

#
# Build dust.js
#

SRC = lib
VERSION = ${shell cat package.json | grep version | grep -o '[0-9]\.[0-9]\.[0-9]\+'}
CORE = dist/dust-core-${VERSION}.js
CORE_DEBUG = dist/dust-core-debug-${VERSION}.js
CORE_MIN = dist/dust-core-${VERSION}.min.js
CORE_DEBUG_MIN = dist/dust-core-debug-${VERSION}.min.js
FULL = dist/dust-full-${VERSION}.js
FULL_DEBUG = dist/dust-full-debug-${VERSION}.js
FULL_MIN = dist/dust-full-${VERSION}.min.js
FULL_DEBUG_MIN = dist/dust-full-debug-${VERSION}.min.js

define HEADER
//
// Dust - Asynchronous Templating v${VERSION}
// http://akdubya.github.com/dustjs
//
// Copyright (c) 2010, Aleksander Williams
// Released under the MIT License.
//

endef

export HEADER

#TODO: REMOVE THE HELPERS IN THE NEXT RELEASE
dust:
	@@mkdir -p dist
	@@touch ${CORE_DEBUG}
	@@echo "$$HEADER" > ${CORE_DEBUG}
	@@cat ${SRC}/dust.js >> ${CORE_DEBUG}
	@@echo ${CORE_DEBUG} built

	node utils/debug_strip ${CORE_DEBUG} ${CORE} 
	@@echo ${CORE} built

	@@touch ${FULL_DEBUG}
	@@echo "$$HEADER" > ${FULL_DEBUG}
	@@cat ${SRC}/dust.js\
	      ${SRC}/compiler.js\
	      ${SRC}/parser.js >> ${FULL_DEBUG}
	@@echo ${FULL_DEBUG} built

	node utils/debug_strip ${FULL_DEBUG} ${FULL} 
	@@echo ${FULL} built

min: dust
	@@echo minifying...
	@@echo "$$HEADER" > ${CORE_MIN}
	@@echo "$$HEADER" > ${CORE_DEBUG_MIN}
	@@echo "$$HEADER" > ${FULL_MIN}
	@@echo "$$HEADER" > ${FULL_DEBUG_MIN}
	node utils/minifier ${CORE} ${CORE_MIN} 
	node utils/minifier ${CORE_DEBUG} ${CORE_DEBUG_MIN} 
	node utils/minifier ${FULL} ${FULL_MIN} 
	node utils/minifier ${FULL_DEBUG} ${FULL_DEBUG_MIN} 

clean:
	git rm dist/*

release: clean docs min
	git add dist/*
	git commit -a -m "release v${VERSION}"
	git tag -a -m "version v${VERSION}" v${VERSION}
	npm publish

.PHONY: test docs bench parser
