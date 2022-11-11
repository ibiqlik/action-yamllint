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
