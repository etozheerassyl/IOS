import UIKit
import AVFoundation

final class ViewController: UIViewController, AVAudioPlayerDelegate {

    // MARK: - Theme Colors
    private enum Theme {
        static let darkIndigo = UIColor(red: 0x12 / 255.0, green: 0x12 / 255.0, blue: 0x1E / 255.0, alpha: 1.0)
        static let translucentWhite = UIColor.white.withAlphaComponent(0.18)
        static let secondaryWhite = UIColor.white.withAlphaComponent(0.72)
    }

    // MARK: - IBOutlets
    @IBOutlet private weak var coverImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var artistLabel: UILabel!
    @IBOutlet private weak var previousButton: UIButton!
    @IBOutlet private weak var playPauseButton: UIButton!
    @IBOutlet private weak var nextButton: UIButton!

    // MARK: - Background Views
    private let backgroundImageView = UIImageView()
    private let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    private let dimmingOverlayView = UIView()

    // MARK: - Timeline / Chronometry Views
    private let progressSlider = TappableSlider()
    private let currentTimeLabel = UILabel()
    private let remainingTimeLabel = UILabel()
    private let timelineStackView = UIStackView()

    // MARK: - Properties
    private let tracks: [Track] = TrackLibrary.tracks
    private var currentIndex: Int = 0
    private var audioPlayer: AVAudioPlayer?
    private var playbackTimer: Timer?
    private var isScrubbing: Bool = false
    private var wasPlayingBeforeScrubbing: Bool = false

    private var currentTrack: Track {
        tracks[currentIndex]
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureAudioSession()
        setupBackground()
        setupTimelineUI()
        setupUI()
        loadCurrentTrack(autoPlay: false, animated: false)

        if CommandLine.arguments.contains("-demoMode") {
            startDemoAutomation()
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopPlaybackTimer()
    }

    // MARK: - Background Setup
    private func setupBackground() {
        view.backgroundColor = .black

        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.clipsToBounds = true
        view.insertSubview(backgroundImageView, at: 0)

        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(blurEffectView, aboveSubview: backgroundImageView)

        dimmingOverlayView.backgroundColor = UIColor.black.withAlphaComponent(0.40)
        dimmingOverlayView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(dimmingOverlayView, aboveSubview: blurEffectView)

        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            blurEffectView.topAnchor.constraint(equalTo: view.topAnchor),
            blurEffectView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            blurEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blurEffectView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            dimmingOverlayView.topAnchor.constraint(equalTo: view.topAnchor),
            dimmingOverlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            dimmingOverlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimmingOverlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    // MARK: - Timeline UI Setup
    private func setupTimelineUI() {
        progressSlider.translatesAutoresizingMaskIntoConstraints = false
        progressSlider.minimumValue = 0
        progressSlider.maximumValue = 1
        progressSlider.value = 0
        progressSlider.minimumTrackTintColor = .white
        progressSlider.maximumTrackTintColor = UIColor.white.withAlphaComponent(0.25)

        let thumb = createThumbImage(diameter: 12)
        progressSlider.setThumbImage(thumb, for: .normal)
        progressSlider.setThumbImage(thumb, for: .highlighted)

        progressSlider.addTarget(self, action: #selector(sliderTouchDown(_:)), for: .touchDown)
        progressSlider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        progressSlider.addTarget(self, action: #selector(sliderTouchEnded(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])

        currentTimeLabel.font = .monospacedDigitSystemFont(ofSize: 12, weight: .medium)
        currentTimeLabel.textColor = Theme.secondaryWhite
        currentTimeLabel.text = "0:00"
        currentTimeLabel.textAlignment = .left

        remainingTimeLabel.font = .monospacedDigitSystemFont(ofSize: 12, weight: .medium)
        remainingTimeLabel.textColor = Theme.secondaryWhite
        remainingTimeLabel.text = "-0:00"
        remainingTimeLabel.textAlignment = .right

        let timeLabelsStack = UIStackView(arrangedSubviews: [currentTimeLabel, remainingTimeLabel])
        timeLabelsStack.axis = .horizontal
        timeLabelsStack.distribution = .equalSpacing
        timeLabelsStack.alignment = .center

        timelineStackView.axis = .vertical
        timelineStackView.spacing = 6
        timelineStackView.alignment = .fill
        timelineStackView.distribution = .fill
        timelineStackView.translatesAutoresizingMaskIntoConstraints = false

        timelineStackView.addArrangedSubview(progressSlider)
        timelineStackView.addArrangedSubview(timeLabelsStack)

        if let mainStackView = coverImageView.superview as? UIStackView {
            mainStackView.spacing = 20
            mainStackView.insertArrangedSubview(timelineStackView, at: 2)
        }
    }

    private func createThumbImage(diameter: CGFloat) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: diameter, height: diameter))
        return renderer.image { ctx in
            ctx.cgContext.setFillColor(UIColor.white.cgColor)
            ctx.cgContext.fillEllipse(in: CGRect(x: 0, y: 0, width: diameter, height: diameter))
        }
    }

    // MARK: - UI Setup & Updates
    private func setupUI() {
        // Aesthetic styling for main cover
        coverImageView.layer.cornerRadius = 24
        coverImageView.layer.cornerCurve = .continuous
        coverImageView.layer.borderWidth = 1.0
        coverImageView.layer.borderColor = UIColor.white.withAlphaComponent(0.18).cgColor
        coverImageView.clipsToBounds = true
        coverImageView.contentMode = .scaleAspectFill

        // Typography styling for dark blurred background
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 26, weight: .bold)

        artistLabel.textColor = Theme.secondaryWhite
        artistLabel.font = .systemFont(ofSize: 17, weight: .medium)

        // Buttons configuration
        setupControlButtons()
        updateUI(animated: false)
    }

