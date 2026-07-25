const cp = require('child_process');
const fs = require('fs');
const os = require('os');
process.stdin.resume();
let raw = '';
process.stdin.on('data', c => raw += c);
process.stdin.on('end', () => {
  try {
    const d = JSON.parse(raw);
    const cwd     = (d.cwd || d.workspace?.current_dir || '');
    const dirname = cwd.split(/[\\/]/).pop() || cwd;
    const model   = d.model?.display_name || '';
    const total   = d.context_window?.context_window_size || 0;
    const used    = d.context_window?.total_input_tokens  || 0;
    const pct     = total > 0 ? Math.round((used / total) * 100) : 0;
    const added   = d.cost?.total_lines_added   || 0;
    const removed = d.cost?.total_lines_removed || 0;
    const fiveHour = d.rate_limits && d.rate_limits.five_hour;

    let branch = '';
    try {
      branch = cp.execSync(`git -C "${cwd}" branch --show-current 2>nul`, {timeout:2000}).toString().trim();
    } catch(_) {}

    // 5h session rate-limit bar — always shown per request, regardless of
    // whether context-window info is present.
    const BAR_W  = 20;
    const fhPct  = (fiveHour && typeof fiveHour.used_percentage === 'number')
      ? Math.max(0, Math.min(100, Math.round(fiveHour.used_percentage)))
      : 0;
    const fhFilled = Math.min(Math.round(fhPct * BAR_W / 100), BAR_W);
    const fhBar     = '\u2588'.repeat(fhFilled) + '\u2591'.repeat(BAR_W - fhFilled);

    let fhResetStr = '';
    if (fiveHour && fiveHour.resets_at) {
      // resets_at is Unix epoch seconds
      const resetMs = fiveHour.resets_at * 1000 - Date.now();
      if (resetMs > 0) {
        const totalMin = Math.round(resetMs / 60000);
        const h = Math.floor(totalMin / 60);
        const m = totalMin % 60;
        fhResetStr = h > 0 ? `${h}h ${m}m` : `${m}m`;
      }
    }

    let sessionTokens = 0;
    if (d.transcript_path && fs.existsSync(d.transcript_path)) {
      try {
        const lines = fs.readFileSync(d.transcript_path, 'utf8').split('\n');
        for (const line of lines) {
          if (!line) continue;
          let entry;
          try { entry = JSON.parse(line); } catch(_) { continue; }
          const u = entry && entry.message && entry.message.usage;
          if (!u) continue;
          sessionTokens += (u.input_tokens || 0) + (u.output_tokens || 0) +
            (u.cache_creation_input_tokens || 0) + (u.cache_read_input_tokens || 0);
        }
      } catch(_) {}
    }

    // ANSI
    const R   = '\x1b[0m';
    const B   = '\x1b[1m';
    const D   = '\x1b[2m';
    const W   = '\x1b[97m';
    const GR  = '\x1b[32m';
    const YL  = '\x1b[33m';
    const RED = '\x1b[31m';
    const pctClr   = pct   >= 80 ? RED : pct   >= 70 ? YL : GR;
    const fhBarClr = fhPct >= 80 ? RED : fhPct >= 50 ? YL : GR;

    const dot = `${GR}\u25CF`;

    let tokStr = '';
    if (sessionTokens > 0) {
      const fmt = n => n >= 1000000 ? (n/1000000).toFixed(1)+'M' : n >= 1000 ? (n/1000).toFixed(1)+'k' : String(n);
      tokStr = `${D}${fmt(sessionTokens)} tokens${R}`;
    }

    let linesStr = '';
    if (added > 0 || removed > 0) {
      linesStr = ` ${GR}+${added}${R} ${RED}-${removed}${R}`;
    }

    // --- left: dot + folder + branch (emoji design) + lines ---
    let left = `${dot}${R} `;
    left += `${B}${W}\ud83d\udcc1 ${dirname}${R}`;
    if (branch) {
      left += ` ${D}->${R} \ud83c\udf43 ${GR}${branch}${R}`;
    }
    left += linesStr;

    // --- right: model (effort) + context% (no bar) + 5h session bar + tokens + reset ---
    let right = `${D}${model}${R}  ${D}|${R}  ${D}ctx${R} ${pctClr}${pct}%${R}`;
    const resetLabel = fhResetStr ? `reset in: ${fhResetStr}` : 'reset in: --';
    right += `  ${D}|${R}  ${D}${resetLabel}${R} ${D}[${R}${fhBarClr}${fhBar}${R}${D}]${R} ${fhBarClr}${fhPct}%${R}`;
    if (tokStr) right += `  ${D}|${R}  ${tokStr}`;

    const strip  = s => s.replace(/\x1b\[[0-9;]*m/g, '');
    const visLen = s => strip(s).length;

    const termWidth = process.stdout.columns || 120;
    const pad = Math.max(1, termWidth - visLen(left) - visLen(right) - 1);

    process.stdout.write(left + ' '.repeat(pad) + right + '\n');

  } catch(e) {
    process.stdout.write('statusline err: ' + e.message + '\n');
  }
});
