#!/usr/bin/env node

"use strict";

const { readFileSync } = require("node:fs");

const manifestPaths = [
  "plugin.json",
  "skills.json",
  ".codex-plugin/plugin.json",
  ".claude-plugin/plugin.json",
  ".claude-plugin/marketplace.json",
  ".agents/plugins/marketplace.json",
];

function readManifestVersion(manifestPath) {
  const raw = readFileSync(manifestPath);
  if (raw[0] === 0xef && raw[1] === 0xbb && raw[2] === 0xbf) {
    throw new Error(`${manifestPath} contains an unexpected UTF-8 BOM`);
  }
  const manifest = JSON.parse(raw.toString("utf8"));
  return manifest.version ?? manifest.plugins?.[0]?.version;
}

const expectedVersion = readManifestVersion("plugin.json");
if (!expectedVersion) {
  throw new Error("plugin.json is missing a version field");
}

for (const manifestPath of manifestPaths) {
  const version = readManifestVersion(manifestPath);
  if (version !== expectedVersion) {
    throw new Error(
      `${manifestPath} has version ${version ?? "<missing>"}; expected ${expectedVersion}`,
    );
  }
}

console.log(`All ${manifestPaths.length} plugin manifests are valid JSON (no BOM) and use version ${expectedVersion}.`);
