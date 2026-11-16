//
//  SupabaseConfig.swift
//  Midterm_GALAN
//
//  Created by Mac-LAB on 11/13/26.
//

import Foundation

// MARK: Supabase Keys
//Paste your own keys here (Supabase Dashboard > Project Settings > API)
enum SupabaseConfig {
    static let url = "https://YOUR-PROJECT-ID.supabase.co"
    static let anonKey = "YOUR-SUPABASE-ANON-KEY"

    //False while the placeholders above are still here
    static var isConfigured: Bool {
        !url.contains("YOUR-PROJECT-ID") && !anonKey.contains("YOUR-SUPABASE-ANON-KEY")
    }
}
