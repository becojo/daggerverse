package main

import (
	"context"
	"fmt"
)

type Processing struct{}

var defaultImage = "ghcr.io/becojo/processing:main@sha256:de8ecf1db356463607b3854a576d7a9679fbbbb523e8c5f8a6ab99550529da11"

func (m *Processing) Render(
	ctx context.Context,
	image Optional[string],
	sketch string,
	width string,
	height string,
	seed string,
) *Container {
	_image := image.GetOr(defaultImage)

	sketches := dag.Host().Directory("sketches", HostDirectoryOpts{
		Exclude: []string{"*.png", "*.gif"},
	})

	cwd := fmt.Sprintf("/sketches/%s", sketch)

	return dag.Container().From(_image).
		WithEnvVariable("RECORD", "1").
		WithEnvVariable("WIDTH", width).
		WithEnvVariable("HEIGHT", height).
		WithEnvVariable("SEED", seed).
		WithDirectory("/sketches", sketches).
		WithWorkdir(cwd).
		WithExec([]string{
			"xvfb-run", "/processing/processing-java",
			fmt.Sprintf("--sketch=%v", cwd), "--run",
		})
}

func (m *Processing) Ffmpeg(
	ctx context.Context,
	image Optional[string],
	sketch string,
	width string,
	height string,
	seed string,
	loops Optional[int],
) *File {
	c := m.Render(ctx, image, sketch, width, height, seed)

	return c.WithExec([]string{"bash", "-ec", `
      start_number=$(ls -1 *.png | sed 's/frame-//g;s/.png//g' | sort -n | head -n1)
      ffmpeg -stream_loop 1 -r 30 -f image2 -start_number "$start_number" -i 'frame-%08d.png' -vcodec libx264 -crf 25 -pix_fmt yuv420p output.mp4
    `}).File("output.mp4")
}

func (m *Processing) Gif(
	ctx context.Context,
	image Optional[string],
	sketch string,
	width string,
	height string,
	seed string,
) *File {
	c := m.Render(ctx, image, sketch, width, height, seed)

	return c.WithExec([]string{"convert", "-delay", "3", "-loop", "0", "*.png", "output.gif"}).
		File("output.gif")
}
