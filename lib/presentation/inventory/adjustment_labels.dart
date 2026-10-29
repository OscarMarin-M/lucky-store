import 'package:flutter/material.dart';

import '../../domain/entities/stock_adjustment.dart';

String reasonLabel(AdjustmentReason reason) => switch (reason) {
      AdjustmentReason.shrinkage => 'Merma',
      AdjustmentReason.expired => 'Vencido',
      AdjustmentReason.ownUse => 'Consumo propio',
      AdjustmentReason.other => 'Otros',
    };

IconData reasonIcon(AdjustmentReason reason) => switch (reason) {
      AdjustmentReason.shrinkage => Icons.broken_image_outlined,
      AdjustmentReason.expired => Icons.event_busy_outlined,
      AdjustmentReason.ownUse => Icons.person_outline,
      AdjustmentReason.other => Icons.more_horiz,
    };
