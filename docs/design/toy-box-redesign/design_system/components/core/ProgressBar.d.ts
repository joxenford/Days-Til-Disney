export interface ProgressBarProps {
  value: number;
  total: number;
  /** accent on light surfaces, gold inside a park panel */
  tone?: 'accent' | 'gold' | 'ink';
  height?: number;
}
export function ProgressBar(props: ProgressBarProps): JSX.Element;
