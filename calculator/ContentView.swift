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
            var curMethod: String? = nil
            var result = 0.0
            
            if equation.count % 2 == 0 || equation.count < 3 {
                print("invalid equation \(equation.count), \(equation)")
                return
            }
    
            for piece in equation {
                if methods.contains(piece) {
                    curMethod = piece
                } else {
                    if curMethod != nil {
                        switch curMethod {
                        case "%":
                            result = result.truncatingRemainder(dividingBy: Double(piece)!)
                        case "X":
                            result *= Double(piece)!
                        case "/":
                            result /= Double(piece)!
                        case "+":
                            result += Double(piece)!
                        case "-":
                            result -= Double(piece)!
                        default:
                            print("Unsupported operator: \(curMethod!)")
                        }
                        // reset method
                        curMethod = nil
                    } else {
                        result = Double(piece)!
                    }
                }
            }
            
            let formatter = NumberFormatter()
            formatter.minimumFractionDigits = 0
            formatter.maximumFractionDigits = 10
            let newOutput = formatter.string(from: NSNumber(value: result)) ?? ""
            output.insert(["= " + newOutput], at: 0)
            output.insert([newOutput], at: 0)
            
        } else {
            let cur = output[0]
            let end = cur.count - 1
            let last = cur.last!
            
            if (last == "0" || last == "" || last == "NaN") && !methods.contains(input) {
                /* When the current line is a lone "0", blank, or NaN output from a previous run
                 replace it with new input
                 */
                output[0][end] = input
            } else if methods.contains(last) {
                if methods.contains(input) {
                    /* The last entry in the current line is also a method replace it with the
                     new method input
                     */
                    output[0][end] = input
                } else {
                    /* The last entry is a method and the input is a number start a new
                     entry in the current line and set it to the number input
                     */
                    output[0].append(input)
                }
            } else {
                if methods.contains(input) {
                    /* The last entry is a number and the input is a method start a new
                     entry in the currentry line and set it to the method input */
                    output[0].append(input)
                } else {
                    /* The last entry is a number and the input is also a number
                     concat the number input onto the existing entry */
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
            Text("Barebones Calculator").font(.largeTitle.bold()).foregroundColor(.white)
            
            BannerAdView(placementId: "BANNER04-8166553")
                .frame(width: 320, height: 50)
                .background(Color.white)
            
            
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
