import UIKit

final class DetailViewController: UIViewController {
    var item: FavoriteItem?

    @IBOutlet weak var heroImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet var starImageViews: [UIImageView]!
    @IBOutlet weak var descriptionLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let item else { return }

        navigationItem.title = item.title
        heroImageView.image = UIImage(named: item.imageName)
        titleLabel.text = item.title
        subtitleLabel.text = item.subtitle
        descriptionLabel.text = item.description

        for (index, imageView) in starImageViews.enumerated() {
            let symbolName = index < item.rating ? "star.fill" : "star"
            imageView.image = UIImage(systemName: symbolName)
        }
    }
}
