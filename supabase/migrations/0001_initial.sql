-- Lucky Store: shared database for the sync of every phone.
--
-- Mirrors the local Drift schema (v5) with these differences:
--  * products has no stock_units / avg_cost_raw: each phone derives them
--    from purchases, sales and write-offs in date order, so two people
--    selling at the same time never overwrite each other's stock.
--  * server_updated_at is set here by a trigger on every insert/update. The
--    phones pull "what changed since my last server_updated_at", so a phone
--    with a wrong clock cannot hide or repeat changes.
--  * created_by records which user registered the row.
--  * Nothing is ever DELETEd: deleted_at (logical delete) travels as an update.
--
-- Run once in Supabase: SQL Editor -> New query -> paste -> Run.

-- ---------------------------------------------------------------------------
-- Shared helpers
-- ---------------------------------------------------------------------------

create or replace function public.touch_server_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.server_updated_at := now();
  return new;
end;
$$;

-- Adds the trigger, the pull index and the access policy to one table.
create or replace procedure public.setup_synced_table(t text)
language plpgsql
as $$
begin
  execute format(
    'create trigger %1$s_touch before insert or update on public.%1$s
       for each row execute function public.touch_server_updated_at()', t);
  execute format(
    'create index %1$s_server_updated_at_idx on public.%1$s (server_updated_at)', t);
  -- First version: every signed-in member of the shop can read and write
  -- everything. Roles (e.g. a seller that does not see profits) come later.
  execute format('alter table public.%1$s enable row level security', t);
  execute format(
    'create policy %1$s_members on public.%1$s for all to authenticated
       using (true) with check (true)', t);
end;
$$;

-- ---------------------------------------------------------------------------
-- Tables (same names and columns as the phone; money in centavos, costs in
-- 1/10.000 Bs, inventory in base units)
-- ---------------------------------------------------------------------------

create table public.products (
  id uuid primary key,
  created_at timestamptz not null,
  updated_at timestamptz not null,
  deleted_at timestamptz,
  server_updated_at timestamptz not null default now(),
  created_by uuid default auth.uid() references auth.users (id),
  name text not null,
  sku text,
  units_per_box integer not null default 1 check (units_per_box >= 1),
  suggested_price_unit_cents integer not null default 0,
  suggested_price_box_cents integer,
  is_active boolean not null default true,
  min_stock_units integer
);

create table public.purchases (
  id uuid primary key,
  created_at timestamptz not null,
  updated_at timestamptz not null,
  deleted_at timestamptz,
  server_updated_at timestamptz not null default now(),
  created_by uuid default auth.uid() references auth.users (id),
  date timestamptz not null,
  supplier text,
  notes text,
  total_cents integer not null
);

create table public.purchase_lines (
  id uuid primary key,
  created_at timestamptz not null,
  updated_at timestamptz not null,
  deleted_at timestamptz,
  server_updated_at timestamptz not null default now(),
  created_by uuid default auth.uid() references auth.users (id),
  purchase_id uuid not null references public.purchases (id),
  product_id uuid not null references public.products (id),
  quantity integer not null,
  presentation text not null check (presentation in ('unit', 'box')),
  units_base integer not null,
  line_total_cents integer not null,
  unit_cost_raw integer not null,
  units_per_box integer,
  expiry_from timestamptz,
  expiry_to timestamptz,
  lot_code text
);

create table public.sales (
  id uuid primary key,
  created_at timestamptz not null,
  updated_at timestamptz not null,
  deleted_at timestamptz,
  server_updated_at timestamptz not null default now(),
  created_by uuid default auth.uid() references auth.users (id),
  date timestamptz not null,
  notes text,
  total_cents integer not null,
  profit_cents integer not null
);

create table public.sale_lines (
  id uuid primary key,
  created_at timestamptz not null,
  updated_at timestamptz not null,
  deleted_at timestamptz,
  server_updated_at timestamptz not null default now(),
  created_by uuid default auth.uid() references auth.users (id),
  sale_id uuid not null references public.sales (id),
  product_id uuid not null references public.products (id),
  quantity integer not null,
  presentation text not null check (presentation in ('unit', 'box')),
  units_base integer not null,
  unit_price_cents integer not null,
  suggested_unit_price_cents integer not null,
  line_total_cents integer not null,
  cost_at_sale_raw integer not null,
  cost_total_cents integer not null,
  profit_cents integer not null
);

-- Charges paid by the customer (assembly, packaging...); already included in
-- sales.total_cents and sales.profit_cents.
create table public.sale_extra_charges (
  id uuid primary key,
  created_at timestamptz not null,
  updated_at timestamptz not null,
  deleted_at timestamptz,
  server_updated_at timestamptz not null default now(),
  created_by uuid default auth.uid() references auth.users (id),
  sale_id uuid not null references public.sales (id),
  concept text not null,
  amount_cents integer not null
);

create table public.stock_adjustments (
  id uuid primary key,
  created_at timestamptz not null,
  updated_at timestamptz not null,
  deleted_at timestamptz,
  server_updated_at timestamptz not null default now(),
  created_by uuid default auth.uid() references auth.users (id),
  product_id uuid not null references public.products (id),
  date timestamptz not null,
  quantity integer not null,
  presentation text not null check (presentation in ('unit', 'box')),
  units_base integer not null,
  reason text not null,
  notes text,
  unit_cost_raw integer not null,
  cost_total_cents integer not null
);

create index purchase_lines_purchase_idx on public.purchase_lines (purchase_id);
create index purchase_lines_product_idx on public.purchase_lines (product_id);
create index sale_lines_sale_idx on public.sale_lines (sale_id);
create index sale_lines_product_idx on public.sale_lines (product_id);
create index sale_extra_charges_sale_idx on public.sale_extra_charges (sale_id);
create index stock_adjustments_product_idx on public.stock_adjustments (product_id);

call public.setup_synced_table('products');
call public.setup_synced_table('purchases');
call public.setup_synced_table('purchase_lines');
call public.setup_synced_table('sales');
call public.setup_synced_table('sale_lines');
call public.setup_synced_table('sale_extra_charges');
call public.setup_synced_table('stock_adjustments');
