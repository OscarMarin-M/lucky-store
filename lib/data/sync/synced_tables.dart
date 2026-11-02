/// Tables shared through the cloud, parents before children: pushing and
/// pulling in this order keeps every foreign key satisfied.
const syncedTableNames = [
  'products',
  'purchases',
  'purchase_lines',
  'sales',
  'sale_lines',
  'sale_extra_charges',
  'stock_adjustments',
];

/// Columns that exist only on the phone. Stock and average cost are derived
/// from the documents of every phone (see `InventoryRebuilder`), so they are
/// never uploaded nor overwritten by a download.
const localOnlyColumns = {
  'products': {'stock_units', 'avg_cost_raw'},
};
