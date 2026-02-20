import 'package:chatify/controller/auth/main_controller.dart';
import 'package:chatify/theme/app_theme.dart';
import 'package:chatify/views/auth/profile/profile_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';

class MainView extends GetView<MainController> {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: controller.pageController,
        onPageChanged: controller.onPageChanged,
        children: [Container(), Container(), Container(), ProfileView()],
      ),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          currentIndex: controller.currentIndex,
          onTap: controller.changeTabIndex,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppTheme.primaryColor,
          unselectedItemColor: AppTheme.textSecondaryColor,
          backgroundColor: Colors.white,
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: _buildIconWithBadge(
                Icons.chat_outlined,
                controller.getUnreadCount(),
              ),
              activeIcon: _buildIconWithBadge(
                Icons.chat,
                controller.getUnreadCount(),
              ),
              label: "Chats",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outlined),
              activeIcon: Icon(Icons.people),
              label: "Friends",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outlined),
              activeIcon: Icon(Icons.person_search),
              label: "Find Friends",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_search_outlined),
              activeIcon: Icon(Icons.person_search),
              label: "Profile",
            ),
          ],
        ),
      ),
    );

  }

  Widget _buildIconWithBadge(IconData icon, int count){
    return Stack(
      children: [
        Icon(icon),
        if(count>0)
          Positioned(
              right: 0,top: 0,
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor,
                  shape: BoxShape.circle
                ),
                constraints: BoxConstraints(minWidth: 12,minHeight: 12),
                child: Text(
                  count >99?"99+":count.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8
                  ),
                  textAlign: TextAlign.center,
                ),
              ))
      ],
    );
  }
}
