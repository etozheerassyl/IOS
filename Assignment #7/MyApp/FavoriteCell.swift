import UIKit

final class FavoriteCell: UITableViewCell {
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var star1ImageView: UIImageView!
    @IBOutlet weak var star2ImageView: UIImageView!
    @IBOutlet weak var star3ImageView: UIImageView!
    @IBOutlet weak var star4ImageView: UIImageView!
    @IBOutlet weak var star5ImageView: UIImageView!

    private static let filledStarColor = UIColor(red: 0.96, green: 0.77, blue: 0.09, alpha: 1.0)
    private static let emptyStarColor = UIColor(red: 0.28, green: 0.32, blue: 0.42, alpha: 1.0)

    func configure(with item: FavoriteItem) {
        posterImageView.image = UIImage(named: item.imageName)
        titleLabel.text = item.title
        subtitleLabel.text = item.subtitle

        let clampedRating = min(max(item.rating, 0), 5)
        let starViews = [
            star1ImageView,
            star2ImageView,
            star3ImageView,
            star4ImageView,
            star5ImageView
        ]

        for (index, starView) in starViews.enumerated() {
            let isFilled = index < clampedRating
            starView?.image = UIImage(systemName: isFilled ? "star.fill" : "star")
            starView?.tintColor = isFilled ? Self.filledStarColor : Self.emptyStarColor
        }
    }
}
