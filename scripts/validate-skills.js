#!/usr/bin/env node

"use strict";

const fs = require("node:fs");
const path = require("node:path");

const ROOT = path.resolve(__dirname, "..");
const SKILLS_DIR = path.join(ROOT, "skills");
const AGENTS_DIR = path.join(ROOT, "agents");

function parseFrontmatter(content) {
  const match = content.match(/^---\r?\n([\s\S]*?)\r?\n---/);
  if (!match) return null;
  const block = match[1];
  const result = {};
  for (const line of block.split(/\r?\n/)) {
    const m = line.match(/^([a-zA-Z0-9_-]+)\s*:\s*(.*)$/);
    if (m) {
      let val = m[2].trim();
      if ((val.startsWith('"') && val.endsWith('"')) || (val.startsWith("'") && val.endsWith("'"))) {
        val = val.slice(1, -1);
      }
      result[m[1]] = val;
    }
  }
  return result;
}

function checkNoBom(filePath) {
  const buf = fs.readFileSync(filePath);
  if (buf[0] === 0xef && buf[1] === 0xbb && buf[2] === 0xbf) {
    return `${path.relative(ROOT, filePath)} contains a UTF-8 BOM`;
  }
  return null;
}

function main() {
  if (!fs.existsSync(SKILLS_DIR)) {
    console.error(`ERROR: skills directory not found at ${SKILLS_DIR}`);
    process.exit(1);
  }

  const skillDirs = fs
    .readdirSync(SKILLS_DIR)
    .filter((d) => fs.statSync(path.join(SKILLS_DIR, d)).isDirectory())
    .sort();

  let errors = 0;

  for (const dirName of skillDirs) {
    const skillMd = path.join(SKILLS_DIR, dirName, "SKILL.md");
    const fileErrors = [];

    if (!fs.existsSync(skillMd)) {
      fileErrors.push("missing SKILL.md");
    } else {
      const bomErr = checkNoBom(skillMd);
      if (bomErr) fileErrors.push(bomErr);

      const content = fs.readFileSync(skillMd, "utf8");
      const fm = parseFrontmatter(content);
      if (!fm) {
        fileErrors.push("missing YAML frontmatter");
      } else {
        if (!fm.name) fileErrors.push('missing "name" in frontmatter');
        else if (fm.name !== dirName) fileErrors.push(`frontmatter name "${fm.name}" does not match directory "${dirName}"`);

        if (!fm.description) fileErrors.push('missing "description" in frontmatter');
        else if (fm.description.length > 1024) fileErrors.push(`description too long (${fm.description.length} > 1024 chars)`);
      }
    }

    if (fileErrors.length === 0) {
      console.log(`  ✓  skills/${dirName}`);
    } else {
      console.log(`  ✗  skills/${dirName}`);
      for (const e of fileErrors) console.log(`       ERROR: ${e}`);
      errors += fileErrors.length;
    }
  }

  const personaFiles = fs.existsSync(AGENTS_DIR)
    ? fs
        .readdirSync(AGENTS_DIR)
        .filter((f) => f.endsWith(".md") && !/^readme\.md$/i.test(f))
        .sort()
    : [];

  if (personaFiles.length > 0) console.log("");
  for (const fileName of personaFiles) {
    const fullPath = path.join(AGENTS_DIR, fileName);
    const stem = path.basename(fileName, ".md");
    const fileErrors = [];

    const bomErr = checkNoBom(fullPath);
    if (bomErr) fileErrors.push(bomErr);

    const content = fs.readFileSync(fullPath, "utf8");
    const fm = parseFrontmatter(content);
    if (!fm) {
      fileErrors.push("missing YAML frontmatter");
    } else {
      if (!fm.name) fileErrors.push('missing "name" in frontmatter');
      else if (fm.name !== stem) fileErrors.push(`frontmatter name "${fm.name}" does not match file "${stem}"`);

      if (!fm.description) fileErrors.push('missing "description" in frontmatter');
    }

    if (!content.includes("## Composition")) {
      fileErrors.push('missing "## Composition" section');
    }

    if (fileErrors.length === 0) {
      console.log(`  ✓  agents/${fileName}`);
    } else {
      console.log(`  ✗  agents/${fileName}`);
      for (const e of fileErrors) console.log(`       ERROR: ${e}`);
      errors += fileErrors.length;
    }
  }

  console.log(`\n${skillDirs.length} skills and ${personaFiles.length} personas checked — ${errors} error(s)`);
  if (errors > 0) process.exit(1);
}

main();
