import React from 'react';

export function SegmentedControl({ options, value, onChange }) {
  return (
    <div style={{ display: 'flex', gap: 8 }}>
      {options.map(o => {
        const active = o === value;
        return (
          <span key={o} onClick={() => onChange && onChange(o)} style={{
            flex: 1, textAlign: 'center', padding: '11px 0',
            borderRadius: 'var(--radius-control)',
            background: active ? 'var(--text-primary)' : 'var(--surface-control)',
            color: active ? 'var(--bg)' : 'var(--text-muted)',
            fontFamily: 'var(--font-ui)', fontSize: 14, fontWeight: active ? 700 : 600, cursor: 'pointer'
          }}>{o}</span>
        );
      })}
    </div>
  );
}
