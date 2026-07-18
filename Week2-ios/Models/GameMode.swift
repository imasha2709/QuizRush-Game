import Foundation
import SwiftUI

enum GameMode: String, Codable, CaseIterable, Identifiable {

    case tapFrenzy = "Tap Frenzy"
    case lightItUp = "Light It Up"
    case quizRush = "Quiz Rush"

    var id: String {
        rawValue
    }

    var icon: String {
        switch self {
        case .tapFrenzy: return "hand.tap.fill"
        case .lightItUp: return "lightbulb.fill"
        case .quizRush:  return "brain.head.profile"
        }
    }

    var color: String {
        switch self {
        case .tapFrenzy: return "green"
        case .lightItUp: return "orange"
        case .quizRush:  return "blue"
        }
    }
    
   
    var themeColor: Color {
        switch self {
        case .tapFrenzy: return .green
        case .lightItUp: return .orange
        case .quizRush:  return .blue
        }
    }
}
