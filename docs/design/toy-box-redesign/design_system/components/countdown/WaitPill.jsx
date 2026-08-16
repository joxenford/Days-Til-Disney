import React from 'react';

export function WaitPill({ minutes, status = 'operating' }) {
  if (status !== 'operating') {
    const labels = { closed: 'CLOSED', refurbishment: 'REFURB', down: 'DOWN' };
    return <span style={{
      background: 'var(--surface-raised)', color: 'var(--text-muted)',
      borderRadius: 'var(--radius-pill)', padding: '6px 11px',
      fontFamily: 'var(--font-ui)', fontSize: 11, fontWeight: 700, letterSpacing: '.6px'
    }}>{labels[status]}</span>;
  }
  const tone = minutes == null ? 'var(--wait-short)'
    : minutes < 20 ? 'var(--wait-short)'
    : minutes < 45 ? 'var(--wait-mid)'
    : 'var(--wait-long)';
  return (
    <span style={{
      color: tone, borderRadius: 'var(--radius-pill)', padding: '4px 12px',
      background: 'rgba(255,255,255,.06)',
      fontFamily: 'var(--font-ui)', fontSize: 19, fontWeight: 700, whiteSpace: 'nowrap'
    }}>{minutes == null ? 'Walk-on' : minutes + ' min'}</span>
  );
}
