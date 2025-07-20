// Module to edit Marimo notebooks
package main

import (
	"context"
	"dagger/marimo/internal/dagger"
	"strings"
)

type Marimo struct {
	Container *dagger.Container
}

const (
	UvVersion     = "0.8.0@sha256:5778d479c0fd7995fedd44614570f38a9d849256851f2786c451c220d7bd8ccd"
	PythonImage   = "python:3.13-slim@sha256:6544e0e002b40ae0f59bc3618b07c1e48064c4faed3a15ae2fbd2e8f663e8283"
	MarimoVersion = "0.14.12"
)

func New(
	//+default=""
	uvVersion string,
	//+default=""
	pythonImage string,
	//+default=""
	marimoVersion string,
	//+default=[]
	packages []string,
	//+default=[]
	env []string,
	//+default=""
	cacheKey string,
) *Marimo {
	if uvVersion == "" {
		uvVersion = UvVersion
	}

	if pythonImage == "" {
		pythonImage = PythonImage
	}

	if marimoVersion == "" {
		marimoVersion = MarimoVersion
	}

	if cacheKey == "" {
		cacheKey = "marimo-cache"
	}

	return &Marimo{
		Container: dag.Container().
			With(cacheVolume(cacheKey, "/src")).
			From(pythonImage).
			With(uv(uvVersion)).
			WithEnvVariable("PACKAGES", strings.Join(append(packages, "marimo=="+marimoVersion), " ")).
			WithExec([]string{"sh", "-ec", `
				cd $(mktemp -d)
				export UV_PROJECT_ENVIRONMENT=/usr/local
				uv init --bare
				uv add $PACKAGES

				mkdir -p /files
		 `}).
			WithWorkdir("/src").
			WithDefaultTerminalCmd([]string{"uv", "run", "bash"}).
			WithExposedPort(2718, dagger.ContainerWithExposedPortOpts{ExperimentalSkipHealthcheck: true}).
			With(envVariables(env)),
	}
}

// Service to edit a file in Marimo
func (m *Marimo) Edit(
	ctx context.Context,
	//+default=""
	path string,
) *dagger.Service {
	args := []string{"marimo", "edit", "--skip-update-check", "--host", "0.0.0.0"}
	if path != "" {
		args = append(args, path)
	}

	return m.Container.AsService(dagger.ContainerAsServiceOpts{
		Args:          args,
		UseEntrypoint: false,
	})
}

// Read a file from the Marimo workspace
func (m *Marimo) File(
	path string,
) *dagger.File {
	return m.Container.
		With(cacheBuster).
		WithExec([]string{"cp", "/src/" + path, "/files/" + path}).
		File("/files/" + path)
}
