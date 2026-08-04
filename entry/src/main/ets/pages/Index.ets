import { display } from '@kit.ArkUI';
import { ArcList, ArcListAttribute, ArcListItem, ArcListItemAttribute, LengthMetrics } from '@kit.ArkUI';
import {
  MATCH_TARGET_ITEMS,
  MatchTargetItem,
  MAX_LOG_ENTRIES,
  MOUSE_ZONE_ID,
  PlaygroundLogEntry,
  PlaygroundLogKind
} from '../model/PlaygroundModels';

const ARC_ITEM_WIDTH = '86%';

/** display.Display.rotation values (@ohos.display): 0/1/2/3 = 0/90/180/270
 * degrees clockwise. There's no exported Rotation enum for this - it's a
 * plain number - so the labels/angles are named here to match DisplayRotation. */
function rotationLabel(rotation: number): string {
  switch (rotation) {
    case 0:
      return 'ROTATION_0';
    case 1:
      return 'ROTATION_90';
    case 2:
      return 'ROTATION_180';
    case 3:
      return 'ROTATION_270';
    default:
      return `UNKNOWN(${rotation})`;
  }
}

function rotationAngle(rotation: number): number {
  switch (rotation) {
    case 0:
      return 0;
    case 1:
      return 90;
    case 2:
      return 180;
    case 3:
      return 270;
    default:
      return 0;
  }
}

function mouseButtonLabel(button: MouseButton): string {
  switch (button) {
    case MouseButton.Left:
      return 'Left';
    case MouseButton.Right:
      return 'Right';
    case MouseButton.Middle:
      return 'Middle';
    case MouseButton.Back:
      return 'Back';
    case MouseButton.Forward:
      return 'Forward';
    default:
      return 'None';
  }
}

function mouseActionLabel(action: MouseAction): string {
  switch (action) {
    case MouseAction.Press:
      return 'Press';
    case MouseAction.Release:
      return 'Release';
    case MouseAction.Hover:
      return 'Hover';
    case MouseAction.Move:
      return 'Move';
    default:
      return 'Other';
  }
}

function logKindColor(kind: PlaygroundLogKind): ResourceColor {
  switch (kind) {
    case PlaygroundLogKind.RESIZE:
      return $r('app.color.resize_accent');
    case PlaygroundLogKind.MOUSE:
      return $r('app.color.mouse_accent');
    case PlaygroundLogKind.MATCH:
      return $r('app.color.match_accent');
    case PlaygroundLogKind.ROTATION:
      return $r('app.color.rotation_accent');
    default:
      return $r('app.color.subtitle_text');
  }
}

/** Shared "card" look for every section Column - kept as an @Extend instead
 * of a reusable @Builder wrapper, since ArkUI doesn't allow a @Builder
 * function to accept an arbitrary child-content callback outside a
 * @BuilderParam-decorated component. */
@Extend(Column)
function cardColumn() {
  .width(ARC_ITEM_WIDTH)
  .padding($r('app.float.card_padding'))
  .backgroundColor($r('app.color.trigger_item_background'))
  .borderRadius($r('app.float.card_corner_radius'))
}

/**
 * PlaygroundPage: the single round-face screen ResizeDirectionTest,
 * MouseButtonTest, MatchPatternTest and DisplayRotationTest all drive via
 * @kit.TestKit's Driver/UiWindow/On. Every section below is its own
 * card so the four APIs under test stay visually separated on the round face.
 *
 * Resize itself (ResizeDirection) has no in-app trigger - UiWindow.resize()
 * is only callable from the ohosTest Driver, and is documented to reject on
 * a wearable, so there is nothing for the app to do but display that it's
 * the resize target. Rotation lock/force is the same story: only the
 * Driver can call setDisplayRotation()/setDisplayRotationEnabled(), and both
 * are documented no-ops here, so RotationStatusBar only ever reads
 * back the live value.
 */
@Entry
@Component
struct PlaygroundPage {
  @State lastMouseButton: string = '';
  @State lastMouseAction: string = '';
  @State lastMatchLabel: string = '';
  @State rotation: number = display.getDefaultDisplaySync().rotation;
  @State log: PlaygroundLogEntry[] = [];

  private onDisplayChange = (): void => {
    this.rotation = display.getDefaultDisplaySync().rotation;
  };

