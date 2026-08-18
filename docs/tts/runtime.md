# TTS Runtime Operation Reference v2.5

## Manual physical operations

All pieces, cards, states, ownership transfers, payments and legality remain human-controlled.

## Guided operations

The Global Lua provides sequencing and tutorial text for card setup, Initial Preparation, Season Opening, AGRHYMET/CILSS load, Intervention hand management, actor order, Season Closing and Final Resolution.

## Visibility controls

- FULL / COMPACT / HIDDEN
- SHOW GUIDE launcher while hidden
- TOP / BOTTOM
- HIGH / DIM
- TUTORIAL ON / OFF
- BACK / NEXT STEP
- RESET GUIDE with two-click confirmation

## Save-state behavior

The v0.4 schema ignores older tutorial state once and starts clean at CARD SETUP. Current v0.4 state persists through `onSave/onLoad`.

## Human validation rule

A Lua behavior reaches PASS only after it has been observed in TTS. Documentary inspection alone is recorded as STATIC PASS or WARN, never as live PASS.
