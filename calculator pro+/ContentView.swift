//
//  ContentView.swift
//  calculator pro+
//
//  Created by Li on 2025/6/18.
//

import SwiftUI

// 计算器模式枚举
enum CalculatorMode: String, CaseIterable {
    case home = "🏠"
    case calc = "➕➖"
    case stat = "📊"
    case table = "ƒ"
    case equation = "⚖️"
    case inequality = ">"
    case complex = "🔢"
    case base = "🔢"
    case matrix = "📐"
    case vector = "↗️"
    case ratio = "%"
    
    var title: String {
        switch self {
        case .home: return "主屏幕"
        case .calc: return "计算"
        case .stat: return "统计"
        case .table: return "函数表格"
        case .equation: return "方程"
        case .inequality: return "不等式"
        case .complex: return "复数"
        case .base: return "基数"
        case .matrix: return "矩阵"
        case .vector: return "向量"
        case .ratio: return "比例"
        }
    }
    
    var color: Color {
        switch self {
        case .home: return .white
        case .calc: return .blue
        case .stat: return .purple
        case .table: return .green
        case .equation: return .orange
        case .inequality: return .red
        case .complex: return .cyan
        case .base: return .pink
        case .matrix: return .indigo
        case .vector: return .mint
        case .ratio: return .brown
        }
    }
}

// 按钮类型枚举
enum ButtonType {
    case number(Int)
    case operation(String)
    case function(String)
    case navigation(String)
    case special(String)
}

// 分数结构
struct Fraction {
    var numerator: String = ""
    var denominator: String = ""
    var isEditingNumerator: Bool = true
    
    var display: String {
        if numerator.isEmpty && denominator.isEmpty {
            return "□/□"
        }
        let num = numerator.isEmpty ? "□" : numerator
        let den = denominator.isEmpty ? "□" : denominator
        return "\(num)/\(den)"
    }
    
    var value: Double? {
        guard let num = Double(numerator), let den = Double(denominator), den != 0 else {
            return nil
        }
        return num / den
    }
}

// 主视图
struct ContentView: View {
    @State private var currentMode: CalculatorMode = .calc
    @State private var display: String = "0"
    @State private var expression: String = ""
    @State private var memory: Double = 0
    @State private var isShiftActive: Bool = false
    @State private var showCursor: Bool = true
    @State private var currentFraction: Fraction?
    @State private var isEditingFraction: Bool = false
    @State private var cursorPosition: Int = 0
    @State private var selectedModeIndex: Int = 0 // 主屏幕中选中的模式索引
    
    // 可选择的模式列表（不包括home）
    private let selectableModes: [CalculatorMode] = [.calc, .stat, .table, .equation, .inequality, .complex, .base, .matrix, .vector, .ratio]
    
