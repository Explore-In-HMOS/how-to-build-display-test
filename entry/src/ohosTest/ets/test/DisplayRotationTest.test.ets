import { Driver, DisplayRotation } from '@kit.TestKit';
import { describe, beforeAll, afterAll, beforeEach, it, expect } from '@ohos/hypium';

interface RotationCase {
  rotation: DisplayRotation;
  label: string;
}

const ROTATIONS_TO_ATTEMPT: RotationCase[] = [
  { rotation: DisplayRotation.ROTATION_90, label: 'ROTATION_90' },
  { rotation: DisplayRotation.ROTATION_180, label: 'ROTATION_180' },
  { rotation: DisplayRotation.ROTATION_270, label: 'ROTATION_270' },
  { rotation: DisplayRotation.ROTATION_0, label: 'ROTATION_0' }
];

/**
 * Exercises setDisplayRotation()/getDisplayRotation()/setDisplayRotationEnabled()
 * across every DisplayRotation value. The UiTest reference documents
 * these as having no effect on device types other than Phone/Tablet/PC/2in1/TV,
 * so on this wearable codelab the correct, passing outcome is that
 * getDisplayRotation() keeps reporting the suite's own baseline reading no
 * matter which rotation was just requested - not that the requested value
 * was applied.
 */
export default function displayRotationTest() {
  describe('DisplayRotationTest', () => {
    let driver: Driver;
    let baseline: DisplayRotation;

    beforeAll(async () => {
      driver = Driver.create();
      baseline = await driver.getDisplayRotation();
    });

    beforeEach(() => {
      driver = Driver.create();
    });

    afterAll(async () => {
      await driver.setDisplayRotationEnabled(true);
    });

    it('setDisplayRotationEnabled_false_hasNoEffectOnWearable', 0, async () => {
      await driver.setDisplayRotationEnabled(false);
      expect(await driver.getDisplayRotation()).assertEqual(baseline);
    });

    ROTATIONS_TO_ATTEMPT.forEach((testCase: RotationCase) => {
      it(`setDisplayRotation_${testCase.label}_hasNoEffectOnWearable`, 0, async () => {
        await driver.setDisplayRotation(testCase.rotation);
        expect(await driver.getDisplayRotation()).assertEqual(baseline);
      });
    });
  });
}
