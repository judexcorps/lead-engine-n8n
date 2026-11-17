# Design decisions

| Decision | Reason |
|---|---|
| Database as the hub | Workflows stay independent, testable, and fail on their own |
| Approval gate in a table cell (`approved_by`) | The AI cannot send; no extra app needed |
| WhatsApp is manual | Automated WhatsApp sending risks account bans and consent problems |
| Email is automated only after approval | Human stays in control of every outbound message |
| No Instagram, Facebook or Google Maps scraping | Platform rules and account risk. Public search results and public business sites only |
| Hash contacts (SHA-256) | Dedupe and opt-outs without keeping extra copies of personal data |
| Free tools only | Keeps the pilot cost at zero and reproducible |
| STOP matches only at the start of a reply | Outgoing messages contain "Reply STOP", so matching anywhere would opt out test leads |
| JSON Schema for the agent output | Only `is_target`, `confidence` and `reason` are required, so stores with no email still parse |
