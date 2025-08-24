//
//  Chore.swift
//  ChoreRallyApp
//
//  Created by Gemini on [Date].
//
//  This file defines the data model for a single chore.
//

import Foundation
import FirebaseFirestore

struct Chore: Identifiable, Codable, Hashable {
    // --- This has been changed from @DocumentID to a simple var ---
    // This allows the model to be decoded from a JSON file without an ID.
    // Firestore will still map the document ID to this property by its name.
    var id: String?
    
    var name: String
    var description: String
    var estimatedTimeInMinutes: Int
    var difficultyMultiplier: Double
    var category: ChoreCategory
    
    // Enum for the different difficulty levels
    enum Difficulty: String, CaseIterable, Codable {
        case easy = "Easy"
        case moderate = "Moderate"
        case difficult = "Difficult"
        case superChallenge = "Super Challenge!"
        
        var multiplier: Double {
            switch self {
            case .easy: return 0.75
            case .moderate: return 1.0
            case .difficult: return 1.5
            case .superChallenge: return 2.0
            }
        }
    }
    
    // Enum for chore categories
    enum ChoreCategory: String, CaseIterable, Codable {
        case kitchen = "Kitchen"
        case animals = "Animals"
        case laundry = "Laundry"
        case cleaning = "Cleaning"
        case tidying = "Tidying"
        case outside = "Outside"
        case foodPrep = "Food Prep"
        case poolMaintenance = "Pool Maintenance"
        case watchingSiblings = "Watching Siblings"
        case diy = "DIY"
        case other = "Other"
    }
}

