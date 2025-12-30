import AVFoundation
import Foundation

@Observable
class AudioManager {
    private var alarmPlayer: AVAudioPlayer?
    private var silentPlayer: AVAudioPlayer?
    private var toneEngine: AVAudioEngine?
    private var tonePlayer: AVAudioPlayerNode?
    private var isPlayingTone = false

    var isPlaying: Bool {
        alarmPlayer?.isPlaying ?? isPlayingTone
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

        if let soundUrl = url {
            do {
                alarmPlayer = try AVAudioPlayer(contentsOf: soundUrl)
                alarmPlayer?.numberOfLoops = -1 // Loop until stopped
                alarmPlayer?.volume = 1.0
                alarmPlayer?.play()
                return
            } catch {
                print("Failed to play alarm file: \(error)")
            }
        }

        // No sound file found - generate alarm tone
        playGeneratedTone()
    }

    private func playGeneratedTone() {
        toneEngine = AVAudioEngine()
        tonePlayer = AVAudioPlayerNode()

        guard let engine = toneEngine, let player = tonePlayer else { return }

        let sampleRate: Double = 44100
        let frequency: Double = 880 // A5 note - urgent sounding
        let amplitude: Float = 0.8

        // Create audio format
        guard let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1) else { return }

        // Generate a beeping pattern (beep on/off)
        let beepDuration: Double = 0.3
        let silenceDuration: Double = 0.2
        let patternDuration = beepDuration + silenceDuration
        let totalDuration: Double = 2.0 // 2 second pattern that loops
        let frameCount = AVAudioFrameCount(sampleRate * totalDuration)

        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return }
        buffer.frameLength = frameCount

        guard let floatData = buffer.floatChannelData?[0] else { return }

        for frame in 0..<Int(frameCount) {
            let time = Double(frame) / sampleRate
            let patternTime = time.truncatingRemainder(dividingBy: patternDuration)

            if patternTime < beepDuration {
                // Beep - sine wave
                let phase = 2.0 * Double.pi * frequency * time
                floatData[frame] = amplitude * Float(sin(phase))
            } else {
                // Silence
                floatData[frame] = 0
            }
        }

        engine.attach(player)
        engine.connect(player, to: engine.mainMixerNode, format: format)

        do {
            try engine.start()
            // Schedule buffer to loop
            player.scheduleBuffer(buffer, at: nil, options: .loops)
            player.play()
            isPlayingTone = true
        } catch {
            print("Failed to start tone engine: \(error)")
        }
    }

    func stopAlarm() {
        alarmPlayer?.stop()
        alarmPlayer = nil

        tonePlayer?.stop()
        toneEngine?.stop()
        tonePlayer = nil
        toneEngine = nil
        isPlayingTone = false
    }

    func setVolume(_ volume: Float) {
        alarmPlayer?.volume = volume
    }
}
