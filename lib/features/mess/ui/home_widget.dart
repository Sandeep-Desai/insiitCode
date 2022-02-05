import 'package:flutter/material.dart';
import 'package:insiit/features/mess/classes/item.dart';
import 'package:insiit/global/data/constants.dart';

Widget itemCard(MessItem item) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 0, 16),
    child: Container(
        width: 200,
        decoration: BoxDecoration(
            color: Colors.grey.withAlpha(10),
            borderRadius: const BorderRadius.all(
              Radius.circular(20),
            )),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  child: Image.network(
                    item.imageUrl,
                    fit: BoxFit.fitWidth,
                  ),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    height: 32,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.star_rounded,
                            color: Colors.amber,
                          ),
                          Text(
                            item.vote.toString(),
                          ),
                        ],
                      ),
                    ),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(
                          Radius.circular(20),
                        )),
                  ),
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    height: 32,
                    child: (item.glutenFree) //TODO replace with asset
                        ? Image.network(
                            "https://cdn1.iconfinder.com/data/icons/eco-food-and-cosmetic-labels/128/Artboard_15-512.png",
                            height: ScreenSize.size.height * 0.05,
                          )
                        : Container(),
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(
                          Radius.circular(20),
                        )),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 120,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.name,
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(
                          height: 6,
                        ),
                        // TODO doesnt look good, change it
                        Text(
                          "kcal: " + item.calories,
                        )
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      (item.vote == 1) ? Icons.favorite : Icons.favorite_border,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      item.vote = 1;
                    },
                  )
                ],
              ),
            ),
          ],
        )),
  );
}

Widget scrollableMessMenu() {
  return Container(
      height: 280,
      // color: Colors.grey,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: dataContainer.mess.currentMeal.length,
        itemBuilder: (context, index) {
          return Padding(
              padding: const EdgeInsets.all(8.0),
              child: itemCard(dataContainer.mess.currentMeal[index]));
        },
      ));
}
