# Favorites Navigator — My Countries

- **Author:** Yerassyl
- **Theme:** Favorite World Countries (`My Countries`)

## Description
A Storyboard-only UIKit iOS application displaying 20 favorite countries around the world inside a `UINavigationController` with Large Titles. Each row in the `UITableView` shows a custom `FavoriteCell` with the country's image and title. Tapping a row triggers a `showDetail` Show segue in `Main.storyboard`, passing the selected `FavoriteItem` via `prepare(for:sender:)` to `DetailViewController`, which displays the large hero image, title, region/capital subtitle, 5-star SF Symbol rating, and multi-sentence description.

## Screenshots
- **List Screen:** `screenshots/list_screen.png`
- **Detail Screen:** `screenshots/detail_screen.png`
- **Launch Screen:** `screenshots/launch_screen.png`
- **App Icon on Home Screen:** `screenshots/app_icon.png`
