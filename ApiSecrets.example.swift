import Foundation

/// Template for API secrets. Copy to `FiveCubedMoments/FiveCubedMoments/Services/Summarization/ApiSecrets.swift`
/// and replace with your key. With "YOUR_KEY_HERE", API calls fail and the app falls back to on-device NL.
///
/// Setup: `cp ApiSecrets.example.swift FiveCubedMoments/FiveCubedMoments/Services/Summarization/ApiSecrets.swift`
/// then add your cloud API key.
enum ApiSecrets {
    static let cloudApiKey = "YOUR_KEY_HERE"
}
