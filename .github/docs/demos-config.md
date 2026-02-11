# demos.config.json

Per-demo configuration for the build/deploy pipeline. Lives at the repository root.

## Schema

```json
{
  "demos": {
    "<demo-name>": {
      "skip": true,
      "variant": "vue-ts",
      "buildFlags": "--minify",
      "unlisted": true
    }
  }
}
```

Demos not listed in the config use default behavior. All fields are optional.

## Fields

| Field | Type | Used by | Description |
|-------|------|---------|-------------|
| `skip` | `boolean` | build script | Skip build and deploy entirely. The demo appears in the "Skipped" summary. |
| `variant` | `string` | build script | Subdirectory to build (e.g. `"vue-ts"`, `"react-ts"`). Overrides the default `ts` → `js` fallback. If the directory doesn't exist, falls back to default. |
| `buildFlags` | `string` | build script | Extra flags appended to the `npm run build` command (e.g. `"--minify"`). |
| `unlisted` | `boolean` | CLI tooling | Hides the demo from `@joint/cli list`. Still builds and deploys normally. |

## Default behavior

When a demo has no entry in the config, the build script picks the first available subdirectory in this order:

1. `ts/`
2. `js/`
3. Skip (with a message suggesting to add a `variant` to the config)

## Examples

Skip a demo from build/deploy:

```json
{
  "demos": {
    "bpmn-camunda-integration": {
      "skip": true
    }
  }
}
```

Build a specific variant instead of the default:

```json
{
  "demos": {
    "chatbot": {
      "variant": "vue-ts"
    }
  }
}
```

Append extra build flags:

```json
{
  "demos": {
    "genogram": {
      "buildFlags": "--minify"
    }
  }
}
```

## Related files

- [`demos.config.json`](../../demos.config.json) — the config file
- [`.github/scripts/build-demos.sh`](../scripts/build-demos.sh) — the build script that reads it
