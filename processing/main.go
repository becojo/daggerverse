package main

import (
	"context"
	"dagger/processing/internal/dagger"
	"embed"
	"encoding/json"
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

type Config struct {
	Width    int    `json:"width"`
	Height   int    `json:"height"`
	Renderer string `json:"renderer"`
}

const processingImage = "ghcr.io/becojo/processing:main@sha256:e708d5f3dbad8bb7d0cefe6a1d00d8077ad512f362b7d9175fccb829ea848508"

//go:embed template
var template embed.FS

func FsFiles(fs embed.FS, basedir string) dagger.WithDirectoryFunc {
	return func(dir *dagger.Directory) *dagger.Directory {
		files, _ := fs.ReadDir("template")
		for _, file := range files {
			if file.IsDir() {
				continue
			}
			if file.Name() == "Makefile" {
				continue
			}
			content, _ := fs.ReadFile("template/" + file.Name())
			dir = dir.WithNewFile("sketch/"+file.Name(), string(content))
		}
		makefile, _ := fs.ReadFile("template/Makefile")
		return dir.WithNewFile("Makefile", string(makefile))
	}
}

// Directory with a new Processing sketch
//
// Usage: dagger call new export --path /tmp/sketch
func (m *Processing) New(ctx context.Context) *dagger.Directory {
	return dag.Directory().With(FsFiles(template, "sketch"))
}

func (m *Processing) Container(ctx context.Context, sketch *dagger.Directory) *dagger.Container {
	return dag.Container().From(processingImage).
		WithDirectory("/src", sketch)
}

// Render a sketch into frames
//
// Usage: dagger call render --sketch /tmp/sketch
func (m *Processing) Render(ctx context.Context,
	sketch *dagger.Directory,
	//+optional
	seed int,
) (*Render, error) {
	var config Config
	configJson, err := sketch.File("sketch/config.json").Contents(ctx)
	if err != nil {
		return nil, err
	}
	err = json.Unmarshal([]byte(configJson), &config)
	if err != nil {
		return nil, err
	}

	ctr := dag.Container().From(processingImage).
		WithEnvVariable("RECORD", "1").
		WithEnvVariable("WIDTH", strconv.Itoa(config.Width)).
		WithEnvVariable("HEIGHT", strconv.Itoa(config.Height)).
		WithEnvVariable("RENDERER", config.Renderer).
		WithEnvVariable("SEED", strconv.Itoa(seed)).
		WithDirectory("/src", sketch).
		WithWorkdir("/src").
		WithExec([]string{
			"xvfb-run",
			"/processing/processing-java",
			`--sketch=/src/sketch`,
			"--run",
		})

	return &Render{
		Container: ctr,
	}, nil
}

// Convert rendered frames into a GIF
//
// Usage: dagger call render --sketch /tmp/sketch gif file export --path output.gif
func (r *Render) Gif() *Gif {
	script := `convert -delay 3 -loop 0 sketch/frame-*.png output.gif`
	ctr := r.Container.WithExec([]string{"bash", "-ec", script})

	return &Gif{File: ctr.File("output.gif")}
}

// Convert rendered frames into a MP4 video
//
// Usage: dagger call render --sketch /tmp/sketch video file export --path output.mp4
func (r *Render) Video(
	//+optional
	loops string,
) *Video {
	if loops == "" {
		loops = "2"
	}

	script := `
start_number=$(ls -1 *.png | sed 's/frame-//g;s/.png//g' | sort -n | head -n1)
ffmpeg -stream_loop ${LOOPS} -r 30 -f image2 -start_number "$start_number" -i 'frame-%08d.png' -vcodec libx264 -crf 25 -pix_fmt yuv420p output.mp4
`
	ctr := r.Container.
		WithWorkdir("/src/sketch").
		WithEnvVariable("LOOPS", loops).
		WithExec([]string{"bash", "-ec", script})

	return &Video{File: ctr.File("output.mp4")}
}

// Optimized a GIF using Gifsicle
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
			WithFile("input.gif", g.File).
			WithExec(args).File("output.gif"),
	}
}
