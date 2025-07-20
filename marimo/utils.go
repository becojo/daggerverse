package main

import (
	"dagger/marimo/internal/dagger"
	"strings"
	"time"
)

func uv(version string) func(*dagger.Container) *dagger.Container {
	uv := dag.Container().From("ghcr.io/astral-sh/uv:" + version).File("/uv")

	return func(c *dagger.Container) *dagger.Container {
		return c.WithFile("/usr/bin/uv", uv)
	}
}

func uvInit(c *dagger.Container) *dagger.Container {
	return c.WithExec([]string{"sh", "-ec", `
	  unset UV_PROJECT_ENVIRONMENT
		uv init --bare --description "Marimo Environment" || true
		uv venv --allow-existing
	`})
}

func envVariables(env []string) func(*dagger.Container) *dagger.Container {
	vars := map[string]string{}
	for _, e := range env {
		name, value, found := strings.Cut(e, "=")
		if !found {
			continue
		}
		vars[name] = value
	}

	return func(c *dagger.Container) *dagger.Container {
		for name, value := range vars {
			c = c.WithEnvVariable(name, value)
		}
		return c
	}
}

func cacheVolume(key string, path string) func(*dagger.Container) *dagger.Container {
	cache := dag.CacheVolume(key)
	return func(c *dagger.Container) *dagger.Container {
		return c.WithMountedCache(path, cache)
	}
}

func cacheBuster(c *dagger.Container) *dagger.Container {
	return c.WithEnvVariable("CACHE", time.Now().String())
}
