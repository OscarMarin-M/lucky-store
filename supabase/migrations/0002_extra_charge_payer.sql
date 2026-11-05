-- Lucky Store v7: each extra amount of an order says who pays it.
--  * true  (every existing row): the customer pays it on top of the
--    products; included in sales.total_cents and sales.profit_cents.
--  * false: the shop pays it; not in total_cents, subtracted from
--    profit_cents.
--
-- Run BEFORE installing the v7 app on any phone (the app uploads and
-- downloads this column): SQL Editor -> New query -> paste -> Run.

alter table public.sale_extra_charges
  add column paid_by_customer boolean not null default true;
