# ElixirServer

**Easily run an http server from terminal**

## Installation

If [available in Hex](https://hex.pm/docs/publish), this escript can be installed
by running this command

```bash
mix escript.install hex elixir_server
```

Or directly from Github like this:
```bash
mix escript.install git https://github.com/vikram25897/elixir_server
```

## Running webserver
You can run it like this:
```bash
elixir_server --port 4000 --host any index.html
```
or
```bash
elixir_server --p 4000 -h any index.html
```
`host` supports two values:
* `any` to bind on `0.0.0.0`
* `loopback` to bind on `127.0.0.1`, defaults to `loopback`

`port` defaults to `4000`

If no entrypoint file is provided, `elixir_server` searches for any of the following files in order:
* `index.html`
* `index.exs`
* `index.ex`

Will fail if none of these 3 files are provided.

## Running with Elixir files

An elixir file path like `index.ex` or `homepage.exs` can be passed instead of `html` filepath.
When passing in an elixir file, make sure that:
* It contains exactly one module.
* That module either has public both `assigns/1` and `template_path/1` function or a single `raw_html/1` function.
* `assigns/1` is expected to return a keyword list, like `[name: "John Doe", age: 25]`
* `template_path/1` is expected to return path of a template file. You can use EEx template syntax and assigns returned from `assigns/1` function.
* `raw_html` expects you to return a html string.

## Generating HTML

Instead of running an http server, you can instead generate an html file by passing `--only_generate` or `-o` flag like this:
```bash
elixir_server -o index.html output.html
```
If only one path is provided like this:
```bash
elixir_server -o output.html
```
It would be considered the output path and it would search for valid entrypoint as explained in `Running Webserver` section.