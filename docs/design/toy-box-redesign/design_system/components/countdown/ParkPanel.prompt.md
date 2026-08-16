The one park-coloured element per screen; everything else stays neutral.

```jsx
<ParkPanel park="var(--park-panel-magic-kingdom)" label="MAGIC KINGDOM" badge="PRIMARY">
  <CountdownNumeral value={45} unit="days" />
</ParkPanel>
```

Never place two park panels on one screen, never gradient-fill it, and never put a photo behind it. Pass a `--park-panel-*` role, not a raw `--park-*` value — the role handles light/dark itself, so no call site makes that decision.
