import 'package:flutter/material.dart';
import 'package:submarine/repository.dart';

class ListAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ListAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      actions: [
        Expanded(
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset("./assets/logo_512_circle.png"),
              ),
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: Repository.to.search,
                ),
              ),
              // IconButton(
              //   onPressed: () async {
                  
              //   },
              //   icon: const Icon(Icons.more_vert),
              // ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
