# `github.com/becojo/daggerverse/marimo`

Module to run and edit Marimo notebooks inside Dagger.

## Usage

### Launch the editor

The URL to open the notebook will be printed to the console.

```sh
dagger call -m github.com/becojo/daggerverse/marimo edit --path notebook.py up
```

### Export files

```sh
dagger call -m github.com/becojo/daggerverse/marimo file --path notebook.py export --path output.py
```

### Add packages to the environment

```sh
dagger call -m github.com/becojo/daggerverse/marimo --packages "jinja2","pandas==2.3.1" edit --path notebook.py up
```

### Use custom Python image

```sh
dagger call -m github.com/becojo/daggerverse/marimo --python-image "python:3.13-slim" edit --path notebook.py up
```

### Define environment variables

```sh
dagger call -m github.com/becojo/daggerverse/marimo --env "TZ=America/New_York","VAR=value" edit --path notebook.py up
```

### Open a terminal in the workspace

```sh
dagger call -m github.com/becojo/daggerverse/marimo container terminal
```