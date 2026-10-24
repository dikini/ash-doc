import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import { test } from 'node:test';
import { verifySequence } from './sequence-cycle.mjs';

const state = JSON.parse(await readFile(new URL('sequence-trial.json', import.meta.url)));

test('construction retains the three participants and four ordered messages', () => {
  const result = verifySequence(state.construction.source);
  assert.deepEqual(result.participants, ['Caller', 'Service', 'Store']);
  assert.deepEqual(result.messages, [
    'Caller->>Service: Get item', 'Service->>Store: Read item',
    'Store-->>Service: Item', 'Service-->>Caller: Item'
  ]);
});

test('missing steps, reordered replies, or changed arrow kinds fail the brief check', () => {
  const source = state.construction.source;
  for (const changed of [source.replace('    participant Store\n', ''),
    source.replace('Service-->>Caller: Item', 'Service->>Caller: Item'),
    source.replace('Store-->>Service: Item\n    Service-->>Caller: Item',
      'Service-->>Caller: Item\n    Store-->>Service: Item')]) {
    assert.throws(() => verifySequence(changed));
  }
});
