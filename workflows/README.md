# Workflows

n8n JSON exports. Each file was cleaned before publishing. Cleaning removes private identifiers only; workflow logic is never edited.

## How to import
1. In n8n, open Workflows, then the menu next to Create, then Import from file.
2. Re-select credentials on each node that shows a warning (Postgres, Gemini header auth, Gemini chat model, Tavily header auth, Gmail).
3. Replace `you@example.com` with your own address in the Gmail nodes (01, 02, 04, 99).
4. Set **Error Workflow** to workflow 99 in each workflow's Settings. The exports do not include it.
5. Import and publish 99 first so the other workflows have an alert target.

## Changes made for publication
| File | Removed or replaced | Logic changes |
|---|---|---|
| 01-inbound-intake.json | Email address, instance, workflow and version IDs, webhook IDs, error-workflow link, empty `pinData` | None |
| 02-store-discovery.json | Same | None |
| 03-send-approved.json | Instance, workflow and version IDs, webhook IDs, empty `pinData` | None |
| 04-replies-and-opt-outs.json | Email address, instance, workflow and version IDs, webhook IDs, empty `pinData` | None |
| 98-keep-alive.json | Instance, workflow and version IDs, error-workflow link, empty `pinData` | None |
| 99-error-alerts.json | Email address, instance, workflow and version IDs, webhook ID, empty `pinData` | None |

## Notes on behaviour (as exported)
- 01 redacts emails and phone numbers from the message before scoring. The name field is not sent.
- 02 keeps a store when the research agent sets `is_target` to true. The confidence value is saved but not used as a filter. The fit threshold (60) is written into the workflow.
- 02 fit scoring sends business type, city, region and the agent's short reason.
- 03 sends only approved email messages. Follow-up rows are marked `sent` when the draft is written.
- 04 checks Gmail every minute and matches replies by the sender's email address.
