# GitHub YAMLlint

This action executes `yamllint` (https://github.com/adrienverge/yamllint) against file(s) or folder

## Usage

### Optional parameters

- `config_file` - Path to custom configuration
- `config_data` - Custom configuration (as YAML source)
- `file_or_dir` - Enter file/folder (space separated), wildcards accepted. Examples:
    - `.` - run against all yaml files in a directory recursively (default)
    - `file1.yaml`
    - `file1.yaml file2.yaml`
    - `kustomize/**/*.yaml mychart/*values.yaml`
- `format` - Format for parsing output [parsable,standard,colored,auto] (default: colored)
- `strict` - Return non-zero exit code on warnings as well as errors [true,false]

### Example usage in workflow

```yaml
name: Yaml Lint
on: [push]
jobs:
  lintAllTheThings:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@master
    - name: yaml-lint
      uses: ibiqlik/action-yamllint@v1
      with:
        file_or_dir: myfolder/*values*.yaml
        config_file: .yamllint.yml
```

Or just simply check all yaml files in the repository:

```yaml
name: Yaml Lint
on: [push]
jobs:
  lintAllTheThings:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v1
    - name: yaml-lint
      uses: ibiqlik/action-yamllint@master
```
