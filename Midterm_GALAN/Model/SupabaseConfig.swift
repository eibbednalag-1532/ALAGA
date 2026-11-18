//
//  SupabaseConfig.swift
//  Midterm_GALAN
//
//  Created by Mac-LAB on 11/13/26.
//

import Foundation

enum SupabaseConfig {
    static let url = "https://xoonplsewuidcosxvlgw.supabase.co"
    static let anonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inhvb25wbHNld3VpZGNvc3h2bGd3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTQ3OTc0MTMsImV4cCI6MjExMDM3MzQxM30.xfYrY-tt0G8brHGVVI4c17Xm_cXl1aVE1EIXxPKMMKo"

    //False while the placeholders above are still here
    static var isConfigured: Bool {
        !url.contains("YOUR-PROJECT-ID") && !anonKey.contains("YOUR-SUPABASE-ANON-KEY")
    }
}
