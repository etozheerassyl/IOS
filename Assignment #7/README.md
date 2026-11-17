# Assignment #7 — Lab: Favorites List (UITableView & Custom Cells)

**Theme:** Favorite Movies (`CineVault`) — 21 iconic films rated from `0` to `5` stars using SF Symbols (`star.fill` / `star`).

## Features
- **UIKit + Storyboard Architecture**: Built entirely with `Main.storyboard` and `LaunchScreen.storyboard` (zero Auto Layout constraints/frames in Swift code).
- **Custom `UITableViewCell` (`FavoriteCell`)**:
  - Fixed-size movie poster `UIImageView` (`68 × 92 pt`, rounded corners, `scaleAspectFill`) on the left.
  - Vertical `UIStackView` on the right with multi-line Title (`UILabel`), Subtitle (`UILabel` with Director • Year • Genre), and a 5-star horizontal `UIStackView` (`star.fill` / `star`).
  - Properly resets all outlets inside `configure(with:)` to handle cell reuse cleanly.
- **21 Custom Movie Posters**: Stored in `Assets.xcassets` (`@2x` and `@3x`).
- **Cinema Midnight & Gold Color Palette**: Deep navy background (`#0D101B`), slate cells (`#141929`), and golden accents (`#F5C518`).
- **Adaptive Layout**: Tested in portrait on both **iPhone SE (3rd generation)** and **iPhone 16 Pro Max** with zero Auto Layout warnings or errors.
