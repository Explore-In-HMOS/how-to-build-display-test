import abilityTest from './Ability.test';
import resizeDirectionTest from './ResizeDirectionTest.test';
import mouseButtonTest from './MouseButtonTest.test';
import matchPatternTest from './MatchPatternTest.test';
import displayRotationTest from './DisplayRotationTest.test';

export default function testsuite() {
  abilityTest();
  resizeDirectionTest();
  mouseButtonTest();
  matchPatternTest();
  displayRotationTest();
}
