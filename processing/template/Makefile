MODULE ?= github.com/becojo/daggerverse/processing
SKETCH ?= $(PWD):sketch

run:
	processing-java --sketch=$(PWD)/sketch --run

render:
	dagger call -m "$(MODULE)" render --sketch "$(SKETCH)"

export/gif: name=$(shell date +%s)
export/gif: seed=$(shell echo '$$RANDOM')
export/gif:
	dagger call -m "$(MODULE)" render --seed "$(seed)" --sketch "$(SKETCH)" gif file export --path "export/$(name).gif"

export/video: name=$(shell date +%s)
export/video: seed=$(shell echo '$$RANDOM')
export/video: loops=2
export/video:
	dagger call -m "$(MODULE)" render --seed "$(seed)" --sketch "$(SKETCH)" video --loops "$(loops)" file export --path "export/$(name).mp4"

export/gifsicle: name=$(shell date +%s)
export/gifsicle: seed=$(shell echo '$$RANDOM')
export/gifsicle: colors=16
export/gifsicle: transparent=
export/gifsicle:
	dagger call -m "$(MODULE)" render --seed "$(seed)" --sketch "$(SKETCH)" gif gifsicle --colors "$(colors)" --transparent "$(transparent)" file export --path "export/$(name).gif"
