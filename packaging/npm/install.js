#!/usr/bin/env node
/**
 * Download ORG/GITHUB_REPO release binary for this platform.
 * Replace ORG, GITHUB_REPO, BINARY_NAME before publishing.
 */
const fs = require("fs");
const path = require("path");
const https = require("https");
const { execSync } = require("child_process");

const ORG = "ORG";
const REPO = "GITHUB_REPO";
const BIN = "BINARY_NAME";
const version = require("./package.json").version;

const platform = process.platform;
const arch = process.arch === "x64" ? "amd64" : process.arch === "arm64" ? "arm64" : process.arch;
let os = platform;
let ext = "";
if (platform === "win32") {
  os = "windows";
  ext = ".exe";
} else if (platform === "darwin") os = "darwin";
else if (platform === "linux") os = "linux";

const asset = `${BIN}_${version}_${os}_${arch}${platform === "win32" ? ".zip" : ""}`;
const tag = version.startsWith("v") ? version : `v${version}`;
const url = `https://github.com/${ORG}/${REPO}/releases/download/${tag}/${asset}`;

const binDir = path.join(__dirname, "bin");
const dest = path.join(binDir, BIN + (platform === "win32" ? ".exe" : ""));

function get(url, follow = 0) {
  return new Promise((resolve, reject) => {
    https.get(url, { headers: { "User-Agent": "npm-postinstall" } }, (res) => {
      if (res.statusCode >= 300 && res.statusCode < 400 && res.headers.location && follow < 5) {
        return resolve(get(res.headers.location, follow + 1));
      }
      if (res.statusCode !== 200) {
        reject(new Error(`HTTP ${res.statusCode} for ${url}`));
        return;
      }
      const chunks = [];
      res.on("data", (c) => chunks.push(c));
      res.on("end", () => resolve(Buffer.concat(chunks)));
    }).on("error", reject);
  });
}

(async () => {
  if (version.includes("template")) {
    console.warn("[BINARY_NAME] template package — skip binary download");
    return;
  }
  fs.mkdirSync(binDir, { recursive: true });
  const data = await get(url);
  if (asset.endsWith(".zip")) {
    const tmp = path.join(binDir, asset);
    fs.writeFileSync(tmp, data);
    execSync(`unzip -o -j "${tmp}" -d "${binDir}"`, { stdio: "inherit" });
    fs.unlinkSync(tmp);
  } else {
    fs.writeFileSync(dest, data, { mode: 0o755 });
  }
  if (platform !== "win32") fs.chmodSync(dest, 0o755);
})().catch((err) => {
  console.error("[BINARY_NAME] postinstall failed:", err.message);
  process.exit(0);
});
