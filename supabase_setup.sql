-- Run this entire script in Supabase Dashboard > SQL Editor > New query > Run.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  pack text not null,
  customer_name text not null,
  phone text not null,
  city text not null,
  business_name text not null,
  review_link text,
  status text not null default 'new' check (status in ('new','confirmed','shipped','completed','cancelled'))
);

alter table public.orders enable row level security;

-- Customers can submit orders, but cannot read, edit, or delete orders.
drop policy if exists "Anyone can submit orders" on public.orders;
create policy "Anyone can submit orders"
on public.orders for insert to anon, authenticated
with check (
  length(trim(customer_name)) > 0 and
  length(trim(phone)) > 0 and
  length(trim(city)) > 0 and
  length(trim(business_name)) > 0
);

-- Only signed-in users can view and manage orders. Keep admin account creation restricted.
drop policy if exists "Signed-in admins can view orders" on public.orders;
create policy "Signed-in admins can view orders"
on public.orders for select to authenticated using (auth.uid() is not null);

drop policy if exists "Signed-in admins can update orders" on public.orders;
create policy "Signed-in admins can update orders"
on public.orders for update to authenticated using (auth.uid() is not null) with check (auth.uid() is not null);
