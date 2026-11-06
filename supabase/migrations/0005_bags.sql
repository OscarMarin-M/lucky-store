-- Lucky Store v10: products can also come in bags.
--  * products: default units per bag (null = no bags) and suggested price
--    of a whole bag.
--  * purchase / sale / write-off lines accept presentation 'bag'. A bag lot
--    keeps its size in purchase_lines.units_per_box (the pack size column).
--
-- Run BEFORE installing the v10 app on any phone: SQL Editor -> New query ->
-- paste -> Run. Then update EVERY phone before anyone registers a bag: an
-- older app cannot read a 'bag' line.

alter table public.products
  add column units_per_bag integer check (units_per_bag >= 1),
  add column suggested_price_bag_cents integer;

-- The inline checks of 0001 got Postgres' default names.
alter table public.purchase_lines
  drop constraint purchase_lines_presentation_check,
  add constraint purchase_lines_presentation_check
    check (presentation in ('unit', 'box', 'bag'));
alter table public.sale_lines
  drop constraint sale_lines_presentation_check,
  add constraint sale_lines_presentation_check
    check (presentation in ('unit', 'box', 'bag'));
alter table public.stock_adjustments
  drop constraint stock_adjustments_presentation_check,
  add constraint stock_adjustments_presentation_check
    check (presentation in ('unit', 'box', 'bag'));
