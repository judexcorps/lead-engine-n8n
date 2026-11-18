-- AI Lead Engine: Supabase (Postgres) schema (inbound + outbound)
-- Run in Supabase > SQL Editor. Safe to run on a fresh project.
-- Columns marked [workflows] are the ones the exported n8n workflows read or write.
-- They were inferred from the workflow queries: check them against your own database before relying on this file.

create extension if not exists pgcrypto;

-- One row per business the engine runs for (sneakers pilot, your automation agency)
create table businesses_config (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  target_regions text[] not null default '{}',
  keywords text[] not null default '{}',
  search_queries text[] not null default '{}',     -- [workflows] with a {city} placeholder
  excluded_domains text[] not null default '{}',   -- [workflows] social media and other sites to skip
  max_queries_per_run int not null default 4,      -- [workflows]
  scoring_rules jsonb not null default '{}',
  outbound_template text,                 -- wholesale pitch to stores/resellers
  inbound_template text,                  -- reply to individuals who opted in
  shipping_note text,
  score_threshold int not null default 60,
  model text,
  fallback_model text,
  followup_days int[] not null default '{1,3,7}',
  notify_email text,
  active boolean not null default true,
  created_at timestamptz not null default now()
);

create table leads (
  id uuid primary key default gen_random_uuid(),
  config_id uuid not null references businesses_config(id),
  lead_type text not null
    check (lead_type in ('outbound_business','inbound_individual')),
  created_at timestamptz not null default now(),
  source text not null,                   -- 'form','telegram','whatsapp_group_form','manual_list'
  external_id text,
  name text,                              -- person name
  business_name text,                     -- outbound: store / boutique / reseller
  business_type text,                     -- 'store','boutique','reseller','online_seller'
  region text,
  city text,
  source_url text,                        -- [workflows] page the store was found on
  email text,                             -- [workflows]
  phone text,                             -- [workflows] +234 format
  website text,                           -- [workflows]
  instagram text,                         -- [workflows]
  whatsapp_link text,                     -- [workflows] wa.me link
  enrichment_confidence int,              -- [workflows] agent confidence, saved but not used as a filter
  contact text not null,                  -- email or phone
  contact_hash text not null,             -- hash of normalized contact, for dedupe
  message text,
  intent text,
  budget_range text,
  urgency text,
  score int check (score between 0 and 100),
  score_reason text,
  status text not null default 'new'
    check (status in ('new','contacted','replied','qualified','won','lost','unsubscribed','needs_manual_channel')),
  consent_marketing boolean not null default false,   -- required for inbound
  consent_at timestamptz,
  opted_out boolean not null default false,
  next_followup_at timestamptz,
  last_contact_at timestamptz,
  notes text,
  unique (config_id, contact_hash)
);
create index leads_status_idx on leads (status);
create index leads_type_region_idx on leads (lead_type, region);
create index leads_followup_idx on leads (next_followup_at) where opted_out = false;

create table lead_events (
  id bigserial primary key,
  lead_id uuid references leads(id) on delete cascade,
  created_at timestamptz not null default now(),
  event_type text not null,
  detail jsonb
);

create table messages (
  id uuid primary key default gen_random_uuid(),
  lead_id uuid references leads(id) on delete cascade,
  created_at timestamptz not null default now(),
  direction text check (direction in ('in','out')),
  channel text,
  subject text,
  body text,
  approved_by text,
  sent_at timestamptz
);

create table followups (
  id uuid primary key default gen_random_uuid(),
  lead_id uuid references leads(id) on delete cascade,
  step int not null,
  scheduled_at timestamptz not null,
  sent_at timestamptz,
  status text not null default 'pending'
    check (status in ('pending','sent','skipped','cancelled'))
);

-- Suppression list: checked before every send, even for contacts not yet in leads
create table opt_outs (
  contact_hash text primary key,
  reason text,
  created_at timestamptz not null default now()
);

create table runs (
  id uuid primary key default gen_random_uuid(),
  config_id uuid references businesses_config(id),
  workflow text,
  leads_in int default 0,
  leads_new int default 0,
  errors int default 0,
  error_detail text,
  started_at timestamptz not null default now(),
  finished_at timestamptz
);

create table eval_cases (
  id serial primary key,
  input_text text not null,
  expected_intent text not null,
  expected_score_min int not null,
  expected_score_max int not null
);

create table eval_runs (
  id serial primary key,
  created_at timestamptz not null default now(),
  model text,
  prompt_version text,
  accuracy numeric,
  details jsonb
);

-- Lock the public API; n8n connects with the database credentials
alter table businesses_config enable row level security;
alter table leads enable row level security;
alter table lead_events enable row level security;
alter table messages enable row level security;
alter table followups enable row level security;
alter table opt_outs enable row level security;
alter table runs enable row level security;
alter table eval_cases enable row level security;
alter table eval_runs enable row level security;

-- Seed: example row (placeholder values only. Edit the templates, queries and email before use)
insert into businesses_config
  (name, target_regions, keywords, outbound_template, inbound_template,
   shipping_note, model, fallback_model, notify_email,
   search_queries, excluded_domains, max_queries_per_run)
values
  ('sneakers',
   '{Lagos,"Benin City",Abuja}',
   '{sneakers,footwear,kicks}',
   'Hi {{business_name}}, we supply sneakers wholesale and ship from Lagos to {{city}}. {{shipping_note}} Reply STOP to opt out.',
   'Hi {{name}}, thanks for getting in touch. {{shipping_note}} Reply STOP to opt out.',
   'We ship nationwide from our Lagos warehouse.',
   'SET_IN_ONE_PLACE', 'SET_FALLBACK', 'you@example.com',
   '{"sneaker store {city}","footwear shop {city}","sneaker boutique {city}","sneaker reseller {city}"}',
   '{instagram.com,facebook.com,tiktok.com,x.com,twitter.com,youtube.com}',
   4);
