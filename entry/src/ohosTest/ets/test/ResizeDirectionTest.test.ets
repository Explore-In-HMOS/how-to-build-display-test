import { BusinessError } from '@kit.BasicServicesKit';
import { Driver, ResizeDirection, UiWindow } from '@kit.TestKit';
import { describe, beforeEach, it, expect } from '@ohos/hypium';

/** UiTest error code for "This operation is not supported.", returned by
 * UiWindow.resize() on device types other than Phone(23+)/PC/2in1/Tablet. */
const RESIZE_UNSUPPORTED_ERROR_CODE = 17000005;

interface ResizeCase {
  direction: ResizeDirection;
  label: string;
}

const RESIZE_CASES: ResizeCase[] = [
  { direction: ResizeDirection.LEFT, label: 'LEFT' },
  { direction: ResizeDirection.RIGHT, label: 'RIGHT' },
  { direction: ResizeDirection.UP, label: 'UP' },
  { direction: ResizeDirection.DOWN, label: 'DOWN' },
  { direction: ResizeDirection.LEFT_UP, label: 'LEFT_UP' },
  { direction: ResizeDirection.LEFT_DOWN, label: 'LEFT_DOWN' },
  { direction: ResizeDirection.RIGHT_UP, label: 'RIGHT_UP' },
  { direction: ResizeDirection.RIGHT_DOWN, label: 'RIGHT_DOWN' }
];

/**
 * Exercises every ResizeDirection value against UiWindow.resize().
 * The UiTest reference documents resize() as returning error 17000005 on
 * device types other than Phone(23+)/PC/2in1/Tablet, so on this wearable
 * codelab the correct, passing outcome is that every attempt rejects with
 * that exact code - a call that resolves instead is the actual test failure.
 */
export default function resizeDirectionTest() {
  describe('ResizeDirectionTest', () => {
    let driver: Driver;

    beforeEach(() => {
      driver = Driver.create();
    });

    RESIZE_CASES.forEach((testCase: ResizeCase) => {
      it(`resize_${testCase.label}_rejectsOnWearable`, 0, async () => {
        const window: UiWindow = await driver.findWindow({ active: true });
        let rejectedWithExpectedCode = false;
        try {
          await window.resize(200, 200, testCase.direction);
        } catch (err) {
          const error = err as BusinessError;
          rejectedWithExpectedCode = error.code === RESIZE_UNSUPPORTED_ERROR_CODE;
        }
        expect(rejectedWithExpectedCode).assertTrue();
      });
    });
  });
}
