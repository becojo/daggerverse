MODULE ?= github.com/becojo/daggerverse/processing
SKETCH ?= $(PWD)

run:
	processing-java --sketch=$(PWD)/sketch --run

export/gif: name=$(shell date +%s)
export/gif: seed=0
export/gif: width=500
export/gif: height=500
export/gif: framerate=25
export/gif:
	dagger call -m "$(MODULE)" \
		render \
			--seed "$(seed)" \
			--sketch "$(SKETCH)" \
			--width "$(width)" \
			--height "$(height)" \
		gif \
			--fps "$(framerate)" \
		file export \
			--path "export/$(name).gif"

export/video: name=$(shell date +%s)
export/video: seed=0
export/video: width=500
export/video: height=500
export/video: fps=25
export/video: loops=1
export/video:
	dagger call -m "$(MODULE)" \
		render \
			--seed "$(seed)" \
			--sketch "$(SKETCH)" \
		video \
			--loops "$(loops)" \
			--fps "$(fps)" \
		file export \
			--path "export/$(name).mp4"

export/gifsicle: name=$(shell date +%s)
export/gifsicle: seed=0
export/gifsicle: width=500
export/gifsicle: height=500
export/gifsicle: fps=25
export/gifsicle: colors=16
export/gifsicle: transparent=
export/gifsicle:
	dagger call -m "$(MODULE)" \
		render \
			--seed "$(seed)" \
			--sketch "$(SKETCH)" \
			--width "$(width)" \
			--height "$(height)" \
		gif \
			--fps "$(fps)" \
		gifsicle \
			--colors "$(colors)" \
			--transparent "$(transparent)" \		file export \
			--path "export/$(name).gif"
