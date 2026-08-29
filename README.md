# mac-health

Welcome to my mac-health repo!

mac-health is a CLI app written in Swift that uses macOS APIs, as far as possible, to collect information about a Mac and check its health.

The app can display a human-readable health report in the terminal, or output the results as JSON. JSON can also be written directly to a file for use by other scripts and tools.

## Commands

```
OVERVIEW: Run health checks against the local Mac.

USAGE: mac-health [--device] [--json] [--output <output>] [--memory] [--storage] [--battery] [--security] [--updates] [--users]

OPTIONS:
  -d, --device            Show device information only.
  --json                  Output to JSON.
  -o, --output <output>   Write JSON output to a file.
  -m, --memory            Show memory health information only.
  -s, --storage           Show storage health information only.
  -b, --battery           Show battery and power information only.
  --security              Show security information only.
  -u, --updates           Check for available macOS software updates.
  --users                 Show local user information only.
  --version               Show the version.
  -h, --help              Show help information.
```

## Usage

Run mac-health with no arguments to perform a full health check:

```
mac-health
```
Run an individual check:

```
mac-health --storage
mac-health --security
mac-health --updates
```

Output the full report as JSON:

```
mac-health --json
```

Write the JSON report to a file

```
mac-health --json --output health.json
```
