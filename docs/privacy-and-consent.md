# Privacy and consent

| Step | What reaches the AI | Protection |
|---|---|---|
| Inbound form scoring | The message text | Emails and phone numbers replaced with `[EMAIL]` and `[PHONE]` first. The separate name field is not sent. A name typed inside the message text is not redacted |
| Store finder (research agent) | Public search results: title, URL, snippet | Public data only. A snippet can contain a shop's public phone number |
| Store fit scoring | Business type, city, region and a short reason written by the research agent | The reason is AI-written from the search snippet, so it could repeat a public contact detail |

- The inbound form has a required consent checkbox.
- Every message ends with "Reply STOP to opt out".
- `opt_outs` is checked before every send.
- The original message and contact are stored in your own Supabase database (needed to reply). Only the redacted message goes to the AI.
- Contacts are stored with a SHA-256 hash for dedupe and opt-out checks. The hash is for matching, not anonymity: plain SHA-256 of a phone number can be reversed by brute force. A keyed hash (HMAC) is planned.
- A human approves every message. The system never sends on its own.

This is a pilot built with test data. It has not been reviewed for legal compliance, so check local rules (for example Nigeria's data protection law) before any real use.
