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
			content, _ := fs.ReadFile("template/" + file.Name())
			dir = dir.WithNewFile("sketch/"+file.Name(), string(content))
		}
		return dir
	}
}

// Directory with a new Processing sketch
func (m *Processing) New(ctx context.Context) *dagger.Directory {
	return dag.Directory().With(FsFiles(template, "sketch"))
}

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

func (r *Render) Gif() *Gif {
	script := `convert -delay 3 -loop 0 sketch/*.png output.gif`
	ctr := r.Container.WithExec([]string{"bash", "-ec", script})

	return &Gif{File: ctr.File("output.gif")}
}

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

func (g *Gif) Gifsicle(
	//+optional
	colors string,
	//+optional
	transparent string,
) *Gif {
	args := []string{"gifsicle", "-o", "output.gif"}

	if colors != "" {
		args = append(args, "--colors="+colors)
	}

	if transparent != "" {
		args = append(args, "--transparent="+transparent, "--disposal=previous")
	}

	args = append(args, "input.gif")

	return &Gif{
		File: dag.Container().
			From(processingImage).
			WithFile("input.gif", g.File).
			WithExec(args).File("output.gif"),
	}
}
