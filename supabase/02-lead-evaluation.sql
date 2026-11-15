-- Vidal Technologies: agente de avaliação de leads
-- Rode depois do 01-customers.sql. Mesmo padrão do Pulse Stock: nomes em inglês,
-- snake_case, tabelas no plural, enums para status e RLS ativado.
-- Cole tudo no Supabase > SQL Editor > New query e clique em Run.

-- ---------------------------------------------------------------------------
-- Tipos
-- ---------------------------------------------------------------------------

-- Etapas do funil de um contato
create type public.customer_status as enum ('lead', 'evaluated', 'in_conversation', 'proposal', 'customer', 'lost');
-- Canal por onde o contato chegou
create type public.customer_source as enum ('email', 'website', 'whatsapp', 'referral', 'other');
-- Prioridade sugerida pelo agente
create type public.lead_priority as enum ('high', 'medium', 'low');
-- Aderência do lead ao catálogo
create type public.service_fit as enum ('high', 'medium', 'low', 'out_of_scope');
-- Frentes do catálogo
create type public.service_category as enum ('sites', 'web_apps', 'automation_ai');

-- ---------------------------------------------------------------------------
-- customers também serve como tabela de leads
-- ---------------------------------------------------------------------------

alter table public.customers
  add column status public.customer_status not null default 'lead',
  add column source public.customer_source not null default 'email';
comment on column public.customers.status is 'Etapa do funil: lead, evaluated, in_conversation, proposal, customer, lost';
comment on column public.customers.source is 'Canal de origem do contato';
create index customers_status_idx on public.customers (status);

-- ---------------------------------------------------------------------------
-- Catálogo de serviços (lido pelo agente)
-- ---------------------------------------------------------------------------

create table public.services (
  id uuid primary key default gen_random_uuid(),
  -- código do catálogo, ex.: S1, A2, I3
  code text not null constraint services_code_key unique check (code ~ '^[A-Z][0-9]{1,2}$'),
  category public.service_category not null,
  name text not null check (char_length(btrim(name)) between 1 and 120),
  description text not null check (char_length(description) <= 500),
  ideal_for text check (char_length(ideal_for) <= 300),
  features text[] not null default '{}',
  sort_order integer not null default 0,
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
comment on table public.services is 'Catálogo de serviços da Vidal Technologies usado pelo agente de avaliação de leads';

create trigger services_set_updated_at
  before update on public.services
  for each row execute function public.set_updated_at();

alter table public.services enable row level security;

-- ---------------------------------------------------------------------------
-- Avaliações do agente (uma por mensagem avaliada, guarda o histórico)
-- ---------------------------------------------------------------------------

create table public.lead_evaluations (
  id uuid primary key default gen_random_uuid(),
  customer_id uuid not null references public.customers (id) on delete cascade,
  source public.customer_source not null default 'email',
  -- mensagem que foi avaliada
  message text not null check (char_length(message) <= 20000),
  -- 1. resumo do lead
  summary text not null check (char_length(summary) <= 2000),
  -- 2. necessidades e problemas
  needs text[] not null default '{}',
  -- 3. aderência às soluções
  fit public.service_fit not null,
  recommended_services text[] not null default '{}',
  fit_reason text check (char_length(fit_reason) <= 1000),
  -- 4. prioridade sugerida
  priority public.lead_priority not null,
  score integer not null check (score between 0 and 100),
  score_breakdown text check (char_length(score_breakdown) <= 500),
  priority_justification text check (char_length(priority_justification) <= 1000),
  -- 5, 6 e 7
  missing_info text[] not null default '{}',
  next_questions text[] not null default '{}',
  next_step text not null check (char_length(next_step) <= 1000),
  model text check (char_length(model) <= 60),
  raw_output jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
comment on table public.lead_evaluations is 'Relatórios do agente de IA: resumo, necessidades, aderência, prioridade, informações faltantes, perguntas e próximo passo';

create index lead_evaluations_customer_id_idx on public.lead_evaluations (customer_id);
create index lead_evaluations_score_idx on public.lead_evaluations (score desc);
create index lead_evaluations_created_at_idx on public.lead_evaluations (created_at desc);

create trigger lead_evaluations_set_updated_at
  before update on public.lead_evaluations
  for each row execute function public.set_updated_at();

-- RLS ativado sem políticas: bloqueia a API pública.
-- O n8n usa a chave secreta (service_role), que passa pelo RLS.
alter table public.lead_evaluations enable row level security;
