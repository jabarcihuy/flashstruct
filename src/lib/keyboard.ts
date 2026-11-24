/** Read number-row and numpad shortcuts consistently across keyboard layouts. */
export function digitFromKeyboardEvent(
  event: Pick<KeyboardEvent, 'key' | 'code'> & Partial<Pick<KeyboardEvent, 'keyCode' | 'which'>>,
): number | null {
  // `code` identifies the physical key and is more reliable than `key`
  // with shifted/non-US keyboard layouts.
  const fromCode = event.code.match(/^(?:Digit|Numpad)([1-4])$/)?.[1];
  if (fromCode) return Number(fromCode);

  const fromKey = /^[1-9]$/.test(event.key) ? Number(event.key) : null;
  if (fromKey !== null) return fromKey;

  // Legacy key codes are still emitted by browsers and some remote/VM keyboards.
  const code = event.keyCode ?? event.which ?? 0;
  if (code >= 49 && code <= 52) return code - 48;
  if (code >= 97 && code <= 100) return code - 96;
  return null;
}
