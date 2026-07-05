import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_constants.dart';
import '../../../../core/theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _slides = [
    {
      'icon': Icons.location_on_rounded,
      'title': 'Office Geofencing',
      'desc': 'Securely log your presence only within your assigned company office boundaries.',
    },
    {
      'icon': Icons.add_a_photo_rounded,
      'title': 'Selfie Attendance',
      'desc': 'Prevent proxy entries with automatic, timestamped live-selfie matching at punch time.',
    },
    {
      'icon': Icons.coffee_rounded,
      'title': 'Break Tracking',
      'desc': 'Log tea, lunch, and official breaks in real-time, calculating net working hours precisely.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () => context.go(RoutePaths.login),
                child: const Text('Skip'),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          slide['icon'] as IconData,
                          size: 100,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(height: 40),
                        Text(
                          slide['title'] as String,
                          style: theme.textTheme.displaySmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          slide['desc'] as String,
                          style: const TextStyle(color: Colors.grey, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 30.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(
                      _slides.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        width: _currentPage == index ? 24.0 : 8.0,
                        height: 8.0,
                        decoration: BoxDecoration(
                          color: _currentPage == index ? AppTheme.primaryColor : Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                      ),
                    ),
                  ),
                  FloatingActionButton(
                    onPressed: () {
                      if (_currentPage < _slides.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeIn,
                        );
                      } else {
                        context.go(RoutePaths.login);
                      }
                    },
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    child: Icon(
                      _currentPage < _slides.length - 1 ? Icons.arrow_forward_rounded : Icons.check_rounded,
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
