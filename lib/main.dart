import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

/* ================= APP ================= */

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

/* ================= HOME ================= */

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bodySlide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _bodySlide = Tween<double>(begin: 160, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.6, // 👈 body starts AFTER categories
          1.0,
          curve: Curves.easeOutQuart,
        ),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final headerHeight = w * 0.85+10;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
      body: Stack(
        children: [
          // MAIN SCROLLING CONTENT
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 160),
              child: Column(
                children: [
                  SizedBox(
                    height: headerHeight,
                    child: _HeaderWithCategories(controller: _controller),
                  ),
                  AnimatedBuilder(
                    animation: _bodySlide,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _bodySlide.value),
                        child: Opacity(
                          opacity: _controller.value,
                          child: child,
                        ),
                      );
                    },
                    child: const _BodySection(),
                  ),
                ],
              ),
            ),
          ),

          // 🔥 FLOATING BLURRED FOOTER (like Figma)
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _BottomFooter(),
          ),
        ],
      ),
    );

  }
}

/* ================= HEADER + CATEGORIES ================= */

class _HeaderWithCategories extends StatefulWidget {
  final AnimationController controller;
  _HeaderWithCategories({required this.controller});
  int pageIndex = 1; // 0 = first 4, 1 = next 4


  @override
  State<_HeaderWithCategories> createState() =>
      _HeaderWithCategoriesState();
}

class _HeaderWithCategoriesState extends State<_HeaderWithCategories> {
  double rotation = 0.0;
  int pageIndex = 1;


  final categories = [
    _CategoryData("Grocery", "assets/categories/grocery.png"),
    _CategoryData("Electronic", "assets/categories/electronic.png"),
    _CategoryData("Beauty", "assets/categories/beauty.png"),
    _CategoryData("Fashion", "assets/categories/fashion.png"),
    _CategoryData("Home", "assets/categories/home.png"),
    _CategoryData("Stationery", "assets/categories/stationery.png"),
    _CategoryData("Tools", "assets/categories/tools.png"),
    _CategoryData("Health", "assets/categories/health.png"),
  ];

  final finalAngles = [
    pi / 2 + 0.55,
    pi / 2 + 0.18,
    pi / 2 - 0.18,
    pi / 2 - 0.55,
  ];

  void _onSwipe(DragEndDetails details) {
    if (details.primaryVelocity == null) return;

    setState(() {
      if (details.primaryVelocity! < 0 && pageIndex < 1) {
        // swipe left → next 4
        pageIndex++;
      } else if (details.primaryVelocity! > 0 && pageIndex > 0) {
        // swipe right → previous 4
        pageIndex--;
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final circleSize = w * 1.6;
    final centerX = w / 2;
    final centerY = -circleSize * 0.05;
    final radius = circleSize / 2.2;

    return GestureDetector(
      onHorizontalDragEnd: _onSwipe,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 🔵 BLUE BACKGROUND CIRCLE
          Positioned(
            top: -circleSize * 0.55,
            left: (w - circleSize) / 2,
            child: Container(
              width: circleSize,
              height: circleSize,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF184A99),
              ),
            ),
          ),

          // 🧭 HEADER CONTENT (TEXT + ICONS + SEARCH) — RESTORED
          Padding(
            padding: EdgeInsets.fromLTRB(w * 0.04, w * 0.06, w * 0.04, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("👋 Hii Vikram",
                            style: TextStyle(color: Colors.white70)),
                        SizedBox(height: 4),
                        Text(
                          "Let’s Shop",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: const [
                        _HeaderIcon("assets/icons/favorite.png"),
                        SizedBox(width: 12),
                        _HeaderIcon("assets/icons/profile.png"),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: w * 0.05),
                Container(
                  height: w * 0.12,
                  padding: EdgeInsets.symmetric(horizontal: w * 0.03),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.search, color: Colors.grey),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text("Search any Product..",
                            style: TextStyle(color: Colors.grey)),
                      ),
                      Icon(Icons.mic, color: Colors.grey),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 🔄 ROTATING CATEGORIES ON CURVE
          AnimatedBuilder(
            animation: widget.controller,
            builder: (_, __) {
              final t =
              Curves.easeOutQuart.transform(widget.controller.value);

              final visibleCategories =
              categories.skip(pageIndex * 4).take(4).toList();

              return Stack(
                children: List.generate(visibleCategories.length, (i) {
                  final angle =
                      (-pi / 2) + (finalAngles[i] + pi / 2) * t;

                  final x = centerX + radius * cos(angle);
                  final y = centerY + radius * sin(angle);

                  return Positioned(
                    left: x - 28,
                    top: y,
                    child: _CategoryItem(
                      image: visibleCategories[i].image,
                      label: visibleCategories[i].label,
                    ),
                  );
                }),
              );
            },
          ),
        ],
      ),
    );
  }
}


/* ================= BODY ================= */

class _BodySection extends StatelessWidget {
  const _BodySection();

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final cardW = (w - (w * 0.12)) / 2;
    final cardH = cardW * 1.05;

