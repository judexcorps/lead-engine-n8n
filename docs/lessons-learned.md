# Lessons learned

Problems hit while building, the cause, and the fix.

| Problem | Cause | Fix |
|---|---|---|
| "Referenced node doesn't exist" | A Code node expression used a node name (e.g. `Insert lead`) that didn't match the real node name | Rename nodes so they match the expression exactly |
| Gemini HTTP timeouts | Unreliable network, and the direct Supabase connection is IPv6 only | Use the Session pooler; add timeouts and retries |
| 429 rate limit | The AI Agent looped many times per item | Max Iterations 3, one page-tool use, batch spacing, a known-sites filter, a cap on results. n8n's retry wait is capped at 5000 ms, so spacing is needed instead of longer retries |
| Structured Output Parser failing | A JSON example makes every field mandatory, so stores with no email failed | Use a JSON Schema where only `is_target`, `confidence` and `reason` are required |
| Page tool "Unexpected type of selector" | The model was allowed to fill the CSS selector field | Fix the selector to `body`; let the model set only the URL |
| Gmail credential expired | Google Cloud app in Testing mode (7-day token) | Reconnect, or publish the OAuth app |
| Workflow stopped with no error | A node output zero items, or the Timeout Workflow field had 15 in the seconds box | Check Executions; use the minutes box |
| Stuck executions | A dropped connection left requests waiting | Request timeouts and a workflow-level timeout |
| Test lead wrongly opted out | Outgoing messages contain "Reply STOP", so searching anywhere in a reply matched | Treat a message as STOP only if it *starts with* stop, unsubscribe, remove me or opt out |

## Techniques worth reusing

- **One database as the hub.** Workflows share tables instead of calling each other, so each can be tested and can fail alone.
- **Approval gate in a table cell.** `approved_by` empty means nothing sends. No extra app needed.
- **Rotating search slice.** Use the week number as an offset into the full list of city and query combinations so each weekly run takes the next slice, with no manual edits.
- **`INSERT ... SELECT ... WHERE NOT EXISTS ... ON CONFLICT DO NOTHING`.** Blocked (opted-out) and duplicate contacts silently produce no row.
- **Hash contacts** for duplicate and opt-out checks without keeping extra copies of personal data.
