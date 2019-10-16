# GitHub YAMLlint

This action executes `yamllint` (https://github.com/adrienverge/yamllint) against file(s) or folder

## Usage

### Required parameters

- `file_or_dir` - Enter file/folder (space speparated), wildcards accepted. Examples:
    - `file1.yaml`
    - `file1.yaml file2.yaml`
    - `.` - run against all yaml files in current directory recursively
    - `./**/*values.yaml` - run against all files that end with `values.yaml` recursively

### Optional parameters

- `config_file` - Path to custom configuration
- `config_data` - Custom configuration (as YAML source)
- `format` - Format for parsing output [parsable,standard]
- `strict` - Return non-zero exit code on warnings as well as errors

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
        file_or_dir: ./**/*val*.yaml
        config_file: .yamllint.yml
```
