# GitHub YAMLlint

This action executes `yamllint` (https://github.com/adrienverge/yamllint) against file(s) or folder

## Usage

### Required parameters

- `file_or_dir` - Enter file/folder (space speparated), wildcards accepted. Examples:
    - `file1.yaml`
    - `file1.yaml file2.yaml`
    - `.` - run against all yaml files in a directory recursively
    - `kustomize/**/*.yaml mychart/*values.yaml`

### Optional parameters

- `config_file` - Path to custom configuration
- `config_data` - Custom configuration (as YAML source)
- `format` - Format for parsing output [parsable,standard,colored,auto]
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
      uses: ibiqlik/action-yamllint@master
      with:
        file_or_dir: myfolder/*values*.yaml
        config_file: .yamllint.yml
```
