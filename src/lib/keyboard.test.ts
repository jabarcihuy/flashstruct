import { describe, expect, it } from 'vitest';
import { digitFromKeyboardEvent } from './keyboard';

describe('digitFromKeyboardEvent', () => {
  it.each([
    [{ key: '1', code: 'Digit1' }, 1],
    [{ key: '4', code: 'Numpad4' }, 4],
    [{ key: '!', code: 'Digit1' }, 1],
    [{ key: 'End', code: 'Numpad1' }, 1],
    [{ key: '', code: '', keyCode: 50, which: 50 }, 2],
    [{ key: '', code: '', keyCode: 100, which: 100 }, 4],
    [{ key: 'a', code: 'KeyA' }, null],
    [{ key: '0', code: 'Digit0' }, null],
  ])('maps %j to %s', (event, expected) => {
    expect(digitFromKeyboardEvent(event)).toBe(expected);
  });
});
