import UIKit

class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let homeVC = MainViewController()
        let recordsVC = MyRecordsViewController()
        let profileVC = ProfileViewController()

        let homeNav = UINavigationController(rootViewController: homeVC)
        let recordsNav = UINavigationController(rootViewController: recordsVC)
        let profileNav = UINavigationController(rootViewController: profileVC)

        homeNav.tabBarItem = UITabBarItem(title: "홈", image: UIImage(systemName: "house"), tag: 0)
        recordsNav.tabBarItem = UITabBarItem(title: "내 기록", image: UIImage(systemName: "note.text"), tag: 1)
        profileNav.tabBarItem = UITabBarItem(title: "내 정보", image: UIImage(systemName: "person.circle"), tag: 2)

        viewControllers = [homeNav, recordsNav, profileNav]
        
        // 그레이스케일 테마 적용
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor(white: 0.12, alpha: 1) // 배경 어두운 회색
        
        tabBarAppearance.stackedLayoutAppearance.selected.iconColor = UIColor(white: 0.93, alpha: 1)   // 선택 아이콘
        tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(white: 0.93, alpha: 1)]
        tabBarAppearance.stackedLayoutAppearance.normal.iconColor = UIColor(white: 0.5, alpha: 1)      // 비선택 아이콘
        tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(white: 0.5, alpha: 1)]
        
        tabBar.standardAppearance = tabBarAppearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = tabBarAppearance
        }
    }
}
