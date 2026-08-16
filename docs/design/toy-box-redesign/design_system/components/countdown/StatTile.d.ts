export interface StatTileProps {
  label: string;
  value: number | string;
  /** denominator rendered smaller, e.g. '/38' */
  sub?: string;
  caption?: string;
  /** e.g. a ProgressBar under the numeral */
  children?: React.ReactNode;
}
export function StatTile(props: StatTileProps): JSX.Element;
