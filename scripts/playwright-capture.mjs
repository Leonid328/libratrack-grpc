#!/usr/bin/env node
/**
 * Playwright screenshots for gRPC homework (REST gateway + GitHub + Sonar org).
 * Requires: server + gateway already running on :50051 and :8080
 */
import { chromium } from "playwright";
import { mkdir } from "fs/promises";
import path from "path";
import { fileURLToPath } from "url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const OUT = path.join(__dirname, "..", "docs", "screenshots", "playwright");
const PORT = process.env.PLAYWRIGHT_GATEWAY_PORT || "8087";
const STATIC = process.env.PLAYWRIGHT_STATIC_PORT || "8765";

const shots = [
  {
    name: "07-rest-get-copy-unary-static.png",
    url: `http://127.0.0.1:${STATIC}/rest-unary-demo.html`,
    wait: 800,
  },
  {
    name: "07-rest-get-copy-unary.png",
    url: `http://127.0.0.1:${PORT}/v1/copies/copy-1`,
    wait: 1500,
  },
  {
    name: "08-rest-unknown-404.png",
    url: `http://127.0.0.1:${PORT}/v1/copies/does-not-exist`,
    wait: 1500,
  },
  {
    name: "09-github-repo.png",
    url: "https://github.com/Leonid328/libratrack-grpc",
    wait: 2500,
  },
  {
    name: "10-github-actions-ci.png",
    url: "https://github.com/Leonid328/libratrack-grpc/actions/workflows/ci.yml",
    wait: 2500,
  },
  {
    name: "11-sonar-org-projects.png",
    url: "https://sonarcloud.io/organizations/leonid328/projects",
    wait: 3000,
  },
  {
    name: "12-sonar-python-project-example.png",
    url: "https://sonarcloud.io/project/overview?id=Leonid328_python",
    wait: 3000,
  },
];

async function main() {
  await mkdir(OUT, { recursive: true });
  const browser = await chromium.launch({
    headless: true,
    channel: process.env.PW_CHANNEL || "chrome",
  });
  const page = await browser.newPage({ viewport: { width: 1280, height: 800 } });

  for (const s of shots) {
    try {
      await page.goto(s.url, { waitUntil: "domcontentloaded", timeout: 60000 });
      await page.waitForTimeout(s.wait);
      await page.screenshot({
        path: path.join(OUT, s.name),
        fullPage: s.url.includes("github.com") || s.url.includes("sonarcloud"),
      });
      console.log("OK", s.name);
    } catch (e) {
      console.error("FAIL", s.name, e.message);
    }
  }

  await browser.close();
  console.log("Saved to", OUT);
}

main();
