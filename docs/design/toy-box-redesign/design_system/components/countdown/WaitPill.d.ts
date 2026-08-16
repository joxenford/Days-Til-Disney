export interface WaitPillProps {
  /** standby wait in minutes; null renders 'Walk-on' */
  minutes: number | null;
  /** mirrors AttractionStatus in Engine/LiveParkData/ParkLiveData.swift */
  status?: 'operating' | 'closed' | 'refurbishment' | 'down';
}
export function WaitPill(props: WaitPillProps): JSX.Element;
