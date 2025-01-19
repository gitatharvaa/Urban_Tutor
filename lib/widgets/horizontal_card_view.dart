import 'package:flutter/material.dart';
import '../screens/notes_page.dart';

class HorizontalCardView extends StatelessWidget {
  const HorizontalCardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        height: 140,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 10, // 1 to 10 standards
          itemBuilder: (context, index) {
            final grade = (index + 1).toString();

            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NotesPage(grade: grade),
                  ),
                );
              },
              splashColor: Theme.of(context).primaryColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: 120,
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [
                      Colors.primaries[index % Colors.primaries.length]
                          .withOpacity(0.55),
                      Colors.primaries[index % Colors.primaries.length]
                          .withOpacity(0.9),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      offset: const Offset(2, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'Std $grade',
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