    // 定时器用于光标闪烁
    let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 0) {
            // LCD屏幕
            screenView
            
            // 固定键盘
            keyboardView
        }
        .background(Color.black)
        .onReceive(timer) { _ in
            showCursor.toggle()
        }
    }
    
    // MARK: - 屏幕视图
    private var screenView: some View {
        VStack(spacing: 0) {
            // 状态栏
            statusBar
            
            // 主显示区域
            displayArea
        }
        .frame(height: 200)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.green.opacity(0.8), Color.green.opacity(0.6)]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray, lineWidth: 2)
        )
        .padding(.horizontal, 10)
        .padding(.top, 10)
    }
    
    // 状态栏
    private var statusBar: some View {
        HStack {
            // 内存指示器
            Text(memory != 0 ? "M" : " ")
                .font(.system(size: 12, family: .monospaced))
                .foregroundColor(.black)
            
            Spacer()
            
            // SHIFT指示器
            Text(isShiftActive ? "SHIFT" : "     ")
                .font(.system(size: 12, family: .monospaced))
                .foregroundColor(.black)
            
            Spacer()
            
            // 模式图标
            Text(currentMode.rawValue)
                .font(.system(size: 16))
            
            Spacer()
            
            // 角度模式
            Text("DEG")
                .font(.system(size: 12, family: .monospaced))
                .foregroundColor(.black)
        }
        .padding(.horizontal, 15)
        .padding(.top, 8)
    }
    
    // 显示区域
    private var displayArea: some View {
        VStack(alignment: .leading, spacing: 5) {
            if currentMode == .home {
                homeScreenContent
            } else {
                calculatorContent
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(.horizontal, 15)
        .padding(.bottom, 10)
    }
    
    // 主屏幕内容
    private var homeScreenContent: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("选择功能模式")
                .font(.system(size: 14, family: .monospaced))
                .foregroundColor(.black)
                .padding(.bottom, 5)
            
            // 使用网格布局显示模式选项
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                ForEach(Array(selectableModes.enumerated()), id: \.offset) { index, mode in
                    HStack(spacing: 8) {
                        Text(mode.rawValue)
                            .font(.system(size: 16))
                            .foregroundColor(mode.color)
                        
                        Text(mode.title)
                            .font(.system(size: 12, family: .monospaced))
                            .foregroundColor(.black)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(index == selectedModeIndex ? Color.black.opacity(0.2) : Color.clear)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(index == selectedModeIndex ? Color.black : Color.clear, lineWidth: 1)
                    )
                }
            }
            
            Spacer()
            
            Text("使用方向键选择，按=确认")
                .font(.system(size: 10, family: .monospaced))
                .foregroundColor(.black.opacity(0.7))
        }
    }
    
    // 计算器内容
    private var calculatorContent: some View {
        VStack(alignment: .trailing, spacing: 5) {
            // 表达式显示
            if !expression.isEmpty {
                Text(expression)
                    .font(.system(size: 14, family: .monospaced))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            
            // 主显示
            HStack {
                Text(displayWithCursor)
                    .font(.system(size: 18, family: .monospaced, weight: .medium))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
    }
    
    // 带光标的显示文本
    private var displayWithCursor: String {
        if isEditingFraction, let fraction = currentFraction {
            return fraction.display + (showCursor ? "|" : " ")
        } else {
            return display + (showCursor ? "|" : " ")
        }
    }
    
    // MARK: - 键盘视图
    private var keyboardView: some View {
        VStack(spacing: 8) {
            // 第一行：SHIFT和空位
            HStack(spacing: 8) {
                calculatorButton("", type: .special(""))
                calculatorButton("", type: .special(""))
                calculatorButton("", type: .special(""))
                calculatorButton("", type: .special(""))
                calculatorButton("SHIFT", type: .special("SHIFT"))
            }
            
            // 第二行：三角函数和除法
            HStack(spacing: 8) {
                calculatorButton(isShiftActive ? "sin⁻¹" : "sin", type: .function("sin"))
                calculatorButton(isShiftActive ? "cos⁻¹" : "cos", type: .function("cos"))
                calculatorButton(isShiftActive ? "tan⁻¹" : "tan", type: .function("tan"))
                calculatorButton("÷", type: .operation("÷"))
                calculatorButton("MODE", type: .navigation("MODE"))
            }
            
            // 第三行：对数和乘法
            HStack(spacing: 8) {
                calculatorButton(isShiftActive ? "10ˣ" : "log", type: .function("log"))
                calculatorButton(isShiftActive ? "eˣ" : "ln", type: .function("ln"))
                calculatorButton(isShiftActive ? "√x" : "x²", type: .function("square"))
                calculatorButton("×", type: .operation("×"))
                calculatorButton("OPTN", type: .navigation("OPTN"))
            }
            
            // 第四行：幂函数和减法
            HStack(spacing: 8) {
                calculatorButton(isShiftActive ? "x³" : "√", type: .function("root"))
                calculatorButton(isShiftActive ? "x!" : "1/x", type: .function("reciprocal"))
                calculatorButton("%", type: .function("%"))
                calculatorButton("-", type: .operation("-"))
                calculatorButton("SETUP", type: .navigation("SETUP"))
            }
            
            // 第五行：数字7-9和加法、上方向键
            HStack(spacing: 8) {
                calculatorButton("7", type: .number(7))
                calculatorButton("8", type: .number(8))
                calculatorButton("9", type: .number(9))
                calculatorButton("+", type: .operation("+"))
                calculatorButton("▲", type: .navigation("▲"))
            }
            
            // 第六行：数字4-6和等号、左右方向键
            HStack(spacing: 8) {
                calculatorButton("4", type: .number(4))
                calculatorButton("5", type: .number(5))
                calculatorButton("6", type: .number(6))
                calculatorButton("=", type: .operation("="))
                HStack(spacing: 4) {
                    calculatorButton("◀", type: .navigation("◀"))
                    calculatorButton("▶", type: .navigation("▶"))
                }
            }
            
            // 第七行：数字1-3、空白键和EXIT
            HStack(spacing: 8) {
                calculatorButton("1", type: .number(1))
                calculatorButton("2", type: .number(2))
                calculatorButton("3", type: .number(3))
                calculatorButton("□/□", type: .special("□/□"))
                calculatorButton("EXIT", type: .navigation("EXIT"))
            }
            
            // 第八行：0、小数点、正负号、AC和下方向键
            HStack(spacing: 8) {
                calculatorButton("0", type: .number(0))
                calculatorButton(".", type: .special("."))
                calculatorButton("+/-", type: .special("+/-"))
                calculatorButton("AC", type: .special("AC"))
                calculatorButton("▼", type: .navigation("▼"))
            }
        }
        .padding(.horizontal, 10)
        .padding(.bottom, 20)
    }
    
    // MARK: - 按钮组件
    private func calculatorButton(_ title: String, type: ButtonType) -> some View {
        Button(action: {
            if !title.isEmpty {
                handleButtonPress(title, type: type)
            }
        }) {
            VStack(spacing: 2) {
                Text(title)
                    .font(.system(size: getButtonFontSize(title), weight: .medium))
                    .foregroundColor(getButtonTextColor(title, type: type))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            .frame(width: getButtonWidth(title), height: 45)
            .background(getButtonColor(type, title: title))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(title.isEmpty)
    }
    
    // 获取按钮宽度
    private func getButtonWidth(_ title: String) -> CGFloat {
        if title == "◀" || title == "▶" {
            return 35
        }
        return 65
    }
    
    // 获取按钮字体大小
    private func getButtonFontSize(_ title: String) -> CGFloat {
        if title.count > 4 {
            return 10
        } else if title.count > 2 {
            return 12
        }
        return 16
    }
    
    // 获取按钮文字颜色
    private func getButtonTextColor(_ title: String, type: ButtonType) -> Color {
        if title.isEmpty {
            return .clear
        }
        
        switch type {
        case .number(_):
            return .white
        case .operation(_):
            return .white
        case .function(_):
            if isShiftActive && (title.contains("⁻¹") || title.contains("ˣ") || title.contains("³") || title.contains("!")) {
                return .yellow
            }
            return .white
        case .navigation(_):
            return .white
        case .special(_):
            return .white
        }
    }
    
    // 获取按钮背景颜色
    private func getButtonColor(_ type: ButtonType, title: String) -> Color {
        if title.isEmpty {
            return Color.clear
        }
        
        switch type {
        case .number(_):
            return Color.gray.opacity(0.8)
        case .operation(_):
            return Color.orange.opacity(0.8)
        case .function(_):
            return Color.blue.opacity(0.8)
        case .navigation(_):
            return Color.green.opacity(0.8)
        case .special(_):
            return Color.red.opacity(0.8)
        }
    }
    
    // MARK: - 按钮处理逻辑
    private func handleButtonPress(_ title: String, type: ButtonType) {
        switch type {
        case .number(let num):
            handleNumberInput(num)
        case .operation(let op):
            handleOperation(op)
        case .function(let func):
            handleFunction(func)
        case .navigation(let nav):
            handleNavigation(nav)
        case .special(let special):
            handleSpecial(special)
        }
    }
    
    // 处理数字输入
    private func handleNumberInput(_ number: Int) {
        if currentMode == .home {
            return // 在主屏幕中数字键不再用于选择模式
        } else if isEditingFraction, var fraction = currentFraction {
            // 编辑分数
            if fraction.isEditingNumerator {
                fraction.numerator += String(number)
            } else {
                fraction.denominator += String(number)
            }
            currentFraction = fraction
        } else {
            // 正常数字输入
            if display == "0" {
                display = String(number)
            } else {
                display += String(number)
            }
        }
    }
    
    // 处理运算符
    private func handleOperation(_ operation: String) {
        if currentMode == .home && operation == "=" {
            // 在主屏幕中按=键确认选择
            currentMode = selectableModes[selectedModeIndex]
            display = "0"
            expression = ""
            isEditingFraction = false
            currentFraction = nil
            return
        }
        
        switch operation {
        case "+", "-", "×", "÷":
            if isEditingFraction, let fraction = currentFraction, let value = fraction.value {
                display = String(value)
                isEditingFraction = false
                currentFraction = nil
            }
            expression = display + " " + operation + " "
            display = "0"
        case "=":
            calculateResult()
        default:
            break
        }
    }
    
    // 处理函数
    private func handleFunction(_ function: String) {
        guard let value = Double(display) else { return }
        
        var result: Double = 0
        
        switch function {
        case "sin":
            result = isShiftActive ? asin(value) * 180 / .pi : sin(value * .pi / 180)
        case "cos":
            result = isShiftActive ? acos(value) * 180 / .pi : cos(value * .pi / 180)
        case "tan":
            result = isShiftActive ? atan(value) * 180 / .pi : tan(value * .pi / 180)
        case "log":
            result = isShiftActive ? pow(10, value) : log10(value)
        case "ln":
            result = isShiftActive ? exp(value) : log(value)
        case "square":
            result = isShiftActive ? sqrt(value) : value * value
        case "root":
            result = isShiftActive ? value * value * value : sqrt(value)
        case "reciprocal":
            if isShiftActive {
                // 阶乘
                result = factorial(Int(value))
            } else {
                result = 1.0 / value
            }
        case "%":
            result = value / 100
        default:
            return
        }
        
        display = formatResult(result)
        isShiftActive = false
    }
    
    // 阶乘计算
    private func factorial(_ n: Int) -> Double {
        if n <= 1 { return 1 }
        return Double(n) * factorial(n - 1)
    }
    
    // 处理导航
    private func handleNavigation(_ navigation: String) {
        switch navigation {
        case "MODE":
            currentMode = .home
            selectedModeIndex = 0
            display = "0"
            expression = ""
            isEditingFraction = false
            currentFraction = nil
        case "EXIT":
            currentMode = .home
            selectedModeIndex = 0
            display = "0"
            expression = ""
            isEditingFraction = false
            currentFraction = nil
        case "▲":
            if currentMode == .home {
                selectedModeIndex = max(0, selectedModeIndex - 2)
            } else if isEditingFraction, var fraction = currentFraction {
                fraction.isEditingNumerator = true
                currentFraction = fraction
            }
        case "▼":
            if currentMode == .home {
                selectedModeIndex = min(selectableModes.count - 1, selectedModeIndex + 2)
            } else if isEditingFraction, var fraction = currentFraction {
                fraction.isEditingNumerator = false
                currentFraction = fraction
            }
        case "◀":
            if currentMode == .home {
                selectedModeIndex = max(0, selectedModeIndex - 1)
            } else if isEditingFraction, var fraction = currentFraction {
                fraction.isEditingNumerator = true
                currentFraction = fraction
            }
        case "▶":
            if currentMode == .home {
                selectedModeIndex = min(selectableModes.count - 1, selectedModeIndex + 1)
            } else if isEditingFraction, var fraction = currentFraction {
                fraction.isEditingNumerator = false
                currentFraction = fraction
            }
        default:
            break
        }
    }
    
    // 处理特殊按键
    private func handleSpecial(_ special: String) {
        switch special {
        case "SHIFT":
            isShiftActive.toggle()
        case "AC":
            display = "0"
            expression = ""
            isEditingFraction = false
            currentFraction = nil
        case ".":
            if !display.contains(".") {
                display += "."
            }
        case "+/-":
            if let value = Double(display) {
                display = String(-value)
            }
        case "□/□":
            currentFraction = Fraction()
            isEditingFraction = true
        default:
            break
        }
    }
    
    // 计算结果
    private func calculateResult() {
        let fullExpression = expression + display
        
        // 简单的表达式计算
        let components = fullExpression.components(separatedBy: " ")
        if components.count >= 3 {
            guard let left = Double(components[0]),
                  let right = Double(components[2]) else { return }
            
            let operation = components[1]
            var result: Double = 0
            
            switch operation {
            case "+":
                result = left + right
            case "-":
                result = left - right
            case "×":
                result = left * right
            case "÷":
                if right != 0 {
                    result = left / right
                } else {
                    display = "Error"
                    return
                }
            default:
                return
            }
            
            display = formatResult(result)
            expression = ""
        }
    }
    
    // 格式化结果
    private func formatResult(_ result: Double) -> String {
        if result.truncatingRemainder(dividingBy: 1) == 0 {
            return String(Int(result))
        } else {
            return String(format: "%.8g", result)
        }
    }
}

#Preview {
    ContentView()
}