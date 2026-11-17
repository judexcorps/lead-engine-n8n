# Privacy and consent

| Step | What reaches the AI | Protection |
|---|---|---|
| Inbound form scoring | The message text | Emails, phone numbers and the person's name replaced with `[EMAIL]`, `[PHONE]`, `[NAME]` first |
| Store finder (research agent) | Public search results: title, URL, snippet | Public data only. A snippet can contain a shop's public phone number |
| Store fit scoring | Business type, city, region | No contact details sent |

- The inbound form has a required consent checkbox.
- Every message ends with "Reply STOP to opt out".
- `opt_outs` is checked before every send.
- Contacts are stored with a SHA-256 hash for dedupe and opt-out checks.
- A human approves every message. The system never sends on its own.

This is a pilot built with test data. It has not been reviewed for legal compliance, so check local rules (for example Nigeria's data protection law) before any real use.
