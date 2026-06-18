import 'package:flutter/material.dart';

import '../../domain/reference_data.dart';
import '../../theme/log_palette.dart';
import '../../theme/log_type.dart';
import '../../widgets/document_card.dart';

List<Widget> ratingDefsCards() {
  return ReferenceData.ratings.map((r) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DocumentCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 4,
              height: 44,
              margin: const EdgeInsets.only(top: 2, right: 12),
              decoration: BoxDecoration(
                color: LogPalette.gold,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(r.label, style: LogType.bodyStrong()),
                  const SizedBox(height: 4),
                  Text(r.summary, style: LogType.body()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }).toList();
}
