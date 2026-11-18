# Architecture

## Principle: one database as the hub
Workflows do not call each other. Each reads and writes Supabase tables. A change in one workflow cannot break another, and each can be tested alone.

## Tables (see `sql/` for exact columns)
| Table | Purpose |
|---|---|
| `businesses_config` | One settings row per business: active flag, target regions, search queries (with a `{city}` placeholder), excluded domains, max queries per run, model names, score threshold (60; the workflows currently hardcode 60 and the model name), follow-up days (1, 3, 7), message templates, notify email |
| `leads` | One row per person or business. `lead_type` is `inbound_individual` or `outbound_business`. Unique on `config_id` plus `contact_hash`. Status: new, contacted, replied, qualified, won, lost, unsubscribed, needs_manual_channel |
| `messages` | Drafted and sent messages: direction, channel, subject, body, `approved_by`, `sent_at` |
| `followups` | Step, `scheduled_at`, status (pending, sent, skipped, cancelled) |
| `opt_outs` | `contact_hash` primary key, checked before every send |
| `lead_events`, `runs`, `eval_cases`, `eval_runs` | Audit log, run log, and test-set tables (evaluation not built yet) |

## Workflow chains
**01 Inbound Intake:** form submission, Edit Fields (normalise contact, consent boolean), Crypto (SHA-256), Redact (Code: emails and phone numbers), Insert lead (on conflict do nothing), Score lead (Gemini), Parse AI (clamps score, falls back to 0), Save score, Log event, Hot Lead? (score at least 60), Gmail alert.

**02 Store Discovery:** Schedule, Load config, Build queries (week number as offset into the query list), Tavily search, Known sites, Filter results (excluded domains, known hosts, duplicates, cap 15), Research agent (Gemini, Structured Output Parser, page-reading tool), Parse target, Real Target? (is_target is true; the confidence value is saved but not used as a filter), Normalize contact, Has contact?, Crypto, Save store, Score fit (business type, city, region and the agent's short reason), Parse fit, Save fit, Good fit?, Load template, Fill pitch, Save draft. A second chain emails a weekly digest.

**03 Send Approved:** Find approved (approved_by set, not sent, email channel, not opted out, limit 20), Loop (batch 1), Gmail send, Mark sent (one query using CTEs), Wait 30 s. A second chain writes follow-up drafts that need the same approval. The follow-up row is marked `sent` when its draft is written, not when the email goes out.

**04 Replies and Opt-outs:** Gmail Trigger (checks every minute), Extract sender, Match lead, Is STOP?. STOP branch records the opt-out and cancels follow-ups. Reply branch logs the message, sets status replied, cancels follow-ups, notifies the owner. A message counts as STOP only if it starts with stop, unsubscribe, remove me or opt out.

**98 Keep-alive** and **99 Error alerts** support the rest.

## Two techniques
Rotating query slice: `start = (floor(now / 1 week) * n) % total` picks a different slice of city and query combinations each week.

Silent dedupe and opt-out in one statement: `INSERT ... SELECT ... WHERE NOT EXISTS (opt_outs) ON CONFLICT DO NOTHING` returns no row for a blocked or duplicate contact.
