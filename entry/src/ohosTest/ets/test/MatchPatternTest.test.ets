import { Component, Driver, MatchPattern, ON } from '@kit.TestKit';
import { describe, beforeEach, it, expect } from '@ohos/hypium';

/**
 * Exercises every MatchPattern value against MatchTargetRail's deliberately
 * overlapping labels - 'Submit', 'Submit Form', 'submit-2', 'RESUBMIT'.
 * Each query below is chosen so exactly one pattern/target pair resolves,
 * except the REG_EXP / REG_EXP_ICASE pair, which reuses the same query to
 * show case-sensitivity is the only difference between them.
 */
export default function matchPatternTest() {
  describe('MatchPatternTest', () => {
    let driver: Driver;

    beforeEach(() => {
      driver = Driver.create();
    });

    it('matchPattern_equals_resolvesExactLabel', 0, async () => {
      const component: Component | null =
        await driver.findComponent(ON.text('Submit', MatchPattern.EQUALS));
      expect(component === null).assertFalse();
      expect(await (component as Component).getText()).assertEqual('Submit');
    });

    it('matchPattern_contains_resolvesSubstringLabel', 0, async () => {
      const component: Component | null =
        await driver.findComponent(ON.text('Form', MatchPattern.CONTAINS));
      expect(component === null).assertFalse();
      expect(await (component as Component).getText()).assertEqual('Submit Form');
    });

    it('matchPattern_startsWith_resolvesPrefixedLabel', 0, async () => {
      // Lowercase 'sub' only prefixes 'submit-2' - 'Submit'/'Submit Form'
      // start with an uppercase 'S', and matching is case-sensitive.
      const component: Component | null =
        await driver.findComponent(ON.text('sub', MatchPattern.STARTS_WITH));
      expect(component === null).assertFalse();
      expect(await (component as Component).getText()).assertEqual('submit-2');
    });

    it('matchPattern_endsWith_resolvesSuffixedLabel', 0, async () => {
      // Uppercase 'MIT' only suffixes 'RESUBMIT'.
      const component: Component | null =
        await driver.findComponent(ON.text('MIT', MatchPattern.ENDS_WITH));
      expect(component === null).assertFalse();
      expect(await (component as Component).getText()).assertEqual('RESUBMIT');
    });

    it('matchPattern_regExp_isCaseSensitive', 0, async () => {
      const exactCase: Component | null =
        await driver.findComponent(ON.text('^Submit$', MatchPattern.REG_EXP));
      expect(exactCase === null).assertFalse();
      expect(await (exactCase as Component).getText()).assertEqual('Submit');

      // Same shape of pattern, wrong case for RESUBMIT: REG_EXP must not match.
      const wrongCase: Component | null =
        await driver.findComponent(ON.text('^resubmit$', MatchPattern.REG_EXP));
      expect(wrongCase === null).assertTrue();
    });

    it('matchPattern_regExpIcase_ignoresCase', 0, async () => {
      const component: Component | null =
        await driver.findComponent(ON.text('^resubmit$', MatchPattern.REG_EXP_ICASE));
      expect(component === null).assertFalse();
      expect(await (component as Component).getText()).assertEqual('RESUBMIT');
    });
  });
}
