# Designer spec: Data & Privacy (0.4.0 trust slice)

## Section: Data & Privacy

**Order (primary rows stable on refresh; toggle row may appear/disappear when the account bucket first resolves):**

1. **Primary** — Heading: “This journal on this device”. Body from snapshot matrix (see `architecture.md`); fallback path must not promise cross-device sync.
2. **Secondary** — Heading: “iCloud sync preference”. Body: aligned vs divergent vs launch-fallback guidance; never hide this row.
3. **Account** — Heading: “iCloud account”. Body: async bucket copy; does not assert sync completion.
4. **Tertiary recovery** — At most two: `Open Settings` (when account is `noAccount` or `restricted`) and non-interactive “close and reopen” text when preference/store diverge or fallback occurred.
5. **Toggle** — iCloud sync `@AppStorage` toggle is **interactive only** when `ICloudAccountBucket` is not `noAccount` or `restricted`. While the account row is still “Checking…” (`displayedBucket == nil`), the toggle stays visible to avoid an empty first paint. When the toggle is hidden, footer and secondary copy use neutral **stored preference** wording (no reference to an on-screen switch); recovery text avoids implying the user can flip sync in-app until iCloud is available again.
6. **Export** — Unchanged behavior.

## Tone

Calm, explicit, non-alarmist; match `.impeccable.md` (warm, trustworthy). VoiceOver: combined accessibility elements per block with distinct labels for storage vs preference vs account.

## Strings

Implemented in `Localizable.xcstrings` (en + zh-Hans). Some longer sentences are split into adjacent keys and joined in code with a space so each catalog entry stays within lint line limits; translators should keep each fragment natural as a continuation. Follow-up: `stringsdict` if pluralized grammar is required for future variants.
