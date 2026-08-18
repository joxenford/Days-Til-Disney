/**
 * @startingPoint section="Countdown" subtitle="Park-coloured hero panel with countdown" viewport="390x300"
 */
export interface ParkPanelProps {
  /** A --park-panel-* role (never a raw --park-* primary or -deep value, never a gradient).
   *  The role resolves to the park primary on light and the deep variant on dark. */
  park?: string;
  /** uppercase park name, e.g. 'MAGIC KINGDOM' */
  label?: string;
  /** small pill at top-right: 'PRIMARY', 'IN PARK' */
  badge?: string;
  children?: React.ReactNode;
  compact?: boolean;
}
export function ParkPanel(props: ParkPanelProps): JSX.Element;
