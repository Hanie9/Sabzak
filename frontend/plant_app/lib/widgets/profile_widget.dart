import 'package:flutter/material.dart';

class BuildOptions extends StatelessWidget {
  final IconData icon;
  final String title;
  const BuildOptions({
    super.key, required this.icon, required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Icon(
            Icons.arrow_back_ios,
            size: 16.0,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Yekan Bakh',
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                width: 5.0,
              ),
              Icon(
                icon,
                size: 23.0,
              ),
            ],
          ),
        ],
      ),
    );
  }
}