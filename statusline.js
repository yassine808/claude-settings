const cp = require('child_process');

process.stdin.resume();
let raw = '';
process.stdin.on('data', c => raw += c);
process.stdin.on('end', () => {
  try {
    const d = JSON.parse(raw);

    const cwd     = d.cwd || '';
    const dirname = cwd.split(/[\\/]/).pop();
    const model   = (d.model && d.model.display_name) || '';
    const total   = d.context_window.context_window_size || 0;
    const used    = d.context_window.total_input_tokens  || 0;
    const pct     = total > 0 ? Math.round((used / total) * 100) : 0;
    const added   = d.cost.total_lines_added   || 0;
    const removed = d.cost.total_lines_removed || 0;
    const ms      = d.cost.total_duration_ms   || 0;

    let branch = '';
    try {
      branch = cp.execSync(`git -C "${cwd}" branch --show-current 2>nul`, {timeout:2000}).toString().trim();
    } catch(_) {}

    const BAR_W  = 20;
    const filled = Math.min(Math.round(pct * BAR_W / 100), BAR_W);
    const bar    = '\u2588'.repeat(filled) + '\u2591'.repeat(BAR_W - filled);

    const R   = '\x1b[0m', B = '\x1b[1m', D = '\x1b[2m';
    const W   = '\x1b[97m', BL = '\x1b[94m', GR = '\x1b[32m';
    const RED = '\x1b[31m', ORG = '\x1b[38;5;208m';
    const barClr = pct >= 80 ? RED : pct >= 70 ? ORG : GR;

    let timeStr = '';
    if (ms > 0) {
      const totalSec = Math.floor(ms / 1000);
      const h = Math.floor(totalSec / 3600);
      const m = Math.floor((totalSec % 3600) / 60);
      const s = totalSec % 60;
      let t = '';
      if (h > 0)      t = `${h}h ${m}m`;
      else if (m > 0) t = `${m}m ${s}s`;
      else            t = `${s}s`;
      timeStr = `${D}⏱ ${t}${R}`;
    }

    let linesStr = '';
    if (added > 0 || removed > 0) {
      linesStr = `  ${GR}+${added}${R} ${RED}-${removed}${R}`;
    }

    let left = `${B}${W}\uD83D\uDCC2 ${dirname}${R}`;
    if (branch) left += ` ${D}>${R} ${BL}\uD83C\uDF43 ${branch}${R}`;
    left += linesStr;

    let right = '';
    if (timeStr) right += `${timeStr}  `;
    right += `${D}${model}${R}  ${B}${W}${pct}%${R}  ${barClr}${bar}${R}`;

    const strip  = s => s.replace(/\x1b\[[0-9;]*m/g, '');
    const visLen = s => strip(s).length;

    const termWidth = process.stdout.columns || 120;
    const pad = Math.max(1, termWidth - visLen(left) - visLen(right) - 1);

    process.stdout.write(left + ' '.repeat(pad) + right + '\n');

  } catch(e) {
    process.stdout.write('statusline err: ' + e.message + '\n');
  }
});