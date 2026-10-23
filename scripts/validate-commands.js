#!/usr/bin/env node

"use strict";

const fs = require("node:fs");
const path = require("node:path");

const ROOT = path.resolve(__dirname, "..");

const DIRS = {
  claude: { dir: path.join(ROOT, ".claude", "commands"), ext: ".md" },
  gemini: { dir: path.join(ROOT, ".gemini", "commands"), ext: ".toml" },
  antigravity: { dir: path.join(ROOT, "commands"), ext: ".toml" },
};

function descriptionFromMd(filePath) {
  const content = fs.readFileSync(filePath, "utf8");
  const match = content.match(/^---\r?\n([\s\S]*?)\r?\n---/);
  if (!match) return null;
  const descMatch = match[1].match(/^description\s*:\s*(.+)$/m);
  if (!descMatch) return null;
  let val = descMatch[1].trim();
  if ((val.startsWith('"') && val.endsWith('"')) || (val.startsWith("'") && val.endsWith("'"))) {
    val = val.slice(1, -1);
  }
  return val;
}

function descriptionFromToml(filePath) {
  const content = fs.readFileSync(filePath, "utf8");
  const doubleMatch = content.match(/^description\s*=\s*"((?:[^"\\]|\\.)*)"/m);
  if (doubleMatch) return doubleMatch[1].replace(/\\"/g, '"');
  const singleMatch = content.match(/^description\s*=\s*'([^']*)'/m);
  return singleMatch ? singleMatch[1] : null;
}

function loadCommands({ dir, ext }) {
  if (!fs.existsSync(dir)) return {};
  return Object.fromEntries(
    fs
      .readdirSync(dir)
      .filter((f) => f.endsWith(ext))
      .map((f) => {
        const stem = path.basename(f, ext);
        const full = path.join(dir, f);
        const desc = ext === ".md" ? descriptionFromMd(full) : descriptionFromToml(full);
        return [stem, desc];
      }),
  );
}

function main() {
  const byTool = {
    claude: loadCommands(DIRS.claude),
    gemini: loadCommands(DIRS.gemini),
    antigravity: loadCommands(DIRS.antigravity),
  };

  const stems = new Set([
    ...Object.keys(byTool.claude),
    ...Object.keys(byTool.gemini),
    ...Object.keys(byTool.antigravity),
  ]);

  let errors = 0;

  for (const stem of [...stems].sort()) {
    const cDesc = byTool.claude[stem];
    const gDesc = byTool.gemini[stem];
    const aDesc = byTool.antigravity[stem];

    if (!cDesc || !gDesc || !aDesc) {
      console.log(`  ✗  /${stem} missing in one or more command directories`);
      errors++;
      continue;
    }

    if (cDesc !== gDesc || cDesc !== aDesc) {
      console.log(`  ✗  /${stem} description mismatch across .claude/commands, .gemini/commands, commands`);
      errors++;
      continue;
    }

    console.log(`  ✓  /${stem}`);
  }

  console.log(`\n${stems.size} command(s) checked across 3 tool directories — ${errors} error(s)`);
  if (errors > 0) process.exit(1);
}

main();
