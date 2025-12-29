import AVFoundation
import Foundation

@Observable
class AudioManager {
    private var alarmPlayer: AVAudioPlayer?
    private var silentPlayer: AVAudioPlayer?

    var isPlaying: Bool {
        alarmPlayer?.isPlaying ?? false
    }

    func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.duckOthers])
            try session.setActive(true)
        } catch {
            print("Failed to configure audio session: \(error)")
        }
    }

    func startBackgroundAudio() {
        // Play silent audio to keep app alive in background
        guard let url = Bundle.main.url(forResource: "silence", withExtension: "caf") else {
            // If no silence file, create one programmatically or skip
            print("No silence.caf found - background audio disabled")
            return
        }

        do {
            silentPlayer = try AVAudioPlayer(contentsOf: url)
            silentPlayer?.numberOfLoops = -1
            silentPlayer?.volume = 0.01
            silentPlayer?.play()
        } catch {
            print("Failed to start background audio: \(error)")
        }
    }

    func stopBackgroundAudio() {
        silentPlayer?.stop()
        silentPlayer = nil
    }

    func playAlarm(soundName: String = "default") {
        // Try custom sound first, fall back to default
        var url = Bundle.main.url(forResource: soundName, withExtension: "caf")
        if url == nil {
            url = Bundle.main.url(forResource: "alarm", withExtension: "caf")
        }

        guard let soundUrl = url else {
            print("No alarm sound found")
            return
        }

        do {
            alarmPlayer = try AVAudioPlayer(contentsOf: soundUrl)
            alarmPlayer?.numberOfLoops = -1 // Loop until stopped
            alarmPlayer?.volume = 1.0
            alarmPlayer?.play()
        } catch {
            print("Failed to play alarm: \(error)")
        }
    }

    func stopAlarm() {
        alarmPlayer?.stop()
        alarmPlayer = nil
    }

    func setVolume(_ volume: Float) {
        alarmPlayer?.volume = volume
    }
}
