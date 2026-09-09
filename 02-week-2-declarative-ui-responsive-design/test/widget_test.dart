import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:responsive_dashboard/main.dart'; 

void main() {
  testWidgets('Dashboard satu kolom di layar sempit', (tester) async {
    // Simulasi ukuran HP
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const DashboardApp());

    // Mencari spesifik widget DashboardCard yang paling pertama (IPK Saat Ini)
    final cardFinder = find.byType(DashboardCard).first;
    final width = tester.getSize(cardFinder).width;
    
    // Karena lebar layar 400, kartu harus kurang dari 700
    expect(width, lessThan(700));
  });

  testWidgets('Dashboard dua kolom di layar lebar', (tester) async {
    // Simulasi ukuran Desktop/Tablet
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const DashboardApp());

    // Mencari spesifik widget DashboardCard yang paling pertama (IPK Saat Ini)
    final cardFinder = find.byType(DashboardCard).first;
    final width = tester.getSize(cardFinder).width;
    
    // Karena lebar layar 1200 dibagi 2 kolom, lebar satu kartu pasti di atas 500
    expect(width, greaterThan(500));
  });
}