    private func setupControlButtons() {
        // Previous Button
        var prevConfig = UIButton.Configuration.filled()
        prevConfig.baseBackgroundColor = Theme.translucentWhite
        prevConfig.baseForegroundColor = .white
        prevConfig.cornerStyle = .capsule
        prevConfig.image = UIImage(
            systemName: "backward.fill",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 22, weight: .semibold)
        )
        previousButton.configuration = prevConfig

        // Next Button
        var nextConfig = UIButton.Configuration.filled()
        nextConfig.baseBackgroundColor = Theme.translucentWhite
        nextConfig.baseForegroundColor = .white
        nextConfig.cornerStyle = .capsule
        nextConfig.image = UIImage(
            systemName: "forward.fill",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 22, weight: .semibold)
        )
        nextButton.configuration = nextConfig

        // Play/Pause Button
        updatePlayPauseButtonIcon()
    }

    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to configure AVAudioSession: \(error.localizedDescription)")
        }
    }

    private func loadCoverImage(for track: Track) -> UIImage {
        if let image = UIImage(named: track.coverImageName) {
            return image
        }
        let nsName = track.coverImageName as NSString
        let base = nsName.deletingPathExtension
        let ext = nsName.pathExtension
        if !ext.isEmpty, let path = Bundle.main.path(forResource: base, ofType: ext), let img = UIImage(contentsOfFile: path) {
            return img
        }
        for candidateExt in ["jpg", "jpeg", "png", "heic"] {
            if let path = Bundle.main.path(forResource: base, ofType: candidateExt), let img = UIImage(contentsOfFile: path) {
                return img
            }
        }
        let config = UIImage.SymbolConfiguration(pointSize: 64, weight: .regular)
        return UIImage(systemName: "music.note", withConfiguration: config) ?? UIImage()
    }

    private func updateUI(animated: Bool = true) {
        guard !tracks.isEmpty else { return }

        let track = currentTrack
        let image = loadCoverImage(for: track)

        let applyData = { [weak self] in
            guard let self = self else { return }
            self.titleLabel.text = track.title
            self.artistLabel.text = track.artist
            self.coverImageView.image = image
            self.backgroundImageView.image = image
        }

        if animated {
            UIView.transition(with: coverImageView, duration: 0.28, options: .transitionCrossDissolve, animations: applyData)
            UIView.transition(with: backgroundImageView, duration: 0.35, options: .transitionCrossDissolve, animations: nil)
            UIView.transition(with: titleLabel, duration: 0.20, options: .transitionCrossDissolve, animations: nil)
            UIView.transition(with: artistLabel, duration: 0.20, options: .transitionCrossDissolve, animations: nil)
        } else {
            applyData()
        }

        updatePlayPauseButtonIcon()
    }

    private func updatePlayPauseButtonIcon() {
        let isPlaying = audioPlayer?.isPlaying ?? false
        let iconName = isPlaying ? "pause.fill" : "play.fill"
        let config = UIImage.SymbolConfiguration(pointSize: 32, weight: .semibold)
        let iconImage = UIImage(systemName: iconName, withConfiguration: config)

        var buttonConfig = playPauseButton.configuration ?? UIButton.Configuration.filled()
        buttonConfig.baseBackgroundColor = .white
        buttonConfig.baseForegroundColor = Theme.darkIndigo
        buttonConfig.cornerStyle = .capsule
        buttonConfig.image = iconImage
        playPauseButton.configuration = buttonConfig
    }

    // MARK: - Playback Timer & Progress
    private func startPlaybackTimer() {
        stopPlaybackTimer()
        playbackTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updatePlaybackProgress()
        }
        if let timer = playbackTimer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }

    private func stopPlaybackTimer() {
        playbackTimer?.invalidate()
        playbackTimer = nil
    }

    private func updatePlaybackProgress() {
        guard let player = audioPlayer, !isScrubbing else { return }
        let currentTime = player.currentTime
        let duration = player.duration
        progressSlider.value = Float(currentTime)
        updateTimeLabels(currentTime: currentTime, duration: duration)
    }

    private func updateTimelineForCurrentTrack() {
        let duration = audioPlayer?.duration ?? 0
        let currentTime = audioPlayer?.currentTime ?? 0
        progressSlider.minimumValue = 0
        progressSlider.maximumValue = Float(max(duration, 1.0))
        progressSlider.value = Float(currentTime)
        progressSlider.isEnabled = (audioPlayer != nil && duration > 0)
        updateTimeLabels(currentTime: currentTime, duration: duration)
    }

    private func updateTimeLabels(currentTime: TimeInterval, duration: TimeInterval) {
        currentTimeLabel.text = formatTime(currentTime)
        let remaining = max(0, duration - currentTime)
        remainingTimeLabel.text = "-\(formatTime(remaining))"
    }

    private func formatTime(_ time: TimeInterval) -> String {
        guard !time.isNaN && time.isFinite && time >= 0 else { return "0:00" }
        let totalSeconds = Int(time.rounded())
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    // MARK: - Timeline Slider Actions
    @objc private func sliderTouchDown(_ sender: UISlider) {
        isScrubbing = true
        wasPlayingBeforeScrubbing = audioPlayer?.isPlaying ?? false
    }

    @objc private func sliderValueChanged(_ sender: UISlider) {
        if !isScrubbing {
            isScrubbing = true
            wasPlayingBeforeScrubbing = audioPlayer?.isPlaying ?? false
        }
        updateTimeLabels(currentTime: Double(sender.value), duration: Double(sender.maximumValue))
    }

    @objc private func sliderTouchEnded(_ sender: UISlider) {
        guard let player = audioPlayer else {
            isScrubbing = false
            return
        }
        player.currentTime = Double(sender.value)
        if wasPlayingBeforeScrubbing && !player.isPlaying {
            player.play()
            startPlaybackTimer()
        }
        isScrubbing = false
        updateTimeLabels(currentTime: player.currentTime, duration: player.duration)
        updatePlayPauseButtonIcon()
    }

    // MARK: - Playback Control
    private func loadCurrentTrack(autoPlay: Bool, animated: Bool = true) {
        guard !tracks.isEmpty else { return }
        let track = currentTrack

        stopPlaybackTimer()

        guard let url = Bundle.main.url(forResource: track.resourceName, withExtension: track.fileExtension) else {
            print("Warning: Audio file '\(track.fileName)' not found in app bundle.")
            audioPlayer?.stop()
            audioPlayer = nil
            updateUI(animated: animated)
            updateTimelineForCurrentTrack()
            showAlert(title: "Track Not Found", message: "Audio file '\(track.fileName)' could not be found.")
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()

            if autoPlay {
                audioPlayer?.play()
                startPlaybackTimer()
            }
        } catch {
            print("Error initializing AVAudioPlayer for \(track.fileName): \(error.localizedDescription)")
            showAlert(title: "Playback Error", message: "Failed to load audio: \(error.localizedDescription)")
            audioPlayer = nil
        }

        updateUI(animated: animated)
        updateTimelineForCurrentTrack()
    }

    // MARK: - IBActions
    @IBAction private func playPauseButtonTapped(_ sender: UIButton) {
        animateButtonPress(sender)
        guard !tracks.isEmpty else { return }

        if let player = audioPlayer {
            if player.isPlaying {
                player.pause()
                stopPlaybackTimer()
            } else {
                player.play()
                startPlaybackTimer()
            }
        } else {
            loadCurrentTrack(autoPlay: true, animated: false)
        }

        updatePlayPauseButtonIcon()
    }

    @IBAction private func previousButtonTapped(_ sender: UIButton) {
        animateButtonPress(sender)
        guard !tracks.isEmpty else { return }

        let wasPlaying = audioPlayer?.isPlaying ?? false
        currentIndex = (currentIndex - 1 + tracks.count) % tracks.count
        loadCurrentTrack(autoPlay: wasPlaying, animated: true)
    }

    @IBAction private func nextButtonTapped(_ sender: UIButton) {
        animateButtonPress(sender)
        guard !tracks.isEmpty else { return }

        let wasPlaying = audioPlayer?.isPlaying ?? false
        currentIndex = (currentIndex + 1) % tracks.count
        loadCurrentTrack(autoPlay: wasPlaying, animated: true)
    }

    // MARK: - Button Animation
    private func animateButtonPress(_ button: UIButton) {
        UIView.animate(withDuration: 0.08, delay: 0, options: [.curveEaseOut, .allowUserInteraction], animations: {
            button.transform = CGAffineTransform(scaleX: 0.90, y: 0.90)
        }) { _ in
            UIView.animate(withDuration: 0.16, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 3.0, options: [.allowUserInteraction], animations: {
                button.transform = .identity
            })
        }
    }

    // MARK: - AVAudioPlayerDelegate
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        stopPlaybackTimer()
        guard !tracks.isEmpty else { return }

        // Automatically advance to the next track when current one finishes
        currentIndex = (currentIndex + 1) % tracks.count
        loadCurrentTrack(autoPlay: true, animated: true)
    }

    // MARK: - Alert Helper
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // MARK: - Automated Demo (Triggered only when passing -demoMode)
    private func startDemoAutomation() {
        // Step 1: Wait 2.0s then Play Track 1
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            guard let self = self else { return }
            self.playPauseButtonTapped(self.playPauseButton)

            // Step 2: Let it play for 3.5s then Pause
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) { [weak self] in
                guard let self = self else { return }
                self.playPauseButtonTapped(self.playPauseButton)

                // Step 3: Wait 2.0s then Next Track (to Track 2)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                    guard let self = self else { return }
                    self.nextButtonTapped(self.nextButton)
                    self.playPauseButtonTapped(self.playPauseButton)

                    // Step 4: Play 3.0s then Next Track (to Track 3)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
                        guard let self = self else { return }
                        self.nextButtonTapped(self.nextButton)

                        // Step 5: Play 3.0s then Previous (back to Track 2)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
                            guard let self = self else { return }
                            self.previousButtonTapped(self.previousButton)

                            // Step 6: Wait 2.5s then Previous (back to Track 1)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak self] in
                                guard let self = self else { return }
                                self.previousButtonTapped(self.previousButton)

                                // Step 7: Wait 2.5s then Previous again (Wrap around to Track 10!)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak self] in
                                    guard let self = self else { return }
                                    self.previousButtonTapped(self.previousButton)

                                    // Step 8: Play 3.0s then Next (Wrap around to Track 1!)
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
                                        guard let self = self else { return }
                                        self.nextButtonTapped(self.nextButton)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Tappable & Draggable Slider
final class TappableSlider: UISlider {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTapGesture()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupTapGesture()
    }

    private func setupTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTrackTap(_:)))
        tap.cancelsTouchesInView = false
        addGestureRecognizer(tap)
    }

    @objc private func handleTrackTap(_ gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: self)
        let width = bounds.width
        guard width > 0 else { return }
        let percentage = Float(max(0, min(1, point.x / width)))
        let newValue = minimumValue + percentage * (maximumValue - minimumValue)
        setValue(newValue, animated: false)
        sendActions(for: .valueChanged)
        sendActions(for: .touchUpInside)
    }

    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let width = bounds.width
        if width > 0 {
            let point = touch.location(in: self)
            let percentage = Float(max(0, min(1, point.x / width)))
            let newValue = minimumValue + percentage * (maximumValue - minimumValue)
            setValue(newValue, animated: false)
            sendActions(for: .valueChanged)
        }
        return true
    }

    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.trackRect(forBounds: bounds)
        rect.size.height = 4
        return rect
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let expanded = bounds.insetBy(dx: -10, dy: -15)
        return expanded.contains(point)
    }
}
