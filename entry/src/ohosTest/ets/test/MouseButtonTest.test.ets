import { Component, Driver, MouseButton, ON, Point } from '@kit.TestKit';
import { describe, beforeEach, it, expect } from '@ohos/hypium';
import { MOUSE_ZONE_ID } from '../../../main/ets/model/PlaygroundModels';

/** KeyCode.KEYCODE_CTRL_LEFT (@ohos.multimodalInput.keyCode), used to prove
 * mouseLongClick() also accepts a modifier key alongside the MouseButton. */
const KEYCODE_CTRL_LEFT = 2072;

const MOUSE_ZONE_STATUS_ID = 'mouse-zone-status';

async function findMouseZoneCenter(driver: Driver): Promise<Point> {
  const zone: Component = await driver.findComponent(ON.id(MOUSE_ZONE_ID));
  return zone.getBoundsCenter();
}

async function readMouseZoneStatus(driver: Driver): Promise<string> {
  const status: Component = await driver.findComponent(ON.id(MOUSE_ZONE_STATUS_ID));
  return status.getText();
}

/**
 * Exercises every MouseButton value, plus a double-click and a Ctrl-modifier
 * long-click, against MouseZone's onMouse handler. Unlike
 * ResizeDirection/DisplayRotation, mouseClick()/mouseDoubleClick()/
 * mouseLongClick() are documented to behave the same on every device type,
 * so on a wearable these are expected to actually land and be reported.
 */
export default function mouseButtonTest() {
  describe('MouseButtonTest', () => {
    let driver: Driver;

    beforeEach(() => {
      driver = Driver.create();
    });

    it('mouseClick_left_isReported', 0, async () => {
      const point = await findMouseZoneCenter(driver);
      await driver.mouseClick(point, MouseButton.MOUSE_BUTTON_LEFT);
      expect(await readMouseZoneStatus(driver)).assertEqual('Left / Release');
    });

    it('mouseClick_right_isReported', 0, async () => {
      const point = await findMouseZoneCenter(driver);
      await driver.mouseClick(point, MouseButton.MOUSE_BUTTON_RIGHT);
      expect(await readMouseZoneStatus(driver)).assertEqual('Right / Release');
    });

    it('mouseDoubleClick_middle_isReported', 0, async () => {
      const point = await findMouseZoneCenter(driver);
      await driver.mouseDoubleClick(point, MouseButton.MOUSE_BUTTON_MIDDLE);
      expect(await readMouseZoneStatus(driver)).assertEqual('Middle / Release');
    });

    it('mouseLongClick_left_withCtrlModifier_isReported', 0, async () => {
      const point = await findMouseZoneCenter(driver);
      await driver.mouseLongClick(point, MouseButton.MOUSE_BUTTON_LEFT, KEYCODE_CTRL_LEFT);
      expect(await readMouseZoneStatus(driver)).assertEqual('Left / Release');
    });
  });
}
