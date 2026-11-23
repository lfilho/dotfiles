// Workflow-level tests: the Alfred plist (object graph and script action), the packaged
// .alfredworkflow, and the exact way Alfred launches the script. These guard the failures that never
// show up in the logic tests: a keyword not wired to its script ("only the notification shows"), a
// shipped file that does not parse, an artifact that drifted from the source.
import assert from "node:assert/strict";
import { execFileSync, spawnSync } from "node:child_process";
import { mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { describe, it } from "node:test";
import { PRELOAD_URL, SOURCE_DIR, at, norm, scenario, summarize } from "./helpers/run.mjs";

// build.sh points this at the freshly built zip so it can be tested before replacing the committed one.
const ARTIFACT = process.env.BLOCK_ARTIFACT ?? join(SOURCE_DIR, "..", "block-schedule.alfredworkflow");
const PLIST = join(SOURCE_DIR, "info.plist");

const has = (cmd) => spawnSync("sh", ["-c", `command -v ${cmd}`]).status === 0;
const noPlutil = has("plutil") ? false : "plutil is only available on macOS";
const noUnzip = has("unzip") ? false : "unzip not found";

const plistJson = () => JSON.parse(execFileSync("plutil", ["-convert", "json", "-o", "-", PLIST], { encoding: "utf8" }));
const unzipMember = (member) => execFileSync("unzip", ["-p", ARTIFACT, member], { maxBuffer: 10 * 1024 * 1024 });

describe("info.plist", { skip: noPlutil }, () => {
  // Loaded lazily: a skipped suite may still run this callback, and plutil exists only on macOS.
  let cached;
  const graph = () => {
    if (!cached) {
      const wf = plistJson();
      cached = {
        wf,
        objects: new Map(wf.objects.map((o) => [o.uid, o])),
        edges: Object.entries(wf.connections ?? {}).flatMap(([from, tos]) => tos.map((t) => [from, t.destinationuid])),
      };
    }
    return cached;
  };
  const isRoot = (o) => /^alfred\.workflow\.(input|trigger)\./.test(o.type);

  function reachableFrom(uid) {
    const seen = new Set([uid]);
    for (const queue = [uid]; queue.length; ) {
      for (const [from, to] of graph().edges) {
        if (from === queue[0] && !seen.has(to)) {
          seen.add(to);
          queue.push(to);
        }
      }
      queue.shift();
    }
    return seen;
  }

  it("is a valid property list", () => {
    execFileSync("plutil", ["-lint", PLIST]);
  });

  it("keeps its bundle id, so re-importing updates the installed workflow instead of duplicating it", () => {
    const { wf } = graph();
    assert.equal(wf.bundleid, "dev.luiz.blockschedule");
  });

  it("has the `block` keyword", () => {
    const { wf } = graph();
    const keywords = wf.objects.filter((o) => o.type === "alfred.workflow.input.keyword").map((o) => o.config.keyword);
    assert.ok(keywords.includes("block"), `keywords: ${keywords}`);
  });

  it("has no dangling connections", () => {
    const { objects, edges } = graph();
    for (const [from, to] of edges) {
      assert.ok(objects.has(from), `connection from unknown object ${from}`);
      assert.ok(objects.has(to), `connection to unknown object ${to}`);
    }
  });

  it("wires every input to something, and every other object to an input (nothing orphaned)", () => {
    const { wf, edges } = graph();
    const roots = wf.objects.filter(isRoot);
    assert.ok(roots.length > 0);
    for (const root of roots) {
      assert.ok(edges.some(([from]) => from === root.uid), `${root.type} "${root.config.keyword ?? root.uid}" is not connected to anything`);
    }
    const reachable = new Set(roots.flatMap((r) => [...reachableFrom(r.uid)]));
    for (const o of wf.objects) assert.ok(reachable.has(o.uid), `${o.type} (${o.uid}) is not reachable from any input`);
  });

  it("runs the script and then reports back when `block` is typed", () => {
    const { wf, objects } = graph();
    const keyword = wf.objects.find((o) => o.type === "alfred.workflow.input.keyword" && o.config.keyword === "block");
    const downstream = [...reachableFrom(keyword.uid)].map((uid) => objects.get(uid));
    assert.ok(downstream.some((o) => o.type === "alfred.workflow.action.script"), "keyword does not reach the script action");
    assert.ok(downstream.some((o) => o.type === "alfred.workflow.output.notification"), "script does not reach the notification");
  });

  it("runs block.mjs relative to the workflow dir with the query, and carries no machine-specific paths", () => {
    const { wf } = graph();
    const scripts = wf.objects.filter((o) => o.type === "alfred.workflow.action.script");
    assert.ok(scripts.length > 0);
    for (const { config } of scripts) {
      assert.equal(config.type, 0, "expected a bash script action");
      assert.equal(config.scriptfile, "", "expected an inline script");
      assert.match(config.script, /node block\.mjs "\{query\}"/);
      assert.doesNotMatch(config.script, /\/Users\//);
    }
  });
});

describe("the packaged .alfredworkflow", { skip: noUnzip }, () => {
  const members = () => execFileSync("unzip", ["-Z1", ARTIFACT], { encoding: "utf8" }).split("\n").filter(Boolean);

  it("contains the workflow files and not the tests", () => {
    const names = members();
    assert.ok(["info.plist", "block.mjs", "icon.png"].every((n) => names.includes(n)), names.join(", "));
    assert.ok(!names.some((n) => n.startsWith("test") || n.endsWith(".test.mjs")), names.join(", "));
  });

  for (const file of ["info.plist", "block.mjs", "icon.png"]) {
    it(`ships exactly the current ${file} (run ./build.sh if this fails)`, () => {
      assert.ok(unzipMember(file).equals(readFileSync(join(SOURCE_DIR, file))), `${file} in the .alfredworkflow differs from the source`);
    });
  }

  // Alfred shows icon.png as the workflow's icon. The tile has rounded corners, so it must keep its
  // alpha channel: a flattened export would put white corners on every theme.
  it("ships icon.png as a square RGBA PNG", () => {
    const png = unzipMember("icon.png");
    assert.deepEqual([...png.subarray(0, 8)], [0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a], "not a PNG");
    const [width, height, bitDepth, colorType] = [png.readUInt32BE(16), png.readUInt32BE(20), png[24], png[25]];
    assert.equal(width, height, `icon must be square, got ${width}x${height}`);
    assert.equal(bitDepth, 8);
    assert.equal(colorType, 6, "icon must be RGBA (color type 6) to keep its transparent corners");
  });

  it("ships a block.mjs that parses", () => {
    const dir = mkdtempSync(join(tmpdir(), "block-artifact-"));
    try {
      writeFileSync(join(dir, "block.mjs"), unzipMember("block.mjs"));
      const r = spawnSync(process.execPath, ["--check", join(dir, "block.mjs")], { encoding: "utf8" });
      assert.equal(r.status, 0, r.stderr);
    } finally {
      rmSync(dir, { recursive: true, force: true });
    }
  });
});

// Run the plist's own script string the way Alfred does: bash, cwd = the workflow dir, a minimal PATH.
// If this breaks, typing `block` in Alfred shows the notification and nothing else happens.
describe("launching from Alfred", { skip: process.platform === "darwin" ? noPlutil : "Alfred only runs on macOS" }, () => {
  it("the script action starts block.mjs and books a slot", () => {
    const script = plistJson().objects.find((o) => o.type === "alfred.workflow.action.script").config.script;
    const dir = mkdtempSync(join(tmpdir(), "block-alfred-"));
    const logFile = join(dir, "log.jsonl");
    try {
      const sc = scenario({ now: at(-420, 2026, 11, 23, 15, 37) });
      const r = spawnSync("/bin/bash", ["-c", script.split("{query}").join("30 contract test")], {
        cwd: SOURCE_DIR,
        env: {
          PATH: "/usr/bin:/bin:/usr/sbin:/sbin", // Alfred's PATH has no Homebrew; the script must add it
          HOME: dir,
          TZ: "America/Denver",
          BLOCK_DRY_RUN: "1",
          NODE_OPTIONS: `--import=${PRELOAD_URL}`,
          FAKE_SCENARIO: JSON.stringify(sc),
          FAKE_LOG: logFile,
        },
        encoding: "utf8",
        timeout: 20_000,
      });
      const out = summarize(r, logFile);
      assert.equal(out.code, 0, `exit ${out.code}: ${out.stderr}`);
      assert.equal(norm(out.stdout.trim()), "[dry run] Scheduled for Mon, Nov 23, 3:40 PM");
    } finally {
      rmSync(dir, { recursive: true, force: true });
    }
  });
});
