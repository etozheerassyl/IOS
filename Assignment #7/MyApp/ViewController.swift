import UIKit

final class ViewController: UIViewController, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!

    private let items = FavoriteItem.movies

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Favorite Movies"
        tableView.dataSource = self

        let cinemaBg = UIColor(red: 0.05, green: 0.06, blue: 0.11, alpha: 1.0)
        let cinemaGold = UIColor(red: 0.96, green: 0.77, blue: 0.09, alpha: 1.0)

        view.backgroundColor = cinemaBg
        tableView.backgroundColor = cinemaBg
        tableView.separatorColor = UIColor(red: 0.15, green: 0.18, blue: 0.27, alpha: 1.0)

        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        navAppearance.backgroundColor = cinemaBg
        navAppearance.titleTextAttributes = [
            .foregroundColor: cinemaGold,
            .font: UIFont.systemFont(ofSize: 18, weight: .bold)
        ]
        navAppearance.largeTitleTextAttributes = [
            .foregroundColor: cinemaGold
        ]
        navigationController?.navigationBar.standardAppearance = navAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navAppearance
        navigationController?.navigationBar.compactAppearance = navAppearance
        navigationController?.navigationBar.tintColor = cinemaGold
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "FavoriteCell",
            for: indexPath
        ) as? FavoriteCell else {
            return UITableViewCell()
        }

        cell.configure(with: items[indexPath.row])
        return cell
    }
}
