-- Lucky Store v9: voiding a purchase, sale or write-off. A voided document
-- has deleted_at set (it already travels with the sync) and now also who
-- voided it (email) and the optional reason typed.
--
-- Run BEFORE installing the v9 app on any phone: SQL Editor -> New query ->
-- paste -> Run.

alter table public.purchases
  add column voided_by text,
  add column void_reason text;
alter table public.sales
  add column voided_by text,
  add column void_reason text;
alter table public.stock_adjustments
  add column voided_by text,
  add column void_reason text;
