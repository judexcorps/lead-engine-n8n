# Pre-commit safety checklist

Do every item before `git add`.

## Workflow JSON files
- [ ] Open each file and **delete the `pinData` block** (it can contain pinned real search results).
- [ ] Search each file for: `key`, `token`, `Bearer`, `@`, `AIza`, `tvly`. Remove or replace anything real. (n8n exports don't include credential secrets, but check anyway.)
- [ ] Check no real store names, phone numbers or emails remain in any node.

## SQL
- [ ] The seed contains no real email address.
- [ ] Message templates contain no private details or business name.

## Screenshots
- [ ] Hide store names, phone numbers, emails and any client work.
- [ ] Keep unchecked screenshots in `screenshots_raw/` (ignored by git). Move to `docs/screenshots/` only after redacting.

## General
- [ ] No `.env`, no lead data, no exports.
- [ ] The business and school are not named without permission.
- [ ] The README says "pilot, in progress". Nothing says "live" or "production".
- [ ] The Tavily key pasted into an earlier chat has been **rotated** in the Tavily dashboard.
- [ ] Run `git status` and read the full file list before committing.

## Wording
Use: pilot, in progress, test data, human approves every message, redacted before AI scoring (inbound form).
Avoid: live, production, fully automated outreach, "no personal data ever reaches the AI", client names, revenue or result claims, unmeasured accuracy percentages.

## Videos (before adding a YouTube link)
- [ ] No API keys, passwords, Supabase project URL or credential screens are visible at any point (pause and scrub through the video).
- [ ] No real store names, phone numbers, emails, or the client's business name appear on screen or in the voice-over.
- [ ] The title or description says "test data" and "pilot, in progress".
- [ ] No claims of results, revenue, or "live".
