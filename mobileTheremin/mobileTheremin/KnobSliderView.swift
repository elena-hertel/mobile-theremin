//
//  KnobSliderView.swift
//  Testing
//
//  Created by Alicia Chun on 5/15/24.
//
import AudioKit
import Controls
import SwiftUI

class Refresh: ObservableObject {
    @Published var version = 0
}

func getBinding(param: NodeParameter, refresh: Refresh) -> Binding<Float> {
    Binding(
        get: { param.value },
        set: { param.value = $0; refresh.version += 1}
    )
}

func getIntBinding(param: NodeParameter, refresh: Refresh) -> Binding<Int> {
    Binding(get: { Int(param.value) }, set: { param.value = AUValue($0); refresh.version += 1 })
}

public struct FrequencyView: View {
    @Binding var frequency: Double
    
    public var body: some View {
        VStack(alignment: .center) {
            VStack {
                Text("Frequency [Hz]")
                    .minimumScaleFactor(0.2)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                Text(String(format: "%0.2f", frequency)).lineLimit(1)
            }
            .frame(height: 50)
            // Use ArcKnob or any other view to represent frequency visually
            ArcKnob("", value: Binding<Float>(
                get: { Float(frequency) },
                set: { frequency = Double($0) }
            ), range: 250...1050)
        }
    }
}

public struct AmplitudeView: View {
    @Binding var volume: Float
    
    public var body: some View {
        VStack(alignment: .center) {
            VStack {
                Text("Amplitude")
                    .minimumScaleFactor(0.2)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                Text(String(format: "%0.2f", volume)).lineLimit(1)
            }
            .frame(height: 50)
            ModWheel(value: $volume)
        }
    }
}
