# GitHub YAMLlint

This action executes `yamllint` (https://github.com/adrienverge/yamllint) against files or folder

## Usage

Simple as:

```yaml
- uses: ibiqlik/action-yamllint@v3
```

### Optional input parameters

- `config_file` - Path to custom configuration
- `config_data` - Custom configuration (as YAML source)
- `file_or_dir` - Enter file/folder (space separated), wildcards accepted. Examples:
  - `.` - run against all yaml files in a directory recursively (default)
  - `file1.yaml`
  - `file1.yaml file2.yaml`
  - `kustomize/**/*.yaml mychart/*values.yaml`
- `format` - Format for parsing output `[parsable,standard,colored,github,auto] (default: parsable)`
- `strict` - Return non-zero exit code on warnings as well as errors `[true,false] (default: false)`
- `no_warnings` - Output only error level problems `[true,false] (default: false)`

**Note:** If `.yamllint` configuration file exists in your root folder, yamllint automatically uses it.

### Outputs

`logfile` - Path to yamllint log file

`${{ steps.<step>.outputs.logfile }}`

**Note:** Each yamllint run (for example if you define multiple yamllint steps) has its own log

### Example usage in workflow

```yaml
---
name: Yaml Lint
on: [push]  # yamllint disable-line rule:truthy
jobs:
  lintAllTheThings:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: yaml-lint
        uses: ibiqlik/action-yamllint@v3
        with:
          file_or_dir: myfolder/*values*.yaml
          config_file: .yamllint.yml
```

Or just simply lint all yaml files in the repository:

```yaml
---
name: Yaml Lint
on: [push]  # yamllint disable-line rule:truthy
jobs:
  lintAllTheThings:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: yaml-lint
        uses: ibiqlik/action-yamllint@v3
```

Config data examples:

```yaml
# Single line
config_data: "{extends: default, rules: {new-line-at-end-of-file: disable}}"
```

``` yaml
# Multi line
config_data: |
  extends: default
  rules:
    new-line-at-end-of-file:
      level: warning
    trailing-spaces:
      level: warning
```

Use output to save/upload the log in artifact. Note, you must have `id` in the step running the yamllint action.

```yaml
---
name: Yaml Lint
on: [push]  # yamllint disable-line rule:truthy
jobs:
  lintAllTheThings:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - id: yaml-lint
        uses: ibiqlik/action-yamllint@v3

      - run: echo ${{ steps.yaml-lint.outputs.logfile }}

      - uses: actions/upload-artifact@v2
        if: always()
        with:
          name: yamllint-logfile
          path: ${{ steps.yaml-lint.outputs.logfile }}
```

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