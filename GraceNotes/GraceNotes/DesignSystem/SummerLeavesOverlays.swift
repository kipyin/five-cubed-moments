import SwiftUI
import UIKit
import AVFoundation

/// Shared seam: picks video or native leaves above the paper field, below interactive content.
struct SummerLeavesOverlaySeam: View {
    let renderer: JournalSummerLeavesRenderer
    let reduceMotion: Bool

    var body: some View {
        Group {
            if reduceMotion {
                Color.clear
            } else {
                switch renderer {
                case .video:
                    SummerLeavesVideoOverlay()
                case .native:
                    SummerLeavesNativeOverlay()
                }
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

// MARK: - Video

struct SummerLeavesVideoOverlay: View {
    var body: some View {
        Group {
            if let url = Bundle.main.url(forResource: "SummerLeavesLoop", withExtension: "mp4") {
                LoopingVideoPlayerView(url: url)
                    .opacity(0.2)
            } else {
                SummerLeavesNativeOverlay()
                    .opacity(0.18)
            }
        }
    }
}

private struct LoopingVideoPlayerView: UIViewRepresentable {
    let url: URL

    func makeCoordinator() -> Coordinator {
        Coordinator(url: url)
    }

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
        context.coordinator.attach(to: view)
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.updateBounds(uiView.bounds)
    }

    final class Coordinator {
        private let url: URL
        private var player: AVQueuePlayer?
        private var looper: AVPlayerLooper?
        private weak var hostView: UIView?
        private var playerLayer: AVPlayerLayer?

        init(url: URL) {
            self.url = url
        }

        func attach(to view: UIView) {
            hostView = view
            guard playerLayer == nil else {
                updateBounds(view.bounds)
                return
            }
            let item = AVPlayerItem(url: url)
            let queue = AVQueuePlayer()
            queue.isMuted = true
            queue.preventsDisplaySleepDuringVideoPlayback = false
            let loop = AVPlayerLooper(player: queue, templateItem: item)
            looper = loop
            player = queue
            let layer = AVPlayerLayer(player: queue)
            layer.videoGravity = .resizeAspectFill
            layer.frame = view.bounds
            view.layer.addSublayer(layer)
            playerLayer = layer
            queue.play()
        }

        func updateBounds(_ bounds: CGRect) {
            playerLayer?.frame = bounds
        }

        func teardown() {
            player?.pause()
            looper = nil
            player = nil
            playerLayer?.removeFromSuperlayer()
            playerLayer = nil
            hostView = nil
        }
    }
}

// MARK: - Native

struct SummerLeavesNativeOverlay: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0, paused: reduceMotion)) { timeline in
            Canvas { context, size in
                let t = timeline.date.timeIntervalSinceReferenceDate
                drawLeaves(context: context, size: size, time: t)
            }
        }
        .opacity(0.22)
    }

    private func drawLeaves(context: GraphicsContext, size: CGSize, time: Double) {
        let palette = [
            Color(red: 0.45, green: 0.58, blue: 0.38),
            Color(red: 0.52, green: 0.62, blue: 0.40),
            Color(red: 0.38, green: 0.50, blue: 0.34)
        ]
        for i in 0..<14 {
            let phase = Double(i) * 0.73
            let baseX = size.width * (0.08 + CGFloat(i % 5) * 0.19)
            let baseY = size.height * (0.12 + CGFloat((i * 3) % 7) * 0.13)
            let driftX = sin(time * 0.35 + phase) * size.width * 0.04
            let driftY = cos(time * 0.28 + phase * 1.1) * size.height * 0.06 + CGFloat(i) * 12
            let rotation = time * 0.15 + phase
            let scale = 0.85 + 0.08 * sin(time * 0.5 + phase)
            var leaf = leafPath(in: CGSize(width: 28 * scale, height: 16 * scale))
            let transform = CGAffineTransform(translationX: baseX + driftX, y: baseY + driftY)
                .rotated(by: CGFloat(rotation))
            leaf = leaf.applying(transform)
            context.fill(leaf, with: .color(palette[i % palette.count].opacity(0.55)))
        }
    }

    private func leafPath(in size: CGSize) -> Path {
        var p = Path()
        let w = size.width
        let h = size.height
        p.move(to: CGPoint(x: 0, y: h * 0.5))
        p.addQuadCurve(
            to: CGPoint(x: w, y: h * 0.5),
            control: CGPoint(x: w * 0.5, y: 0)
        )
        p.addQuadCurve(
            to: CGPoint(x: 0, y: h * 0.5),
            control: CGPoint(x: w * 0.5, y: h)
        )
        p.closeSubpath()
        return p
    }
}