    final products = [
      {"title": "Black Winter", "image": "assets/trending/black_winter.png"},
      {"title": "Pink Embroide", "image": "assets/trending/pink_embroide.png"},
      {"title": "men’s & boys shoes", "image": "assets/trending/mens_shoes.png"},
      {"title": "Muscle Blaze", "image": "assets/trending/muscle_blaze.png"},
      {"title": "HRX Shoes", "image": "assets/trending/hrx_shoes.png"},
      {"title": "Titan Men Watch", "image": "assets/trending/titan_watch.png"},
    ];


    return Padding(
      padding: EdgeInsets.only(top: w * 0.06),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// SPECIAL OFFERS TITLE
          Padding(
            padding: EdgeInsets.symmetric(horizontal: w * 0.04),
            child: const Text(
              "Special Offers",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 14),

          /// SPECIAL OFFERS CARD
          Container(
            width: double.infinity, // ✅ full screen width
            height: w * 0.52,
            clipBehavior: Clip.hardEdge,
            margin: const EdgeInsets.only(bottom: 28),
            decoration: BoxDecoration(
              color: const Color(0xFFF9D199),
              borderRadius: BorderRadius.circular(0),
            ),

            // 🔹 KEEP CONTENT INSIDE
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: w * 0.04),
              child: Row(
                children: [
                  /// LEFT TEXT AREA
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          "Top 35% Discount",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "On Beauty, grocery & Fashion",
                          style: TextStyle(
                            fontSize: 11,
                          ),
                          maxLines: 1, // 👈 force single line
                          overflow: TextOverflow.ellipsis, // 👈 safety for small screens
                        ),
                        SizedBox(height: 14),
                        _ExploreButton(),
                      ],
                    ),
                  ),

                  /// RIGHT IMAGE
                  Expanded(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          right: -w * 0.16, // ⭐ pushes outside card
                          top: -w * 0.07,
                          child: Container(
                            width: w * 0.68, // ⭐ bigger than card height
                            height: w * 0.68,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(36),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Image.asset(
                                  "assets/images/offer.png",
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),


                ],
              ),
            ),
          ),


          const SizedBox(height: 0),

          /// TRENDING NOW (FULL WIDTH BLUE SECTION)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 10),
            padding: EdgeInsets.only(
              top: 20,
              bottom: 28,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFF184A99), // dark blue background
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(0),
                topRight: Radius.circular(0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                /// TITLE ROW
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: w * 0.04),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        "Trending Now",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Icon(Icons.arrow_outward, color: Colors.white),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                /// GRID
                Wrap(
                  spacing: w * 0.04,
                  runSpacing: w * 0.04,
                  children: List.generate(products.length, (i) {
                    return Container(
                      width: cardW,
                      height: cardH,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3A64A8),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4BC0FF).withOpacity(0.6),
                            blurRadius: 10,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // IMAGE
                          Expanded(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(16),
                              ),
                              child: Image.asset(
                                products[i]["image"]!,
                                fit: BoxFit.contain,
                                width: double.infinity,
                              ),
                            ),
                          ),

                          // TITLE
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(
                              products[i]["title"]!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );

                  }),
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }
}

/* ================= SMALL WIDGETS ================= */

class _ExploreButton extends StatelessWidget {
  const _ExploreButton();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF194796), // change if needed
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6), // 👈 box-shaped
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
      ),
      onPressed: () {},
      child: const Text(
        "Explore Now",
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );

  }
}

class _HeaderIcon extends StatelessWidget {
  final String image;

  const _HeaderIcon(this.image);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,

      ),
      child: Container(
        width: 64, // increase size
        height: 64,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          // color: Colors.white, // 👈 white background
        ),
        child: Padding(
          padding: const EdgeInsets.all(4), // space between image & border
          child: ClipOval(
            child: Image.asset(
              image,
              fit: BoxFit.cover, // 👈 fully fills circle
            ),
          ),
        ),
      ),

    );
  }
}


class _CategoryItem extends StatelessWidget {
  final String image;
  final String label;

  const _CategoryItem({
    required this.image,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: ClipOval(
            child: Image.asset(
              image,
              fit: BoxFit.cover, // fills completely
              width: 56,
              height: 56,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}


/* ================= FOOTER ================= */


class _BottomFooter extends StatelessWidget {
  const _BottomFooter();

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = w * 0.18;

    return Padding(
      padding: EdgeInsets.all(w * 0.04),
      child: SizedBox(
        height: h,
        child: Stack(
          alignment: Alignment.center,
          children: [

            // 🔹 BLUR LAYER (OUTSIDE PILL)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    color: Colors.white.withOpacity(0.25),
                  ),
                ),
              ),
            ),

            // 🔹 SOLID WHITE PILL (NO BLUR UNDER ICONS)
            Container(
              height: h,
              decoration: BoxDecoration(
                color: Colors.white, // MUST be fully opaque
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 90,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _FooterItem(Icons.home, "Home", true),
                  _FooterItem(Icons.category, "Categories", false),
                  _FooterItem(Icons.receipt, "Orders", false),
                  _FooterItem(Icons.shopping_cart, "Cart", false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FooterItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  const _FooterItem(this.icon, this.label, this.active);

  @override
  Widget build(BuildContext context) {
    final color = active ? const Color(0xFF184A99) : Colors.grey;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: color, fontSize: 12)),
      ],
    );
  }
}

class _CategoryData {
  final String label;
  final String image;
  _CategoryData(this.label, this.image);
}