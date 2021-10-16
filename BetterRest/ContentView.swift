//
//  ContentView.swift
//  BetterRest
//
//  Created by Abed Atassi on 2021-09-13.
//

import SwiftUI

struct ContentView: View {
    
    static var defaultWakeUpTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }
    
    @State private var sleepAmt = 8.0
    @State private var wakeUp = defaultWakeUpTime
    @State private var coffeeCups = 1
    
    
    @State private var alertTitle = ""
    @State private var alertMsg = ""
    @State private var showAlert = false
    

    var body: some View {
        
        NavigationView{
            Form {
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("When do you wake up?")
                        .font(.headline)
            
                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        //.datePickerStyle(WheelDatePickerStyle())
                }
                    
                VStack(alignment: .leading, spacing: 0) {
                    Text("Desired amount of sleep")
                        .font(.headline)
                    
                    Stepper(value: $sleepAmt, in: 4...12, step: 0.25) {
                        Text("\(sleepAmt, specifier: "%g") hours")
                    }
                }
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("Daily coffee intake")
                        .font(.headline)
                    
                    /* Picker
                    Picker("Number of coffee cups", selection: $coffeeCups) {
                        ForEach(0 ..< 21) {
                            if $0 == 1 {
                                Text("1 cup")
                            } else {
                                Text("\($0) cups")
                            }
                        }
                    }*/
                    
                    Stepper(value: $coffeeCups, in: 0...20) {
                        if coffeeCups == 1 {
                            Text("1 cup")
                        } else {
                            Text("\(coffeeCups) cups")
                        }
                    }
                }
                
                Section(header: Text("Recommended bedtime")) {
                    Text("\(alertMsg)")
                        .font(.headline)
                }
            }
            .navigationTitle("BetterRest")
            .navigationBarItems(trailing:
                Button(action: calculateBedTime) {
                    Text("Calculate")
                }
            )
            .alert(isPresented: $showAlert) {
                Alert(title: Text(alertTitle), message: Text(alertMsg), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    func calculateBedTime() {
        
        let model: SleepCalculator = SleepCalculator()
        let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
        let hour = (components.hour ?? 0) * 60 * 60
        let minute = (components.minute ?? 0) * 60
    
        do {
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmt, coffee: Double(coffeeCups))
            
            let sleepTime = wakeUp - prediction.actualSleep
            let formater = DateFormatter()
            formater.timeStyle = .short
            
            alertMsg = formater.string(from: sleepTime)
            alertTitle = "Your ideal bedtime is..."
            
        } catch {
            alertTitle = "Error"
            alertMsg = "Something went wrong calculating your bedtime"
        }
        
        showAlert = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
