export interface ChipProps {
  children: React.ReactNode;
  /** onPark sits inside a park panel; surface sits on the page */
  tone?: 'onPark' | 'surface';
  selected?: boolean;
}
export function Chip(props: ChipProps): JSX.Element;
