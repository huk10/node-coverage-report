# Node coverage report

[![MIT License](https://img.shields.io/badge/license-MIT-brightgreen.svg)](https://github.com/huk10/node-coverage-report/blob/master/LICENSE)
[![Release](https://img.shields.io/github/release/huk10/node-coverage-report.svg?style=flat-square)](https://github.com/huk10/node-coverage-report/releases)

A Github Action is used to generate a [badge][badge] with test coverage and add it to your JavaScript.
In the code warehouse. Part of the code comes from [go-coverage-report](https://github.com/ncruces/go-coverage-report)。

[English](./README.md) | [简体中文](./README-zh-Hans.md)

## How works

At present, the mainstream JavaScript testing framework should use test coverage reports generated by [istanbul.js][istanbul] (v8 also supports istanbul.js).
This Action will try to read the output of `text-summary` and `json-summary` to parse out the test coverage, and then use [shields.io][shields] to generate a logo that will upload the logo to the wiki of your code repository.

The core is that your project needs to be able to output reports in accordance with the two reporters (`text-summary` and `json-summary`) formats.

Because the output of `json-summary` only exists on the command line, while `json-summary` can be generated in the file directory ahead of time. In order to avoid repeated execution of test commands.
The contents of `json-summary` will be read preferentially internally. Run the command to generate data when it is not available.

Both vitest and jest have reporters configuration items, and other testing frameworks should be able to support them if they can be used with [nyc][nyc].

## Usage

First, your code repository needs to have at least one wiki page, and then you need to turn on Action read and write access to the repository.

<details>
    <summary>View pictures</summary>
    <div align=center>
        <img src="./setting.jpg" width="70%" align="center">
    </div>
</details>

Next you need to add the following code to your Github workflows.

```yaml
- name: Update coverage report
  uses: huk10/node-coverage-report@v1
```

This Action has 6 optional configuration items:

- **command** It should be a command that can output the contents of the above reporters. Default: `npm run test:coverage`
- **coverage-dir** The output directory of the test coverage report file. Default: `coverage`
- **output-dir** The directory where the Action outputs the files in the wiki of your code repository, which is output in the root directory by default.
- **badge-style** The badge style of [shields.io][shields] can only be one of `flat`, `flat-square`, `plastic`, `for-the-badge`, `social`. Default: `flat`
- **badge-title** The text on the badge. Default: `coverage`
- **amend** Use the `Update coverage` commit when submitting to the wiki warehouse to avoid generating too much. Default: `false`

> Also, consider:
> - running this step _after_ your tests run
>   - coverage will fail if any test fails, so you may skip it if they fail
> - running it only once per commit
>   - use a condition to avoid repeated matrix runs
> - skipping it for PRs
>   - PRs lack permission to update the Wiki, nor would you want not submitted PRs to do so
> - allowing it to fail without failing the entire job
>   - if tests pass, the problem might be with the action itself, not your code

<details>
<summary>Complete example:</summary>

```yaml
name: Node.js

on: [ push ]

jobs:
  build:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        node-version: [ 20 ]
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node-version }}
          cache: 'pnpm'
      - uses: pnpm/action-setup@v3
        with:
          version: 8
      - name: Install dependencies
        run: pnpm install
      - name: Update coverage badge
        uses: huk10/node-coverage-report@v1
        with:
          amend: true
        if: |
          matrix.os == 'ubuntu-latest' && github.event_name == 'push'
        continue-on-error: true
```

</details>

To add a coverage badge to your `README.md`, use this Markdown snippet:

```markdown
<!-- You need to replace the following USER and REPO with your own -->
![](https://github.com/USER/REPO/wiki/coverage.svg)
```

## License

The scripts and documentation in this project are released under the [MIT License](./LICENSE)

[badge]: https://github.com/huk10/esdi/wiki/coverage.svg

[istanbul]: https://istanbul.js.org/docs/advanced/alternative-reporters

[shields]: https://shields.io

[nyc]: https://github.com/istanbuljs/nyc
