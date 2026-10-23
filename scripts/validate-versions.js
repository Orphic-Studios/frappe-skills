#!/usr/bin/env node

"use strict";

const fs = require("node:fs");
const path = require("node:path");

const ROOT = path.resolve(__dirname, "..");

const manifestPaths = [
  "plugin.json",
  "skills.json",
  ".codex-plugin/plugin.json",
  ".claude-plugin/plugin.json",
  ".claude-plugin/marketplace.json",
  ".agents/plugins/marketplace.json",
];

function readManifestVersion(manifestPath) {
  const fullPath = path.join(ROOT, manifestPath);
  const raw = fs.readFileSync(fullPath);
  if (raw[0] === 0xef && raw[1] === 0xbb && raw[2] === 0xbf) {
    throw new Error(`${manifestPath} contains an unexpected UTF-8 BOM`);
  }
  const manifest = JSON.parse(raw.toString("utf8"));
  return manifest.version ?? manifest.plugins?.[0]?.version;
}

function checkRepoForBom(dir) {
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    if (entry.name === ".git" || entry.name === "node_modules") continue;
    const fullPath = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      checkRepoForBom(fullPath);
    } else if (entry.isFile()) {
      const buf = fs.readFileSync(fullPath);
      if (buf.length >= 3 && buf[0] === 0xef && buf[1] === 0xbb && buf[2] === 0xbf) {
        throw new Error(`${path.relative(ROOT, fullPath)} contains an unexpected UTF-8 BOM`);
      }
    }
  }
}

checkRepoForBom(ROOT);

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

console.log(`All ${manifestPaths.length} plugin manifests are valid JSON (no BOM in repo) and use version ${expectedVersion}.`);
