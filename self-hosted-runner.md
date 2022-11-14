## Using self-hosted runner with containers

If you are using self-hosted runner like below:

```yaml
---
name: Yaml Lint
on: [push]  # yamllint disable-line rule:truthy
jobs:
  lintAllTheThings:
    runs-on: self-hosted
    container: ubuntu:latest
...
```

Because of the difference between self-hosted runner and github runner, you will most likely get the following errors.

In Github's ubuntu runner image, there are quite a lot of software packages pre-installed, so when you switch to a self-hosted runner environment, your ubuntu container may be missing a lot of different software packages. You can read more about Github runner software packages here [https://github.com/actions/runner-images/blob/main/images/linux/Ubuntu2004-Readme.md](https://github.com/actions/runner-images/blob/main/images/linux/Ubuntu2004-Readme.md).

### Error 1: Missing or wrong git version

The error look like:

```
git: command not found
Error: Invalid git version. Please upgrade git () to >= (2.18.0)
Error: Process completed with exit code 1.
```

To fix this, add a step in your workflows like this:

```yaml
---
name: Yaml Lint
on: [push]  # yamllint disable-line rule:truthy
jobs:
  lintAllTheThings:
    runs-on: self-hosted
    container: ubuntu:latest
    steps:
      # This step will resolve the error related to git
      - name: Install packages
        run: |
          apt update
          apt install -y git
...
```

### Error 2: Unable to locate the current sha

The error look like:

```
Error: Unable to locate the current sha: ccac51682fd2d799056162998cf6e90c47644e43
Error: You seem to be missing 'fetch-depth: 0' or 'fetch-depth: 2'.
Error: Process completed with exit code 1.
```

Examples of workflows are as follows.

```yaml
---
name: Yaml Lint
on: [push]  # yamllint disable-line rule:truthy
jobs:
  lintAllTheThings:
    runs-on: self-hosted
    container: ubuntu:latest
    steps:
      # This step will resolve the error related to git
      - name: Install packages
        run: |
          apt update
          apt install -y git

      - uses: actions/checkout@v3
        with:
          fetch-depth: 0
...
```

Even though you have set `fetch-depth: 0` for action `actions/checkout@v3` above, you will probably get the above error.

That's because on a regular Github runner, the runner's working directory is `/home/runner/work/` while on a self-hosted runner container environment, it will be `/__w/`. This may cause checkout errors in some environments.

To handle it, you can add a step in your workflows as follows. Replace `your-repository` with your repository name. Example `action-yamllint`.

```yaml
---
name: Yaml Lint
on: [push]  # yamllint disable-line rule:truthy
jobs:
  lintAllTheThings:
    runs-on: self-hosted
    container: ubuntu:latest
    steps:
      # This step will resolve the error related to git
      - name: Install packages
        run: |
          apt update
          apt install -y git

      - uses: actions/checkout@v3
        with:
          fetch-depth: 0

      # This step will resolve the error related to checkout
      - name: Git config safe.directory
        run: |
          git config --global --add safe.directory /__w/your-repository/your-repository
...
```

### Error 3: yamllint: command not found

The error look like:

```
======================
= Linting YAML files =
======================
/__w/_actions/ibiqlik/action-yamllint/v3/entrypoint.sh: line 36: yamllint: command not found
Error: Process completed with exit code 127.
```

If you're getting this error, it's also related to the self-hosted runner container that doesn't have the `yamllint` software package pre-installed. To fix this error, simply install the `yamllint` package.

```yaml
---
name: Yaml Lint
on: [push]  # yamllint disable-line rule:truthy
jobs:
  lintAllTheThings:
    runs-on: self-hosted
    container: ubuntu:latest
    steps:
      # This step will resolve the error related to git & yamllint command
      - name: Install packages
        run: |
          apt update
          apt install -y git
          apt install -y yamllint

      - uses: actions/checkout@v3
        with:
          fetch-depth: 0

      # This step will resolve the error related to checkout
      - name: Git config safe.directory
        run: |
          git config --global --add safe.directory /__w/your-repository/your-repository
...
```

## Complete workflow example for self-hosted runner container

```yaml
---
name: Yaml Lint
on: [push]  # yamllint disable-line rule:truthy
jobs:
  lintAllTheThings:
    runs-on: self-hosted
    container: ubuntu:latest
    steps:
      # This step will resolve the error related to git & yamllint command
      - name: Install packages
        run: |
          apt update
          apt install -y git
          apt install -y yamllint

      - uses: actions/checkout@v3
        with:
          fetch-depth: 0

      # This step will resolve the error related to checkout
      - name: Git config safe.directory
        run: |
          git config --global --add safe.directory /__w/your-repository/your-repository

      # This step will get all changed files
      - name: Get changed files
        id: changed-files
        uses: tj-actions/changed-files@v34

      # This step will list all changed files
      - name: List all changed files
        run: |
          for file in ${{ steps.changed-files.outputs.all_changed_files }}; do
            echo "$file was changed"
          done

      # This step will check YAML lint
      - name: Yaml lint all changed files
        uses: ibiqlik/action-yamllint@v3
        with:
          file_or_dir: ${{ steps.changed-files.outputs.all_changed_files }}
          # Change the line length to 130 characters
          config_data: |
            extends: default
            rules:
              line-length:
                max: 130
                allow-non-breakable-words: true
                allow-non-breakable-inline-mappings: false
```
