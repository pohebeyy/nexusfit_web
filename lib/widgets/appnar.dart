import 'package:flutter/material.dart';
import 'package:startap/screens/profile/profile.dart';


class Appnar {
  static Widget buildModernAppBar(BuildContext context, String text) {
    return SliverAppBar(
      expandedHeight: 70,
      floating: false,
      pinned: true,
      stretch: true,
      backgroundColor: const Color(0xFF1C1C1E), // Изменён цвет
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.fadeTitle,
        ],
        
        title: Row(
          children: [

            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                shadows: [
                  Shadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),
          ],
        ),
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 8, top: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.15),
              width: 1,
            ),
          ),
          child: IconButton(
            icon: Stack(
              children: [
                const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 24,
                ),
                
              ],
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileScreen()),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
      ],
    );
  }
}
