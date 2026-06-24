const cp = require('child_process');

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
    const isThinking = d.is_thinking || false;

    let branch = '';
    try {
      branch = cp.execSync(`git -C "${cwd}" branch --show-current 2>nul`, {timeout:2000}).toString().trim();
    } catch(_) {}

    let dirty = false;
    if (branch) {
      try {
        const s = cp.execSync(`git -C "${cwd}" status --porcelain 2>nul`, {timeout:2000}).toString().trim();
        dirty = s.length > 0;
      } catch(_) {}
    }

    // progress bar
    const BAR_W  = 20;
    const filled = Math.min(Math.round(pct * BAR_W / 100), BAR_W);
    const bar    = '\u2588'.repeat(filled) + '\u2591'.repeat(BAR_W - filled);

    // context label
    let ctxLabel = '';
    if (total >= 1000000)    ctxLabel = `${Math.round(total/1000000)}M context`;
    else if (total >= 1000)  ctxLabel = `${Math.round(total/1000)}K context`;

    // ANSI
    const E   = '\x1b[';
    const R   = '\x1b[0m';
    const B   = '\x1b[1m';
    const DIM = '\x1b[2m';
    const W   = '\x1b[97m';
    const BL  = '\x1b[94m';
    const GR  = '\x1b[32m';
    const YL  = '\x1b[33m';
    const RED = '\x1b[31m';
    const GRY = '\x1b[37m';

    const barClr = pct >= 80 ? RED : pct >= 50 ? YL : GR;

    // pulse dot: green = idle, orange = thinking
    const dot = isThinking ? '\x1b[38;5;208m\u25CF' : `${GR}\u25CF`;

    // build line
    let line = `${dot}${R} `;
    line += `${B}${W}~/${dirname}${R}`;
    if (branch) {
      line += ` ${DIM}(${R}${BL}${branch}${R}`;
      if (dirty) line += `${RED}*${R}`;
      line += `${DIM})${R}`;
    }
    line += `  ${DIM}[${R}${barClr}${bar}${R}${DIM}]${R}`;
    line += ` ${B}${pct}%${R}${DIM} used${R}`;
    line += `  ${GRY}${DIM}${model}`;
    if (ctxLabel) line += ` (${ctxLabel})`;
    line += R;

    process.stdout.write(line + '\n');

  } catch(e) {
    process.stdout.write('! ' + e.message + '\n');
  }
});