import 'package:flutter/material.dart';

class BudgetDisplay extends StatelessWidget {
  final double remainingAmount;
  final double startingAmount;
  final double spentAmount;
  final Function() startBetragEingeben;
  final Function(BuildContext) showDeleteConfirmationDialog;

  const BudgetDisplay({
    super.key,
    required this.remainingAmount,
    required this.startingAmount,
    required this.spentAmount,
    required this.startBetragEingeben,
    required this.showDeleteConfirmationDialog,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 355,
          height: 200,
          decoration: const BoxDecoration(
            color: Color(0xff194975),
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Kontostand:",
                      style: TextStyle(color: Color(0xffD1E4FF), fontSize: 14),
                    ),
                    // Übergeben Sie die Funktionen als Argumente an die Methode
                    _buildPopupMenu(
                      context, // Kontext muss auch übergeben werden
                      startBetragEingeben,
                      showDeleteConfirmationDialog,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${remainingAmount.toStringAsFixed(2)} €',
                style: const TextStyle(
                  color: Color(0xffD1E4FF),
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildBudgetInfo(
                    title: 'Budget:',
                    amount: startingAmount,
                    borderColor: const Color(0xffD1E4FF),
                  ),
                  _buildBudgetInfo(
                    title: 'Ausgaben:',
                    amount: spentAmount,
                    borderColor: const Color(0xffD1E4FF),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Die Methode nimmt nun die benötigten Funktionen als Parameter entgegen
  Widget _buildPopupMenu(
    BuildContext context,
    Function() startBetragEingebenCallback,
    Function(BuildContext) showDeleteConfirmationDialogCallback,
  ) {
    const Color textColor = Color(0xffe1e2e8);
    const Color backgroundColor = Color(0xff272a2f);
    return Theme(
      data: Theme.of(
        context,
      ).copyWith(popupMenuTheme: PopupMenuThemeData(color: backgroundColor)),
      child: PopupMenuButton<String>(
        icon: const Icon(
          Icons.more_vert,
          color: Color(0xffD1E4FF),
        ), // Icon des Buttons
        onSelected: (value) {
          if (value == 'add') {
            startBetragEingebenCallback(); // Zugriff über den Parameter
          } else if (value == 'delete') {
            showDeleteConfirmationDialogCallback(
              context,
            ); // Zugriff über den Parameter
          }
        },
        itemBuilder:
            (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'add',
                child: Row(
                  children: const [
                    Icon(Icons.add, color: textColor),
                    SizedBox(width: 8),
                    Text('Geld hinzufügen', style: TextStyle(color: textColor)),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: const [
                    Icon(Icons.delete, color: textColor),
                    SizedBox(width: 8),
                    Text('Alles löschen', style: TextStyle(color: textColor)),
                  ],
                ),
              ),
            ],
      ),
    );
  }

  Widget _buildBudgetInfo({
    required String title,
    required double amount,
    required Color borderColor,
  }) {
    return Container(
      width: 150,
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xff194975),
        border: Border.all(color: borderColor),
        borderRadius: const BorderRadius.all(Radius.circular(20)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(9, 4, 0, 4),
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xffD1E4FF),
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          Center(
            child: Text(
              '${amount.toStringAsFixed(2)} €',
              style: const TextStyle(color: Color(0xffD1E4FF), fontSize: 24),
            ),
          ),
        ],
      ),
    );
  }
}
