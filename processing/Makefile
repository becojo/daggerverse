MODULE ?= $(PWD)

test:
	dagger call -m $(MODULE) new export --path /tmp/test-sketch
	cd /tmp/test-sketch && PERIODS=1 make run
	cd /tmp/test-sketch && MODULE=$(MODULE) make export/gif
	cd /tmp/test-sketch && MODULE=$(MODULE) make export/video
	cd /tmp/test-sketch && MODULE=$(MODULE) make export/gifsicle colors=32