  aboutToAppear(): void {
    display.on('change', this.onDisplayChange);
  }

  aboutToDisappear(): void {
    display.off('change', this.onDisplayChange);
  }

  private appendLog(kind: PlaygroundLogKind, message: string): void {
    this.log = [new PlaygroundLogEntry(kind, message), ...this.log].slice(0, MAX_LOG_ENTRIES);
  }

  private handleMouseEvent(event: MouseEvent): void {
    if (event.action !== MouseAction.Press && event.action !== MouseAction.Release) {
      return;
    }
    this.lastMouseButton = mouseButtonLabel(event.button);
    this.lastMouseAction = mouseActionLabel(event.action);
    this.appendLog(PlaygroundLogKind.MOUSE, `Mouse ${this.lastMouseButton} ${this.lastMouseAction}`);
  }

  private handleMatchTap(item: MatchTargetItem): void {
    this.lastMatchLabel = item.label;
    this.appendLog(PlaygroundLogKind.MATCH, `Tapped "${item.label}"`);
  }

  @Builder
  cardHeader(color: ResourceColor, title: ResourceStr) {
    Row({ space: 6 }) {
      Circle({ width: $r('app.float.accent_dot_size'), height: $r('app.float.accent_dot_size') })
        .fill(color)
      Text(title)
        .fontSize($r('app.float.section_title_font_size'))
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.primary_text'))
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  matchChip(item: MatchTargetItem) {
    Text(item.label)
      .id(item.id)
      .fontSize($r('app.float.trigger_title_font_size'))
      .fontColor(item.label === this.lastMatchLabel ? $r('app.color.primary_button_text') : $r('app.color.primary_text'))
      .padding({
        left: $r('app.float.chip_padding_h'),
        right: $r('app.float.chip_padding_h'),
        top: $r('app.float.chip_padding_v'),
        bottom: $r('app.float.chip_padding_v')
      })
      .backgroundColor(item.label === this.lastMatchLabel ? $r('app.color.match_accent') : $r('app.color.chip_background'))
      .borderRadius($r('app.float.chip_corner_radius'))
      .onClick(() => this.handleMatchTap(item))
  }

  @Builder
  logRow(entry: PlaygroundLogEntry) {
    Row({ space: 6 }) {
      Circle({ width: $r('app.float.accent_dot_size'), height: $r('app.float.accent_dot_size') })
        .fill(logKindColor(entry.kind))
      Text(entry.message)
        .fontSize($r('app.float.detail_label_font_size'))
        .fontColor($r('app.color.subtitle_text'))
        .layoutWeight(1)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .width('100%')
    .alignItems(VerticalAlign.Top)
  }

  build() {
    ArcList({ initialIndex: 0 }) {
      ArcListItem() {
        Column({ space: 2 }) {
          Text($r('app.string.playground_page_title'))
            .width(ARC_ITEM_WIDTH)
            .fontSize($r('app.float.page_title_font_size'))
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.primary_text'))
            .textAlign(TextAlign.Center)
          Text($r('app.string.playground_page_subtitle'))
            .width(ARC_ITEM_WIDTH)
            .fontSize($r('app.float.page_subtitle_font_size'))
            .fontColor($r('app.color.subtitle_text'))
            .textAlign(TextAlign.Center)
        }
      }

      // Resize Target - ResizeDirectionTest's window.resize() target.
      ArcListItem() {
        Column({ space: $r('app.float.card_gap') }) {
          this.cardHeader($r('app.color.resize_accent'), $r('app.string.resize_probe_title'))
          Text($r('app.string.resize_probe_hint'))
            .width('100%')
            .fontSize($r('app.float.trigger_subtitle_font_size'))
            .fontColor($r('app.color.subtitle_text'))
            .textAlign(TextAlign.Center)
        }
        .id('resize-probe')
        .cardColumn()
      }

      // Match Target Rail - On.text()/MatchPattern targets.
      ArcListItem() {
        Column({ space: $r('app.float.card_gap') }) {
          this.cardHeader($r('app.color.match_accent'), $r('app.string.match_rail_title'))
          Text($r('app.string.match_rail_hint'))
            .width('100%')
            .fontSize($r('app.float.trigger_subtitle_font_size'))
            .fontColor($r('app.color.subtitle_text'))
            .textAlign(TextAlign.Center)
          Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Center }) {
            ForEach(MATCH_TARGET_ITEMS, (item: MatchTargetItem) => {
              this.matchChip(item)
            }, (item: MatchTargetItem) => item.id)
          }
          .width('100%')
          .padding({ top: 2 })

          Row({ space: 4 }) {
            Text($r('app.string.last_match_label'))
              .fontSize($r('app.float.detail_label_font_size'))
              .fontColor($r('app.color.subtitle_text'))
            Text(this.lastMatchLabel.length > 0 ? this.lastMatchLabel : $r('app.string.last_match_placeholder'))
              .id('last-match-label')
              .fontSize($r('app.float.detail_value_font_size'))
              .fontWeight(FontWeight.Medium)
              .fontColor(this.lastMatchLabel.length > 0 ? $r('app.color.match_accent') : $r('app.color.subtitle_text'))
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
        }
        .cardColumn()
      }

      // Mouse Zone - Driver.mouseClick/mouseDoubleClick/mouseLongClick target.
      ArcListItem() {
        Column({ space: $r('app.float.card_gap') }) {
          this.cardHeader($r('app.color.mouse_accent'), $r('app.string.mouse_zone_title'))
          Text($r('app.string.mouse_zone_hint'))
            .width('100%')
            .fontSize($r('app.float.trigger_subtitle_font_size'))
            .fontColor($r('app.color.subtitle_text'))
            .textAlign(TextAlign.Center)
          Column() {
            Text(
              this.lastMouseButton.length > 0
                ? `${this.lastMouseButton} / ${this.lastMouseAction}`
                : $r('app.string.mouse_zone_placeholder')
            )
              .id('mouse-zone-status')
              .fontSize($r('app.float.detail_value_font_size'))
              .fontWeight(FontWeight.Medium)
              .fontColor(this.lastMouseButton.length > 0 ? $r('app.color.mouse_accent') : $r('app.color.subtitle_text'))
              .textAlign(TextAlign.Center)
          }
          .id(MOUSE_ZONE_ID)
          .width('100%')
          .constraintSize({ minHeight: $r('app.float.mouse_zone_min_height') })
          .justifyContent(FlexAlign.Center)
          .backgroundColor($r('app.color.chip_background'))
          .borderRadius($r('app.float.chip_corner_radius'))
          .onMouse((event: MouseEvent) => this.handleMouseEvent(event))
        }
        .cardColumn()
      }

      // Rotation Status - Driver.setDisplayRotation/getDisplayRotation/
      // setDisplayRotationEnabled target; read-only, see the note above build().
      ArcListItem() {
        Column({ space: $r('app.float.card_gap') }) {
          this.cardHeader($r('app.color.rotation_accent'), $r('app.string.rotation_status_title'))
          Text($r('app.string.rotation_status_hint'))
            .width('100%')
            .fontSize($r('app.float.trigger_subtitle_font_size'))
            .fontColor($r('app.color.subtitle_text'))
            .textAlign(TextAlign.Center)
          Row({ space: 6 }) {
            Text('▲')
              .fontSize($r('app.float.rotation_arrow_size'))
              .fontColor($r('app.color.rotation_accent'))
              .rotate({ angle: rotationAngle(this.rotation) })
            Text(rotationLabel(this.rotation))
              .id('rotation-status-label')
              .fontSize($r('app.float.detail_value_font_size'))
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.primary_text'))
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
        }
        .cardColumn()
      }

      // Playground Log - visual trail of recognized in-app actions.
      ArcListItem() {
        Column({ space: $r('app.float.card_gap') }) {
          this.cardHeader($r('app.color.subtitle_text'), $r('app.string.playground_log_title'))
          if (this.log.length === 0) {
            Text($r('app.string.playground_log_empty'))
              .width('100%')
              .fontSize($r('app.float.trigger_subtitle_font_size'))
              .fontColor($r('app.color.subtitle_text'))
              .textAlign(TextAlign.Center)
          } else {
            Column({ space: 4 }) {
              ForEach(this.log, (entry: PlaygroundLogEntry) => {
                this.logRow(entry)
              }, (entry: PlaygroundLogEntry) => `${entry.kind}-${entry.timestamp}`)
            }
            .width('100%')
          }
        }
        .cardColumn()
      }
    }
    .space(LengthMetrics.resource($r('app.float.section_spacing')))
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
  }
}
