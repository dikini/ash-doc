import assert from 'node:assert/strict';
import test from 'node:test';
import { foldlStates } from './foldl-state.mjs';

test('each recursive step preserves the accumulator as the left argument', () => {
  const states = foldlStates(['1', '2', '3']);
  assert.deepEqual(states.map(state => state.remaining), [['1', '2', '3'], ['2', '3'], ['3'], []]);
  assert.equal(states[0].accumulator, 'z');
  for (let index = 1; index < states.length; index += 1) {
    assert.deepEqual(states[index].accumulator,
      { function: 'f', left: states[index - 1].accumulator, right: String(index) });
  }
  assert.equal(states.at(-1).expression, 'f (f (f z 1) 2) 3');
});

test('empty input returns the seed without inventing an application', () => {
  assert.deepEqual(foldlStates([]), [{ accumulator: 'z', remaining: [], expression: 'z' }]);
  assert.throws(() => foldlStates(['1', '1']), /distinct/);
});
