import React from 'react';

export function Toggle({ on = false, onChange, label }) {
  return (
    <span role="switch" aria-checked={on} aria-label={label} onClick={onChange} style={{
      width: 50, height: 30, flex: '0 0 50px', borderRadius: 'var(--radius-pill)',
      background: on ? 'var(--accent-interactive)' : 'var(--hairline)', position: 'relative', cursor: 'pointer', display: 'inline-block'
    }}>
      <span style={{
        position: 'absolute', top: 3, left: on ? 23 : 3, width: 24, height: 24,
        borderRadius: 'var(--radius-pill)', background: 'var(--knob)'
      }} />
    </span>
  );
}
