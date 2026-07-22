// Loads every level (data/Levels/*.lvl) through the real game in headless Chromium
// and reports which ones fail to load (throw / reject during parse, init or the
// first frames of the update loop).
//
// Usage:
//   node test/check_levels.js                 # all levels, 6 workers
//   node test/check_levels.js --workers=8
//   node test/check_levels.js --limit=50      # quick subset (first 50)
//   node test/check_levels.js --filter=l101   # only files whose name contains "l101"
//   node test/check_levels.js --timeout=30000 # per-level timeout (ms)
//
// Requires the dev server running (node server.js → http://localhost:3001).
// Prints a summary to stdout and writes the failing levels to test/failing_levels.txt.

const { chromium } = require('playwright');
const fs   = require('fs');
const path = require('path');

const BASE     = process.env.XMOTO_URL || 'http://localhost:3001';
const PAGE_URL = BASE + '/test/level_loader.html';

function parseArgs() {
  const args = { workers: 6, limit: 0, timeout: 20000, filter: '' };
  for (const arg of process.argv.slice(2)) {
    const m = arg.match(/^--([^=]+)=(.*)$/);
    if (m) args[m[1]] = /^\d+$/.test(m[2]) ? Number(m[2]) : m[2];
  }
  return args;
}

async function main() {
  const args = parseArgs();

  const levelsDir = path.join(__dirname, '..', 'data', 'Levels');
  let files = fs.readdirSync(levelsDir).filter((f) => f.endsWith('.lvl')).sort();
  if (args.filter) files = files.filter((f) => f.includes(args.filter));
  if (args.limit)  files = files.slice(0, args.limit);

  if (files.length === 0) { console.error('No level files matched.'); process.exit(2); }

  console.log(`Checking ${files.length} levels with ${args.workers} worker(s) via ${PAGE_URL}`);

  const browser = await chromium.launch({
    headless: true,
    args: ['--use-gl=angle', '--use-angle=swiftshader', '--ignore-gpu-blocklist'],
  });

  const results = [];
  let cursor = 0, done = 0;
  const nextFile = () => (cursor < files.length ? files[cursor++] : null);

  // Hard ceiling so a wedged/crashed page (where the in-page timer can't fire and
  // page.evaluate never resolves) can't stall the whole run.
  const HARD_TIMEOUT = args.timeout + 10000;
  const withTimeout = (promise, ms) =>
    Promise.race([
      promise,
      new Promise((_, reject) => setTimeout(() => reject(new Error(`hard timeout after ${ms}ms`)), ms)),
    ]);

  async function worker() {
    let context = await browser.newContext();
    let page    = await context.newPage();

    const loadOne = async (file) => {
      // Fresh page load per level → fresh WebGL context, no leak/bleed between levels.
      await page.goto(PAGE_URL, { waitUntil: 'load', timeout: 30000 });
      return page.evaluate(([f, t]) => window.loadLevelForTest(f, t), [file, args.timeout]);
    };

    let file;
    while ((file = nextFile()) !== null) {
      let res;
      try {
        res = await withTimeout(loadOne(file), HARD_TIMEOUT);
      } catch (e) {
        res = { ok: false, error: 'harness: ' + (e.message || String(e)) };
        // The page may be wedged (renderer/GPU crash); recreate it so the worker continues.
        try { await context.close(); } catch (_) {}
        context = await browser.newContext();
        page    = await context.newPage();
      }

      results.push(Object.assign({ file }, res));
      done++;
      if (!res.ok) console.log(`  ✗ ${file}  —  ${res.error}`);
      if (done % 100 === 0) console.log(`  … ${done}/${files.length}`);
    }

    await context.close();
  }

  await Promise.all(Array.from({ length: Math.max(1, args.workers) }, worker));
  await browser.close();

  results.sort((a, b) => a.file.localeCompare(b.file));
  const failures = results.filter((r) => !r.ok);
  const warned   = results.filter((r) => r.ok && r.warnings && r.warnings.length);

  fs.writeFileSync(
    path.join(__dirname, 'failing_levels.txt'),
    failures.map((r) => `${r.file}\t${r.error}`).join('\n') + (failures.length ? '\n' : '')
  );

  console.log(`\nDone. ${results.length} checked — ${failures.length} failed, ${warned.length} loaded with warnings.`);
  console.log('Failures written to test/failing_levels.txt');
  process.exit(failures.length ? 1 : 0);
}

main().catch((e) => { console.error(e); process.exit(2); });
