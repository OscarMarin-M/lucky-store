-- Lucky Store v8: each document (purchase, sale, write-off) records the
-- email of the account that registered it, written by the phone at that
-- moment (works offline: the session stays on the phone).
--
-- Documents uploaded before v8 are filled from created_by, the account that
-- uploaded them. Rows registered before sign-in existed were uploaded by the
-- phone's owner on the first sync, so they show that account. The update
-- moves server_updated_at, so every phone downloads the names on its next
-- sync.
--
-- Run BEFORE installing the v8 app on any phone: SQL Editor -> New query ->
-- paste -> Run.

alter table public.purchases add column registered_by text;
alter table public.sales add column registered_by text;
alter table public.stock_adjustments add column registered_by text;

update public.purchases d set registered_by = u.email
  from auth.users u where u.id = d.created_by and d.registered_by is null;
update public.sales d set registered_by = u.email
  from auth.users u where u.id = d.created_by and d.registered_by is null;
update public.stock_adjustments d set registered_by = u.email
  from auth.users u where u.id = d.created_by and d.registered_by is null;
