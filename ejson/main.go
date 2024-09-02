package main

import (
	"bytes"
	"context"
	"dagger/ejson/internal/dagger"
	"encoding/json"
	"strings"

	ejsonLib "github.com/Shopify/ejson"
)

type Ejson struct{}

var defaultContainer = dag.Container().From("alpine:latest")

// Compile EJSON and return a container with the binary in /usr/bin/ejson
func (m *Ejson) Container(
	// +optional
	container *dagger.Container,
) *dagger.Container {
	if container == nil {
		container = defaultContainer
	}

	bin := dag.Container().
		From("cgr.dev/chainguard/go").
		WithExec([]string{"go", "install", "github.com/Shopify/ejson/cmd/ejson@latest"}).
		File("/root/go/bin/ejson")

	return container.WithFile("/usr/bin/ejson", bin)
}

// Encrypt an EJSON file
func (m *Ejson) Encrypt(
	ctx context.Context,
	ejson *dagger.Secret,
) (string, error) {
	str, err := ejson.Plaintext(ctx)
	if err != nil {
		return "", err
	}

	output := new(bytes.Buffer)
	_, err = ejsonLib.Encrypt(strings.NewReader(str), output)
	if err != nil {
		return "", err
	}

	return output.String(), nil
}

type Ejson2Env struct {
	Environment map[string]string `json:"environment"`
}

// Return a container with decrypted environment variables from an EJSON file
//
// Similar to ejson2env, the EJSON file is expected to have a map of environment
// variables in the "environment" key. If the environment variable starts with an
// underscore, it will be added to the container's environment variables with the
// leading underscore removed. Otherwise, it will be added as a secret variable.
func (m *Ejson) DecryptSecrets(
	ctx context.Context,
	// +optional
	container *dagger.Container,
	ejson *dagger.File,
	key *dagger.Secret,
) (*dagger.Container, error) {
	if container == nil {
		container = defaultContainer
	}

	keyStr, err := key.Plaintext(ctx)
	if err != nil {
		return nil, err
	}

	ejsonStr, err := ejson.Contents(ctx)
	if err != nil {
		return nil, err
	}

	output := new(bytes.Buffer)
	err = ejsonLib.Decrypt(strings.NewReader(ejsonStr), output, "", keyStr)
	if err != nil {
		return nil, err
	}

	var secrets Ejson2Env
	err = json.NewDecoder(output).Decode(&secrets)
	if err != nil {
		return nil, err
	}

	for k, v := range secrets.Environment {
		if k == "" {
			continue
		}

		if k[0] == '_' {
			// the value was in plaintext, add as an environment variable
			k = k[1:]
			container = container.WithEnvVariable(k, v)
		} else {
			// the value was encrypted, add as a secret variable
			container = container.WithSecretVariable(k, dag.SetSecret(k, v))
		}
	}

	return container, nil
}
