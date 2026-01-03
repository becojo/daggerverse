package main

import (
	"context"
	"dagger/processing/internal/dagger"
	"embed"
	"io/fs"
	"os"
	"strconv"
)

type Processing struct {
}

type Render struct {
	Container *dagger.Container
}

type Gif struct {
	File *dagger.File
}

type Video struct {
	File *dagger.File
}

const processingImage = "ghcr.io/becojo/processing:main@sha256:e708d5f3dbad8bb7d0cefe6a1d00d8077ad512f362b7d9175fccb829ea848508"

//go:embed all:template
var template embed.FS

func fsFiles(src embed.FS, basedir string) dagger.WithDirectoryFunc {
	return func(dir *dagger.Directory) *dagger.Directory {
		fs.WalkDir(src, ".", func(path string, d os.DirEntry, err error) error {
			if err != nil || d.IsDir() {
				return err
			}
			content, err := fs.ReadFile(src, path)
			if err != nil {
				return err
			}
			dir = dir.WithNewFile(path, string(content))
			return nil
		})
		return dir.Directory(basedir)
	}
}

// Directory with a new Processing sketch
//
// Usage: dagger call new export --path /tmp/sketch
func (m *Processing) New() *dagger.Directory {
	return dag.Directory().With(fsFiles(template, "template"))
}

func (m *Processing) Container(ctx context.Context, sketch *dagger.Directory) *dagger.Container {
	return dag.Container().
		From(processingImage).
		WithDirectory("/src", sketch)
}

// Render a sketch into frames
func (m *Processing) Render(ctx context.Context,
	// +ignore=["*", "!sketch/**"]
	sketch *dagger.Directory,
	//+optional
	seed int,
	//+default=500
	width int,
	//+default=500
	height int,
) (*Render, error) {
	ctr := dag.Container().From(processingImage).
		WithEnvVariable("RECORD", "1").
		WithEnvVariable("WIDTH", strconv.Itoa(width)).
		WithEnvVariable("HEIGHT", strconv.Itoa(height)).
		WithEnvVariable("SEED", strconv.Itoa(seed)).
		WithDirectory("/src", sketch).
		WithWorkdir("/src").
		WithExec([]string{
			"xvfb-run",
			"/processing/processing-java",
			`--sketch=/src/sketch`,
			"--run",
		})

	return &Render{Container: ctr}, nil
}

// Convert rendered frames into a GIF
//
// Usage: dagger call render --sketch /tmp/sketch gif file export --path output.gif
func (r *Render) Gif(
	//+default=25
	fps int,
) *Gif {
	script := `
start_number=$(ls -1 sketch/*.png | sed 's/.*frame-//g;s/.png//g' | sort -n | head -n1)
ffmpeg -r ${FPS} -f image2 -start_number "$start_number" -i 'sketch/frame-%08d.png' -vf palettegen palette.png
ffmpeg -r ${FPS} -f image2 -start_number "$start_number" -i 'sketch/frame-%08d.png' -i palette.png -lavfi paletteuse output.gif
`
	ctr := r.Container.
		WithEnvVariable("FPS", strconv.Itoa(fps)).
		WithExec([]string{"bash", "-ec", script})

	return &Gif{File: ctr.File("output.gif")}
}

// Convert rendered frames into a MP4 video
//
// Usage: dagger call render --sketch /tmp/sketch video file export --path output.mp4
func (r *Render) Video(
	//+default=2
	loops int,
	//+default=25
	fps int,
) *Video {
	script := `
start_number=$(ls -1 *.png | sed 's/frame-//g;s/.png//g' | sort -n | head -n1)
ffmpeg -stream_loop ${LOOPS} -r ${FPS} -f image2 -start_number "$start_number" -i 'frame-%08d.png' -vcodec libx264 -crf 25 -pix_fmt yuv420p output.mp4
`
	ctr := r.Container.
		WithWorkdir("/src/sketch").
		WithEnvVariable("LOOPS", strconv.Itoa(loops)).
		WithEnvVariable("FPS", strconv.Itoa(fps)).
		WithExec([]string{"bash", "-ec", script})

	return &Video{File: ctr.File("output.mp4")}
}

// Optimize a rendered GIF using Gifsicle
//
// Usage: dagger call render --sketch /tmp/sketch gif gifsicle --colors 32 file export --path output.gif
func (g *Gif) Gifsicle(
	//+optional
	colors string,
	//+optional
	transparent string,
	//+optional
	lossy bool,
	//+optional
	optimize bool,
) *Gif {
	args := []string{"gifsicle", "-o", "output.gif"}

	if colors != "" {
		args = append(args, "--colors="+colors)
	}

	if transparent != "" {
		args = append(args, "--transparent="+transparent, "--disposal=previous")
	}

	if lossy {
		args = append(args, "--lossy")
	}

	if optimize {
		args = append(args, "--optimize")
	}

	args = append(args, "input.gif")

	return &Gif{
		File: dag.Container().
			From(processingImage).
			WithMountedFile("input.gif", g.File).
			WithExec(args).
			File("output.gif"),
	}
}
