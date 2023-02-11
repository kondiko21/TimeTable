//
//  EnvironmentValue_extension.swift
//  Timetable 3.0
//
//  Created by Konrad on 30/10/2022.
//  Copyright © 2022 Konrad. All rights reserved.
//

import Foundation
import SwiftUI

private struct UpdatedContextKey: EnvironmentKey {
    static var defaultValue: Bool = false
    
    typealias Value = Bool

}

extension EnvironmentValues {
    
    var updatedContext: Bool {
        get { self[UpdatedContextKey.self] }
        set { self[UpdatedContextKey.self] = newValue }
    }
}

extension View {
    func updateContextValue(_ value: Bool) -> some View {
        environment(\.updatedContext, !value)
    }
}
