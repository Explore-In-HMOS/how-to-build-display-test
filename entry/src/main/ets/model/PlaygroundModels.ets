/** Kind of action PlaygroundLog renders, one per UiTest API under test. */
export enum PlaygroundLogKind {
  RESIZE = 'RESIZE',
  MOUSE = 'MOUSE',
  MATCH = 'MATCH',
  ROTATION = 'ROTATION'
}

/** One row in PlaygroundLog: a recognized action plus when it happened. */
export class PlaygroundLogEntry {
  readonly kind: PlaygroundLogKind;
  readonly message: string;
  readonly timestamp: number;

  constructor(kind: PlaygroundLogKind, message: string) {
    this.kind = kind;
    this.message = message;
    this.timestamp = Date.now();
  }
}

/** PlaygroundLog only keeps the most recent entries. */
export const MAX_LOG_ENTRIES = 6;

/** One button on MatchTargetRail. */
export class MatchTargetItem {
  readonly id: string;
  readonly label: string;

  constructor(id: string, label: string) {
    this.id = id;
    this.label = label;
  }
}

/**
 * Deliberately overlapping labels so every MatchPattern (EQUALS / CONTAINS /
 * STARTS_WITH / ENDS_WITH / REG_EXP / REG_EXP_ICASE) resolves a different
 * (or no) button - see MatchPatternTest.
 */
export const MATCH_TARGET_ITEMS: MatchTargetItem[] = [
  new MatchTargetItem('match-submit', 'Submit'),
  new MatchTargetItem('match-submit-form', 'Submit Form'),
  new MatchTargetItem('match-submit-2', 'submit-2'),
  new MatchTargetItem('match-resubmit', 'RESUBMIT')
];

/** Id MouseButtonTest uses to locate MouseZone via ON.id(). */
export const MOUSE_ZONE_ID = 'mouse-zone';
