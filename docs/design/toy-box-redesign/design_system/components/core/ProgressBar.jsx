import React from 'react';

export function ProgressBar({ value, total, tone = 'accent', height = 8 }) {
  const pct = total > 0 ? Math.min(100, Math.round((value / total) * 100)) : 0;
  const fills = { accent: 'var(--accent-interactive)', gold: 'var(--gold)', ink: 'var(--text-primary)' };
  return (
    <div role="progressbar" aria-valuenow={value} aria-valuemax={total} style={{
      height, borderRadius: 'var(--radius-pill)', background: 'var(--hairline)', overflow: 'hidden'
    }}>
      <div style={{ width: pct + '%', height, borderRadius: 'var(--radius-pill)', background: fills[tone] }} />
    </div>
  );
}
