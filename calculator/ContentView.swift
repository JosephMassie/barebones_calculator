//
//  ContentView.swift
//  calculator
//
//  Created by Joseph Massie on 2/11/25.
//

import SwiftUI


struct CalcBtn: Identifiable {
    let id = UUID()
    let title: String
    let backgroundColor: Color
    let textColor: Color
}

var inputs: [[CalcBtn]] = [
    [
        CalcBtn(title: "CL", backgroundColor: Color.buttonSecondary, textColor: Color.buttonText),
        CalcBtn(title: "X", backgroundColor: Color.buttonSecondary, textColor: Color.buttonText),
        CalcBtn(title: "/", backgroundColor: Color.buttonSecondary, textColor: Color.buttonText),
        CalcBtn(title: "-", backgroundColor: Color.buttonSecondary, textColor: Color.buttonText),
    ],
    [
        CalcBtn(title: "7", backgroundColor: Color.buttonPrimary, textColor: Color.buttonText),
        CalcBtn(title: "8", backgroundColor: Color.buttonPrimary, textColor: Color.buttonText),
        CalcBtn(title: "9", backgroundColor: Color.buttonPrimary, textColor: Color.buttonText),
        CalcBtn(title: "+", backgroundColor: Color.buttonSecondary, textColor: Color.buttonText),
    ],
    [
        CalcBtn(title: "4", backgroundColor: Color.buttonPrimary, textColor: Color.buttonText),
        CalcBtn(title: "5", backgroundColor: Color.buttonPrimary, textColor: Color.buttonText),
        CalcBtn(title: "6", backgroundColor: Color.buttonPrimary, textColor: Color.buttonText),
        CalcBtn(title: "=", backgroundColor: Color.buttonSecondary, textColor: Color.buttonText),
    ],
    [
        CalcBtn(title: "1", backgroundColor: Color.buttonPrimary, textColor: Color.buttonText),
        CalcBtn(title: "2", backgroundColor: Color.buttonPrimary, textColor: Color.buttonText),
        CalcBtn(title: "3", backgroundColor: Color.buttonPrimary, textColor: Color.buttonText),
        CalcBtn(title: "0", backgroundColor: Color.buttonPrimary, textColor: Color.buttonText),
        
    ]
];

let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())];
let emptyHistory = [["0"]]

struct ButtonGrid: View {
    @Binding var output: [[String]]
    
    func processInput(_ input: String) -> Void {
        let methods: [String] = ["%", "X", "/", "+", "-"]
        
        if input == "CL" {
            output = emptyHistory
        } else if input == "=" {
            let equation = output[0]
            var method: String? = nil
            var last = 0.0
            
            if equation.count % 2 == 0 || equation.count < 3 {
                print("invalid equation \(equation.count), \(equation)")
                return
            }
    
            for piece in equation {
                if methods.contains(piece) {
                    method = piece
                } else {
                    if method != nil {
                        switch method {
                        case "%":
                            last = last.truncatingRemainder(dividingBy: Double(piece)!)
                        case "X":
                            last *= Double(piece)!
                        case "/":
                            last /= Double(piece)!
                        case "+":
                            last += Double(piece)!
                        case "-":
                            last -= Double(piece)!
                        default:
                            print("Unsupported operator: \(method!)")
                        }
                        // reset method
                        method = nil
                    } else {
                        last = Double(piece)!
                    }
                }
            }
            
            let format = NumberFormatter()
            format.minimumFractionDigits = 0
            format.maximumFractionDigits = 10
            let result = format.string(from: NSNumber(value: last)) ?? ""
            output.insert(["= " + result], at: 0)
            output.insert([result], at: 0)
            
        } else {
            let cur = output[0]
            let end = cur.count - 1
            let last = cur.last!
            
            if (last == "0" || last == "" || last == "NaN") && !methods.contains(input) {
                // the current output is only zero and the input is not a modifier replace it
                output[0][end] = input
            } else if methods.contains(last) {
                if methods.contains(input) {
                    // the last entry is a method and the input is also a method replace it
                    output[0][end] = input
                } else {
                    // last entry is a method but input is a number add it to the queue
                    output[0].append(input)
                }
            } else {
                if methods.contains(input) {
                    output[0].append(input)
                } else {
                    output[0][end] += input
                }
            }
        }
    }

    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(inputs.flatMap { $0 }) { btn in
                Button(action: {
                    processInput(btn.title)
                }) {
                    Text(btn.title)
                        .frame(
                            width: 40,
                            height: 40
                        )
                        .padding(.all, 10)
                        .background(btn.backgroundColor)
                        .foregroundColor(btn.textColor)
                        .font(.title)
                        .fontWeight(.bold)
                        .cornerRadius(15)
                }
            }
        }.padding(.all)
            .padding(.vertical, 20)
            .background()
            .cornerRadius(20)
    }
}

struct ResultsHistory: View {
    @Binding var output: [[String]]

    var body: some View {
        ScrollViewReader { scrollView in
            ScrollView(.vertical) {
                VStack(alignment: .trailing, spacing: 5) {
                    ForEach(output.reversed(), id: \.self) { line in
                        Text(line.joined(separator: " "))
                            .font(.title)
                            .lineLimit(/*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                }.id("history").frame(maxWidth: .infinity)
            }.onChange(of: output, initial: false, {
                withAnimation {
                    scrollView.scrollTo("history", anchor: .bottom)
                }
            }).frame(maxWidth: .infinity, minHeight: 100, maxHeight: 200)
                .padding(.all, 10)
                .background(Color.window)
        }
    }
}

struct ContentView: View {
    @State public var output: [[String]] = emptyHistory
    
    var body: some View {
        VStack {
            Text("Barebones Calculator").font(.largeTitle).foregroundColor(.white).fontWeight(.bold)
            
            Spacer()
            
            ResultsHistory(output: $output)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .background(RoundedRectangle(cornerRadius: 20).stroke(Color.black, lineWidth: 4))
                .padding(.all)
                
            ButtonGrid(output: $output)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .background(RoundedRectangle(cornerRadius: 20).stroke(Color.black, lineWidth: 4))
                .padding(.all)
            
            Spacer()
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 10)
        .background(Color.main)
    }
}

#Preview {
    ContentView()
}
