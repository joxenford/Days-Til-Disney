import React from 'react';

export function Checkbox({ label, checked = false, onToggle }) {
  return (
    <div onClick={onToggle} style={{ display: 'flex', alignItems: 'center', gap: 12, cursor: 'pointer', minHeight: 'var(--tap-min)' }}>
      <span style={{
        width: 24, height: 24, flex: '0 0 24px', borderRadius: 'var(--radius-check)',
        background: checked ? 'var(--accent-interactive)' : 'transparent',
        border: checked ? 'none' : 'var(--border-checkbox)',
        color: 'var(--on-accent)', display: 'grid', placeItems: 'center', fontSize: 12, fontWeight: 800
      }}>{checked ? '✓' : ''}</span>
      <span style={{
        fontFamily: 'var(--font-prose)', fontSize: 16,
        color: checked ? 'var(--text-done)' : 'var(--text-primary)',
        textDecoration: checked ? 'line-through' : 'none'
      }}>{label}</span>
    </div>
  );
}
