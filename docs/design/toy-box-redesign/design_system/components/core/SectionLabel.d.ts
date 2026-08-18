export interface SectionLabelProps {
  children: React.ReactNode;
  /** wider tracking for standalone section headers */
  loose?: boolean;
  tone?: 'muted' | 'gold' | 'onPark';
}
export function SectionLabel(props: SectionLabelProps): JSX.Element;
