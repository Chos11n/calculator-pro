//
//  ContentView.swift
//  calculator pro+
//
//  Created by Li on 2025/6/18.
//

import SwiftUI

struct ContentView: View {
    @State private var currentView: CalculatorView = .calculation
    @State private var isShiftPressed = false
    @State private var displayValue = "0"
    @State private var currentExpression = "0"
    @State private var cursorPosition = 0
    @State private var memoryValue = 0.0
    @State private var isMemoryActive = false
    @State private var showCursor = true
    @State private var isInFractionMode = false
    @State private var fractionCursorPosition = 0 // 0: numerator, 1: denominator
    @State private var cursorOpacity: Double = 1.0 // 光标透明度
    @State private var lastAnswer: String = "" // 存储上一次的答案
    @State private var showAnswer: Bool = false // 是否显示答案
    @State private var ansValue: Double = 0.0 // ANS数值变量
    @State private var displayFormat: DisplayFormat = .standard // 显示格式
    @State private var showFormatOptions: Bool = false // 是否显示格式选项
    @State private var showSettings: Bool = false // 是否显示设置
    @State private var currentSettingTab: SettingTab = .calculation // 当前设置标签页
    
    enum CalculatorView {
        case main, calculation, statistics, function, equation, inequality, complex, base, matrix, vector, ratio
    }
    
    enum DisplayFormat {
        case standard, decimal, improperFraction, mixedFraction, engineering, sexagesimal
    }
    
    enum SettingTab {
        case calculation, system, reset
    }
    
    enum Operation {
        case add, subtract, multiply, divide, power, sqrt, sin, cos, tan, log, ln
    }
    
    var body: some View {
        ZStack {
            // 背景色 - 模拟计算器外壳
            Color(red: 0.2, green: 0.2, blue: 0.2)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 计算器屏幕区域
                VStack(spacing: 0) {
                    // 屏幕边框
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.black)
                        .frame(height: 120)
                        .overlay(
                            VStack(alignment: .trailing, spacing: 5) {
                                // 状态指示器和模式图标
                                HStack {
                                    if isMemoryActive {
                                        Text("M")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(.green)
                                    }
                                    if isShiftPressed {
                                        Text("SHIFT")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(.yellow)
                                    }
                                    Spacer()
                                    // 模式图标
                                    modeIcon
                                    Text("DEG")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.gray)
                                }
                                .padding(.horizontal, 15)
                                .padding(.top, 10)
                                
                                // 主要显示内容
                                if currentView == .main {
                                    mainScreenDisplay
                                } else {
                                    calculationView
                                }
                                
                                Spacer()
                                
                                // 答案显示在右下角
                                if showAnswer && !lastAnswer.isEmpty {
                                    HStack {
                                        Spacer()
                                        Text(lastAnswer)
                                            .font(.system(size: 14, weight: .medium, design: .monospaced))
                                            .foregroundColor(.green)
                                            .padding(.horizontal, 15)
                                            .padding(.bottom, 10)
                                    }
                                }
                                
                                // 格式选项显示
                                if showFormatOptions {
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text("选择显示格式:")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(.yellow)
                                        
                                        HStack(spacing: 8) {
                                            FormatOptionButton(title: "标准", isSelected: displayFormat == .standard) {
                                                displayFormat = .standard
                                                showFormatOptions = false
                                            }
                                            FormatOptionButton(title: "小数", isSelected: displayFormat == .decimal) {
                                                displayFormat = .decimal
                                                showFormatOptions = false
                                            }
                                            FormatOptionButton(title: "假分数", isSelected: displayFormat == .improperFraction) {
                                                displayFormat = .improperFraction
                                                showFormatOptions = false
                                            }
                                        }
                                        
                                        HStack(spacing: 8) {
                                            FormatOptionButton(title: "带分数", isSelected: displayFormat == .mixedFraction) {
                                                displayFormat = .mixedFraction
                                                showFormatOptions = false
                                            }
                                            FormatOptionButton(title: "工程", isSelected: displayFormat == .engineering) {
                                                displayFormat = .engineering
                                                showFormatOptions = false
                                            }
                                            FormatOptionButton(title: "60进制", isSelected: displayFormat == .sexagesimal) {
                                                displayFormat = .sexagesimal
                                                showFormatOptions = false
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 15)
                                    .padding(.bottom, 5)
                                }
                                
                                // 设置显示
                                if showSettings {
                                    settingsView
                                        .padding(.horizontal, 15)
                                        .padding(.bottom, 5)
                                }
                            }
                        )
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                }
                
                // 固定键盘布局
                fixedKeyboardLayout
            }
        }
        .onAppear {
            // 启动光标闪烁动画
            startCursorBlink()
        }
    }
    
    // MARK: - 光标闪烁动画
    private func startCursorBlink() {
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.1)) {
                showCursor.toggle()
                cursorOpacity = showCursor ? 1.0 : 0.0
            }
        }
    }
    
    private func stopCursorBlink() {
        // 停止光标闪烁
        showCursor = false
        cursorOpacity = 0.0
    }
    
    // MARK: - 模式图标
    var modeIcon: some View {
        Group {
            switch currentView {
            case .calculation:
                Image(systemName: "plus.forwardslash.minus")
                    .foregroundColor(.blue)
            case .statistics:
                Image(systemName: "chart.bar")
                    .foregroundColor(.purple)
            case .function:
                Image(systemName: "function")
                    .foregroundColor(.green)
            case .equation:
                Image(systemName: "equal.circle")
                    .foregroundColor(.orange)
            case .inequality:
                Image(systemName: "greaterthan.circle")
                    .foregroundColor(.red)
            case .complex:
                Image(systemName: "number.circle")
                    .foregroundColor(.cyan)
            case .base:
                Image(systemName: "binary")
                    .foregroundColor(.pink)
            case .matrix:
                Image(systemName: "grid")
                    .foregroundColor(.indigo)
            case .vector:
                Image(systemName: "arrow.up.right")
                    .foregroundColor(.mint)
            case .ratio:
                Image(systemName: "percent")
                    .foregroundColor(.brown)
            case .main:
                Image(systemName: "house")
                    .foregroundColor(.white)
            }
        }
        .font(.system(size: 16, weight: .medium))
    }
    
    // MARK: - 主屏幕显示
    var mainScreenDisplay: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("选择功能模式")
                .font(.system(size: 18, weight: .medium, design: .monospaced))
                .foregroundColor(.green)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("1. 计算 (CALC)")
                    .font(.system(size: 14, weight: .light, design: .monospaced))
                    .foregroundColor(.gray)
                Text("2. 统计 (STAT)")
                    .font(.system(size: 14, weight: .light, design: .monospaced))
                    .foregroundColor(.gray)
                Text("3. 函数表格 (TABLE)")
                    .font(.system(size: 14, weight: .light, design: .monospaced))
                    .foregroundColor(.gray)
                Text("4. 方程 (EQN)")
                    .font(.system(size: 14, weight: .light, design: .monospaced))
                    .foregroundColor(.gray)
                Text("5. 不等式 (INEQ)")
                    .font(.system(size: 14, weight: .light, design: .monospaced))
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 15)
    }
    
    // MARK: - 计算屏幕
    var calculationView: some View {
        VStack(alignment: .leading, spacing: 5) {
            if isInFractionMode {
                // 分数模式显示
                HStack(spacing: 0) {
                    ForEach(Array(currentExpression.enumerated()), id: \.offset) { index, character in
                        if index == cursorPosition {
                            Rectangle()
                                .fill(Color.white)
                                .frame(width: 2, height: 20)
                                .opacity(cursorOpacity)
                        }
                        
                        if character == "□" {
                            Rectangle()
                                .stroke(Color.white, lineWidth: 1)
                                .frame(width: 20, height: 20)
                                .background(Color.clear)
                        } else if character == "ⁿ" {
                            Text("ⁿ")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.yellow)
                        } else {
                            Text(String(character))
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.white)
                        }
                    }
                    
                    if cursorPosition == currentExpression.count {
                        Rectangle()
                            .fill(Color.white)
                            .frame(width: 2, height: 20)
                            .opacity(cursorOpacity)
                    }
                }
            } else {
                // 普通模式显示
                cursorView(for: currentExpression)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 15)
    }
    
    // MARK: - 光标导航功能
    private func navigateUp() {
        if currentView == .main {
            // 在主屏幕中向上选择
            displayValue = "向上选择"
        } else {
            // 在表达式中向上移动光标
            if isInFractionMode {
                fractionCursorPosition = 0
            } else {
                // 在普通表达式中，向上可以移动到分数位置
                if currentExpression.contains("□/□") {
                    isInFractionMode = true
                    fractionCursorPosition = 0
                }
            }
        }
    }
    
    private func navigateDown() {
        if currentView == .main {
            // 在主屏幕中向下选择
            displayValue = "向下选择"
        } else {
            // 在表达式中向下移动光标
            if isInFractionMode {
                fractionCursorPosition = 1
            } else {
                // 在普通表达式中，向下可以移动到分数位置
                if currentExpression.contains("□/□") {
                    isInFractionMode = true
                    fractionCursorPosition = 1
                }
            }
        }
    }
    
    private func navigateLeft() {
        if currentView != .main {
            if isInFractionMode {
                fractionCursorPosition = 0
            } else {
                // 在普通表达式中向左移动光标
                cursorPosition = max(0, cursorPosition - 1)
            }
        }
    }
    
    private func navigateRight() {
        if currentView != .main {
            if isInFractionMode {
                fractionCursorPosition = 1
            } else {
                // 在普通表达式中向右移动光标
                cursorPosition = min(currentExpression.count, cursorPosition + 1)
            }
        }
    }
    
    // MARK: - 插入功能
    private func insertNumber(_ number: String) {
        if currentView == .main {
            // 在主屏幕中，数字键用于选择模式
            switch number {
            case "1": currentView = .calculation
            case "2": currentView = .statistics
            case "3": currentView = .function
            case "4": currentView = .equation
            case "5": currentView = .inequality
            default: break
            }
        } else {
            // 如果当前显示答案，清空屏幕并开始新的输入
            if showAnswer {
                currentExpression = number
                cursorPosition = 1
                showAnswer = false
                return
            }
            
            if isInFractionMode {
                // 在分数模式下填充空白
                if currentExpression.contains("□/□") {
                    if fractionCursorPosition == 0 {
                        // 填充分子
                        currentExpression = currentExpression.replacingOccurrences(of: "□/□", with: "\(number)/□")
                    } else {
                        // 填充分母
                        currentExpression = currentExpression.replacingOccurrences(of: "□/□", with: "□/\(number)")
                    }
                } else {
                    // 如果已经有部分填充，继续填充
                    if fractionCursorPosition == 0 {
                        if currentExpression.contains("/□") {
                            currentExpression = currentExpression.replacingOccurrences(of: "/□", with: "/\(number)")
                        } else {
                            // 在分子位置插入数字
                            let parts = currentExpression.components(separatedBy: "/")
                            if parts.count == 2 {
                                let numerator = parts[0] + number
                                let denominator = parts[1]
                                currentExpression = "\(numerator)/\(denominator)"
                            }
                        }
                    } else {
                        if currentExpression.contains("□/") {
                            currentExpression = currentExpression.replacingOccurrences(of: "□/", with: "\(number)/")
                        } else {
                            // 在分母位置插入数字
                            let parts = currentExpression.components(separatedBy: "/")
                            if parts.count == 2 {
                                let numerator = parts[0]
                                let denominator = parts[1] + number
                                currentExpression = "\(numerator)/\(denominator)"
                            }
                        }
                    }
                }
            } else {
                // 检查是否有其他空白需要填充
                if currentExpression.contains("√□") {
                    // 填充根号内的空白
                    currentExpression = currentExpression.replacingOccurrences(of: "√□", with: "√\(number)")
                    cursorPosition += 1
                } else if currentExpression.contains("□²") {
                    // 填充平方前的空白
                    currentExpression = currentExpression.replacingOccurrences(of: "□²", with: "\(number)²")
                    cursorPosition += 1
                } else if currentExpression.contains("log□") {
                    // 填充log后的空白
                    currentExpression = currentExpression.replacingOccurrences(of: "log□", with: "log\(number)")
                    cursorPosition += 1
                } else if currentExpression.contains("×10ⁿ") {
                    // 填充×10ⁿ中的空白
                    currentExpression = currentExpression.replacingOccurrences(of: "×10ⁿ", with: "×10^\(number)")
                    cursorPosition += 1
                } else if currentExpression.contains("sin()") {
                    // 填充sin函数的空白
                    currentExpression = currentExpression.replacingOccurrences(of: "sin()", with: "sin(\(number))")
                    cursorPosition += 1
                } else if currentExpression.contains("cos()") {
                    // 填充cos函数的空白
                    currentExpression = currentExpression.replacingOccurrences(of: "cos()", with: "cos(\(number))")
                    cursorPosition += 1
                } else if currentExpression.contains("tan()") {
                    // 填充tan函数的空白
                    currentExpression = currentExpression.replacingOccurrences(of: "tan()", with: "tan(\(number))")
                    cursorPosition += 1
                } else if currentExpression.contains("sin⁻¹()") {
                    // 填充sin⁻¹函数的空白
                    currentExpression = currentExpression.replacingOccurrences(of: "sin⁻¹()", with: "sin⁻¹(\(number))")
                    cursorPosition += 1
                } else if currentExpression.contains("cos⁻¹()") {
                    // 填充cos⁻¹函数的空白
                    currentExpression = currentExpression.replacingOccurrences(of: "cos⁻¹()", with: "cos⁻¹(\(number))")
                    cursorPosition += 1
                } else if currentExpression.contains("tan⁻¹()") {
                    // 填充tan⁻¹函数的空白
                    currentExpression = currentExpression.replacingOccurrences(of: "tan⁻¹()", with: "tan⁻¹(\(number))")
                    cursorPosition += 1
                } else {
                    // 正常模式插入数字
                    if currentExpression == "0" {
                        // 如果当前是0，直接替换
                        currentExpression = number
                        cursorPosition = 1
                    } else {
                        // 在光标位置插入数字
                        let index = currentExpression.index(currentExpression.startIndex, offsetBy: cursorPosition)
                        currentExpression.insert(contentsOf: number, at: index)
                        cursorPosition += 1
                    }
                }
            }
        }
    }
    
    private func insertDecimal() {
        if currentView == .calculation {
            // 如果当前显示答案，清空屏幕并开始新的输入
            if showAnswer {
                currentExpression = "0."
                cursorPosition = 2
                showAnswer = false
                return
            }
            
            if isInFractionMode {
                // 在分数模式下填充空白
                if currentExpression.contains("□/□") {
                    if fractionCursorPosition == 0 {
                        // 填充分子
                        currentExpression = currentExpression.replacingOccurrences(of: "□/□", with: "0./□")
                    } else {
                        // 填充分母
                        currentExpression = currentExpression.replacingOccurrences(of: "□/□", with: "□/0.")
                    }
                } else {
                    // 如果已经有部分填充，继续填充
                    if fractionCursorPosition == 0 {
                        if currentExpression.contains("/□") {
                            currentExpression = currentExpression.replacingOccurrences(of: "/□", with: "/0.")
                        } else {
                            // 在分子位置插入小数点
                            let parts = currentExpression.components(separatedBy: "/")
                            if parts.count == 2 {
                                let numerator = parts[0] + "."
                                let denominator = parts[1]
                                currentExpression = "\(numerator)/\(denominator)"
                            }
                        }
                    } else {
                        if currentExpression.contains("□/") {
                            currentExpression = currentExpression.replacingOccurrences(of: "□/", with: "0./")
                        } else {
                            // 在分母位置插入小数点
                            let parts = currentExpression.components(separatedBy: "/")
                            if parts.count == 2 {
                                let numerator = parts[0]
                                let denominator = parts[1] + "."
                                currentExpression = "\(numerator)/\(denominator)"
                            }
                        }
                    }
                }
            } else {
                // 检查是否有其他空白需要填充
                if currentExpression.contains("√□") {
                    // 填充根号内的空白
                    currentExpression = currentExpression.replacingOccurrences(of: "√□", with: "√0.")
                    cursorPosition += 2
                } else if currentExpression.contains("□²") {
                    // 填充平方前的空白
                    currentExpression = currentExpression.replacingOccurrences(of: "□²", with: "0.²")
                    cursorPosition += 2
                } else if currentExpression.contains("log□") {
                    // 填充log后的空白
                    currentExpression = currentExpression.replacingOccurrences(of: "log□", with: "log0.")
                    cursorPosition += 2
                } else if currentExpression.contains("×10ⁿ") {
                    // 填充×10ⁿ中的空白
                    currentExpression = currentExpression.replacingOccurrences(of: "×10ⁿ", with: "×10^0.")
                    cursorPosition += 2
                } else if currentExpression.contains("sin()") {
                    // 填充sin函数的空白
                    currentExpression = currentExpression.replacingOccurrences(of: "sin()", with: "sin(0.)")
                    cursorPosition += 2
                } else if currentExpression.contains("cos()") {
                    // 填充cos函数的空白
                    currentExpression = currentExpression.replacingOccurrences(of: "cos()", with: "cos(0.)")
                    cursorPosition += 2
                } else if currentExpression.contains("tan()") {
                    // 填充tan函数的空白
                    currentExpression = currentExpression.replacingOccurrences(of: "tan()", with: "tan(0.)")
                    cursorPosition += 2
                } else if currentExpression.contains("sin⁻¹()") {
                    // 填充sin⁻¹函数的空白
                    currentExpression = currentExpression.replacingOccurrences(of: "sin⁻¹()", with: "sin⁻¹(0.)")
                    cursorPosition += 2
                } else if currentExpression.contains("cos⁻¹()") {
                    // 填充cos⁻¹函数的空白
                    currentExpression = currentExpression.replacingOccurrences(of: "cos⁻¹()", with: "cos⁻¹(0.)")
                    cursorPosition += 2
                } else if currentExpression.contains("tan⁻¹()") {
                    // 填充tan⁻¹函数的空白
                    currentExpression = currentExpression.replacingOccurrences(of: "tan⁻¹()", with: "tan⁻¹(0.)")
                    cursorPosition += 2
                } else if currentExpression.contains("ans□") {
                    // 填充ans后的空白
                    currentExpression = currentExpression.replacingOccurrences(of: "ans□", with: "ans0.")
                    cursorPosition += 2
                } else {
                    // 正常模式插入小数点
                    if currentExpression == "0" {
                        // 如果当前是0，直接替换为0.
                        currentExpression = "0."
                        cursorPosition = 2
                    } else {
                        // 在光标位置插入小数点
                        let index = currentExpression.index(currentExpression.startIndex, offsetBy: cursorPosition)
                        currentExpression.insert(".", at: index)
                        cursorPosition += 1
                    }
                }
            }
        }
    }
    
    private func insertOperator(_ operator: String) {
        if currentView != .main {
            if isInFractionMode {
                // 在分数模式下，先退出分数模式
                isInFractionMode = false
            }
            
            // 插入运算符
            if currentExpression == "0" {
                // 如果当前是0，直接替换为运算符
                currentExpression = " \(`operator`) "
                cursorPosition = 3
            } else {
                // 在光标位置插入运算符
                let index = currentExpression.index(currentExpression.startIndex, offsetBy: cursorPosition)
                currentExpression.insert(contentsOf: " \(`operator`) ", at: index)
                cursorPosition += 3 // 运算符 + 两个空格
            }
        }
    }
    
    private func insertFunction(_ function: String) {
        if currentView != .main {
            if isInFractionMode {
                // 在分数模式下，先退出分数模式
                isInFractionMode = false
            }
            
            // 插入函数
            if currentExpression == "0" {
                // 如果当前是0，直接替换为函数
                currentExpression = "\(function)()"
                cursorPosition = function.count + 1
            } else {
                // 在光标位置插入函数
                let index = currentExpression.index(currentExpression.startIndex, offsetBy: cursorPosition)
                currentExpression.insert(contentsOf: "\(function)()", at: index)
                cursorPosition += function.count + 1 // 函数名 + 左括号
            }
        }
    }
    
    private func insertBlankFraction() {
        if currentView == .calculation {
            if isInFractionMode {
                // 如果已经在分数模式，切换光标位置
                fractionCursorPosition = (fractionCursorPosition + 1) % 2
            } else {
                // 插入空白分数
                if currentExpression == "0" {
                    // 如果当前是0，直接替换为空白分数
                    currentExpression = "□/□"
                    cursorPosition = 3
                    isInFractionMode = true
                    fractionCursorPosition = 0
                } else {
                    // 在光标位置插入空白分数
                    let index = currentExpression.index(currentExpression.startIndex, offsetBy: cursorPosition)
                    currentExpression.insert(contentsOf: "□/□", at: index)
                    cursorPosition += 3
                    isInFractionMode = true
                    fractionCursorPosition = 0
                }
            }
        }
    }
    
    // MARK: - 新的空白输入功能
    private func insertSqrtBlank() {
        if currentView == .calculation {
            if currentExpression == "0" {
                // 如果当前是0，直接替换为空白根号
                currentExpression = "√□"
                cursorPosition = 2
            } else {
                // 在光标位置插入空白根号
                let index = currentExpression.index(currentExpression.startIndex, offsetBy: cursorPosition)
                currentExpression.insert(contentsOf: "√□", at: index)
                cursorPosition += 2
            }
        }
    }
    
    private func insertSquareBlank() {
        if currentView == .calculation {
            if currentExpression == "0" {
                // 如果当前是0，直接替换为空白平方
                currentExpression = "□²"
                cursorPosition = 1
            } else {
                // 在光标位置插入空白平方
                let index = currentExpression.index(currentExpression.startIndex, offsetBy: cursorPosition)
                currentExpression.insert(contentsOf: "□²", at: index)
                cursorPosition += 1
            }
        }
    }
    
    private func insertLogBlank() {
        if currentView == .calculation {
            if currentExpression == "0" {
                // 如果当前是0，直接替换为log空白
                currentExpression = "log□"
                cursorPosition = 4
            } else {
                // 在光标位置插入log空白
                let index = currentExpression.index(currentExpression.startIndex, offsetBy: cursorPosition)
                currentExpression.insert(contentsOf: "log□", at: index)
                cursorPosition += 4
            }
        }
    }
    
    private func insertLeftBracket() {
        if currentView == .calculation {
            if currentExpression == "0" {
                // 如果当前是0，直接替换为左括号
                currentExpression = "("
                cursorPosition = 1
            } else {
                // 在光标位置插入左括号
                let index = currentExpression.index(currentExpression.startIndex, offsetBy: cursorPosition)
                currentExpression.insert("(", at: index)
                cursorPosition += 1
            }
        }
    }
    
    private func insertRightBracket() {
        if currentView == .calculation {
            if currentExpression == "0" {
                // 如果当前是0，直接替换为右括号
                currentExpression = ")"
                cursorPosition = 1
            } else {
                // 在光标位置插入右括号
                let index = currentExpression.index(currentExpression.startIndex, offsetBy: cursorPosition)
                currentExpression.insert(")", at: index)
                cursorPosition += 1
            }
        }
    }
    
    // MARK: - ×10ⁿ按钮功能
    private func insertTimes10Power() {
        if currentView == .calculation {
            if currentExpression == "0" {
                // 如果当前是0，直接替换为×10ⁿ
                currentExpression = "×10ⁿ"
                cursorPosition = 4
            } else {
                // 在光标位置插入×10ⁿ
                let index = currentExpression.index(currentExpression.startIndex, offsetBy: cursorPosition)
                currentExpression.insert(contentsOf: "×10ⁿ", at: index)
                cursorPosition += 4
            }
        }
    }
    
    // MARK: - 格式按钮功能
    private func formatButton() {
        if currentView == .calculation {
            if isShiftPressed {
                // Shift + 格式 = 插入ANS（只要ANS有值就可以使用）
                if lastAnswer != "" {
                    insertAnsText()
                }
            } else {
                // 格式按钮 = 显示格式选项（只有在有答案时才有效）
                if showAnswer && !lastAnswer.isEmpty {
                    showFormatOptions = true
                }
            }
        }
    }
    
    // MARK: - 插入ANS文本
    private func insertAnsText() {
        if currentView == .calculation {
            // 检查是否有空白需要填充
            if currentExpression.contains("□/□") {
                // 在分数空白中插入ans
                if fractionCursorPosition == 0 {
                    // 填充分子
                    currentExpression = currentExpression.replacingOccurrences(of: "□/□", with: "ans/□")
                } else {
                    // 填充分母
                    currentExpression = currentExpression.replacingOccurrences(of: "□/□", with: "□/ans")
                }
                cursorPosition += 3
            } else if currentExpression.contains("√□") {
                // 填充根号内的空白
                currentExpression = currentExpression.replacingOccurrences(of: "√□", with: "√ans")
                cursorPosition += 3
            } else if currentExpression.contains("□²") {
                // 填充平方前的空白
                currentExpression = currentExpression.replacingOccurrences(of: "□²", with: "ans²")
                cursorPosition += 3
            } else if currentExpression.contains("log□") {
                // 填充log后的空白
                currentExpression = currentExpression.replacingOccurrences(of: "log□", with: "logans")
                cursorPosition += 3
            } else if currentExpression.contains("×10ⁿ") {
                // 填充×10ⁿ中的空白
                currentExpression = currentExpression.replacingOccurrences(of: "×10ⁿ", with: "×10^ans")
                cursorPosition += 3
            } else if currentExpression.contains("sin()") {
                // 填充sin函数的空白
                currentExpression = currentExpression.replacingOccurrences(of: "sin()", with: "sin(ans)")
                cursorPosition += 3
            } else if currentExpression.contains("cos()") {
                // 填充cos函数的空白
                currentExpression = currentExpression.replacingOccurrences(of: "cos()", with: "cos(ans)")
                cursorPosition += 3
            } else if currentExpression.contains("tan()") {
                // 填充tan函数的空白
                currentExpression = currentExpression.replacingOccurrences(of: "tan()", with: "tan(ans)")
                cursorPosition += 3
            } else if currentExpression.contains("sin⁻¹()") {
                // 填充sin⁻¹函数的空白
                currentExpression = currentExpression.replacingOccurrences(of: "sin⁻¹()", with: "sin⁻¹(ans)")
                cursorPosition += 3
            } else if currentExpression.contains("cos⁻¹()") {
                // 填充cos⁻¹函数的空白
                currentExpression = currentExpression.replacingOccurrences(of: "cos⁻¹()", with: "cos⁻¹(ans)")
                cursorPosition += 3
            } else if currentExpression.contains("tan⁻¹()") {
                // 填充tan⁻¹函数的空白
                currentExpression = currentExpression.replacingOccurrences(of: "tan⁻¹()", with: "tan⁻¹(ans)")
                cursorPosition += 3
            } else {
                // 正常插入ans
                if currentExpression == "0" {
                    // 如果当前是0，直接替换为ans
                    currentExpression = "ans"
                    cursorPosition = 3
                } else {
                    // 在光标位置插入ans
                    let index = currentExpression.index(currentExpression.startIndex, offsetBy: cursorPosition)
                    currentExpression.insert(contentsOf: "ans", at: index)
                    cursorPosition += 3
                }
            }
        }
    }
    
    // MARK: - 格式化数字显示
    private func formatNumberForDisplay(_ number: Double, format: DisplayFormat) -> String {
        switch format {
        case .standard:
            return formatResult(number)
        case .decimal:
            return String(format: "%.6f", number)
        case .improperFraction:
            // 简化的假分数转换
            return "\(Int(number * 100))/100"
        case .mixedFraction:
            // 简化的带分数转换
            let whole = Int(number)
            let fraction = number - Double(whole)
            return "\(whole) \(Int(fraction * 100))/100"
        case .engineering:
            // 工程技术法
            if abs(number) >= 1000 || (abs(number) < 1 && abs(number) > 0) {
                let exponent = Int(log10(abs(number)))
                let mantissa = number / pow(10.0, Double(exponent))
                return String(format: "%.3f×10^%d", mantissa, exponent)
            } else {
                return String(format: "%.3f", number)
            }
        case .sexagesimal:
            // 60进制（度分秒）
            let degrees = Int(number)
            let minutes = Int((number - Double(degrees)) * 60)
            let seconds = Int(((number - Double(degrees)) * 60 - Double(minutes)) * 60)
            return "\(degrees)°\(minutes)'\(seconds)\""
        }
    }
    
    // MARK: - 其他功能
    private func toggleSign() {
        if currentView != .main {
            if isInFractionMode {
                // 在分数模式下切换符号
                if fractionCursorPosition == 0 {
                    // 切换分子符号
                    if currentExpression.contains("□/□") {
                        currentExpression = currentExpression.replacingOccurrences(of: "□/□", with: "-□/□")
                    } else {
                        let parts = currentExpression.components(separatedBy: "/")
                        if parts.count == 2 {
                            let numerator = parts[0].hasPrefix("-") ? String(parts[0].dropFirst()) : "-" + parts[0]
                            let denominator = parts[1]
                            currentExpression = "\(numerator)/\(denominator)"
                        }
                    }
                } else {
                    // 切换分母符号
                    if currentExpression.contains("□/□") {
                        currentExpression = currentExpression.replacingOccurrences(of: "□/□", with: "□/-□")
                    } else {
                        let parts = currentExpression.components(separatedBy: "/")
                        if parts.count == 2 {
                            let numerator = parts[0]
                            let denominator = parts[1].hasPrefix("-") ? String(parts[1].dropFirst()) : "-" + parts[1]
                            currentExpression = "\(numerator)/\(denominator)"
                        }
                    }
                }
            } else {
                // 正常模式切换符号
                if currentExpression.hasPrefix("-") {
                    currentExpression.removeFirst()
                } else {
                    currentExpression = "-" + currentExpression
                }
            }
        }
    }
    
    private func clearAll() {
        if currentView == .calculation {
            currentExpression = "0"
            cursorPosition = 0
            isInFractionMode = false
            fractionCursorPosition = 0
            showAnswer = false // 清除答案显示
            showFormatOptions = false // 清除格式选项显示
        } else if currentView == .main {
            currentView = .calculation
        }
    }
    
    // MARK: - 退回按钮功能（删除光标所在位置的内容）
    private func backspaceAtCursor() {
        if currentView == .calculation {
            if currentExpression.count > 1 {
                // 检查是否在分数模式
                if isInFractionMode && currentExpression.contains("/") {
                    let parts = currentExpression.components(separatedBy: "/")
                    if parts.count == 2 {
                        if fractionCursorPosition == 0 {
                            // 删除分子最后一个字符
                            let newNumerator = String(parts[0].dropLast())
                            if newNumerator.isEmpty || newNumerator == "□" {
                                currentExpression = "□/" + parts[1]
                            } else {
                                currentExpression = newNumerator + "/" + parts[1]
                            }
                        } else if fractionCursorPosition == 1 {
                            // 删除分母最后一个字符
                            let newDenominator = String(parts[1].dropLast())
                            if newDenominator.isEmpty || newDenominator == "□" {
                                currentExpression = parts[0] + "/□"
                            } else {
                                currentExpression = parts[0] + "/" + newDenominator
                            }
                        }
                        // 如果分子和分母都为空，恢复为□/□
                        let newParts = currentExpression.components(separatedBy: "/")
                        if newParts.count == 2 && (newParts[0] == "□" && newParts[1] == "□") {
                            currentExpression = "□/□"
                        }
                    }
                } else {
                    // 检查光标位置的特殊情况
                    if cursorPosition > 0 && cursorPosition <= currentExpression.count {
                        let beforeCursor = String(currentExpression.prefix(cursorPosition))
                        let afterCursor = String(currentExpression.suffix(from: currentExpression.index(currentExpression.startIndex, offsetBy: cursorPosition)))
                        // 检查光标前面是否有未填充的空白
                        if beforeCursor.hasSuffix("√ans") || beforeCursor.hasSuffix("√□") {
                            // 删除整个√ans或√□，恢复为√□
                            currentExpression = String(beforeCursor.dropLast(beforeCursor.hasSuffix("√ans") ? 4 : 2)) + "√□" + afterCursor
                            cursorPosition = max(0, cursorPosition - (beforeCursor.hasSuffix("√ans") ? 4 : 2) + 2)
                        } else if beforeCursor.hasSuffix("ans²") || beforeCursor.hasSuffix("□²") {
                            // 删除整个ans²或□²，恢复为□²
                            currentExpression = String(beforeCursor.dropLast(beforeCursor.hasSuffix("ans²") ? 4 : 2)) + "□²" + afterCursor
                            cursorPosition = max(0, cursorPosition - (beforeCursor.hasSuffix("ans²") ? 4 : 2) + 2)
                        } else if beforeCursor.hasSuffix("logans") || beforeCursor.hasSuffix("log□") {
                            // 删除整个logans或log□，恢复为log□
                            currentExpression = String(beforeCursor.dropLast(beforeCursor.hasSuffix("logans") ? 6 : 4)) + "log□" + afterCursor
                            cursorPosition = max(0, cursorPosition - (beforeCursor.hasSuffix("logans") ? 6 : 4) + 4)
                        } else if beforeCursor.hasSuffix("×10^ans") || beforeCursor.hasSuffix("×10ⁿ") {
                            // 删除整个×10^ans或×10ⁿ，恢复为×10ⁿ
                            currentExpression = String(beforeCursor.dropLast(beforeCursor.hasSuffix("×10^ans") ? 7 : 4)) + "×10ⁿ" + afterCursor
                            cursorPosition = max(0, cursorPosition - (beforeCursor.hasSuffix("×10^ans") ? 7 : 4) + 4)
                        } else if beforeCursor.hasSuffix("sin(ans)") || beforeCursor.hasSuffix("sin()") {
                            // 删除整个sin(ans)或sin()，恢复为sin()
                            currentExpression = String(beforeCursor.dropLast(beforeCursor.hasSuffix("sin(ans)") ? 8 : 5)) + "sin()" + afterCursor
                            cursorPosition = max(0, cursorPosition - (beforeCursor.hasSuffix("sin(ans)") ? 8 : 5) + 5)
                        } else if beforeCursor.hasSuffix("cos(ans)") || beforeCursor.hasSuffix("cos()") {
                            // 删除整个cos(ans)或cos()，恢复为cos()
                            currentExpression = String(beforeCursor.dropLast(beforeCursor.hasSuffix("cos(ans)") ? 8 : 5)) + "cos()" + afterCursor
                            cursorPosition = max(0, cursorPosition - (beforeCursor.hasSuffix("cos(ans)") ? 8 : 5) + 5)
                        } else if beforeCursor.hasSuffix("tan(ans)") || beforeCursor.hasSuffix("tan()") {
                            // 删除整个tan(ans)或tan()，恢复为tan()
                            currentExpression = String(beforeCursor.dropLast(beforeCursor.hasSuffix("tan(ans)") ? 8 : 5)) + "tan()" + afterCursor
                            cursorPosition = max(0, cursorPosition - (beforeCursor.hasSuffix("tan(ans)") ? 8 : 5) + 5)
                        } else if beforeCursor.hasSuffix("sin⁻¹(ans)") || beforeCursor.hasSuffix("sin⁻¹()") {
                            // 删除整个sin⁻¹(ans)或sin⁻¹()，恢复为sin⁻¹()
                            currentExpression = String(beforeCursor.dropLast(beforeCursor.hasSuffix("sin⁻¹(ans)") ? 11 : 8)) + "sin⁻¹()" + afterCursor
                            cursorPosition = max(0, cursorPosition - (beforeCursor.hasSuffix("sin⁻¹(ans)") ? 11 : 8) + 8)
                        } else if beforeCursor.hasSuffix("cos⁻¹(ans)") || beforeCursor.hasSuffix("cos⁻¹()") {
                            // 删除整个cos⁻¹(ans)或cos⁻¹()，恢复为cos⁻¹()
                            currentExpression = String(beforeCursor.dropLast(beforeCursor.hasSuffix("cos⁻¹(ans)") ? 11 : 8)) + "cos⁻¹()" + afterCursor
                            cursorPosition = max(0, cursorPosition - (beforeCursor.hasSuffix("cos⁻¹(ans)") ? 11 : 8) + 8)
                        } else if beforeCursor.hasSuffix("tan⁻¹(ans)") || beforeCursor.hasSuffix("tan⁻¹()") {
                            // 删除整个tan⁻¹(ans)或tan⁻¹()，恢复为tan⁻¹()
                            currentExpression = String(beforeCursor.dropLast(beforeCursor.hasSuffix("tan⁻¹(ans)") ? 11 : 8)) + "tan⁻¹()" + afterCursor
                            cursorPosition = max(0, cursorPosition - (beforeCursor.hasSuffix("tan⁻¹(ans)") ? 11 : 8) + 8)
                        } else if beforeCursor.hasSuffix("□/□") {
                            // 删除整个空白分数
                            currentExpression = String(beforeCursor.dropLast(3)) + afterCursor
                            cursorPosition = max(0, cursorPosition - 3)
                            isInFractionMode = false
                        } else {
                            // 正常删除一个字符
                            currentExpression = String(beforeCursor.dropLast()) + afterCursor
                            cursorPosition = max(0, cursorPosition - 1)
                        }
                    }
                }
            } else {
                currentExpression = "0"
                cursorPosition = 0
                isInFractionMode = false
                fractionCursorPosition = 0
            }
        }
    }
    
    private func calculate() {
        if currentView == .calculation {
            // 检查是否还有空白需要填充
            if currentExpression.contains("□") || currentExpression.contains("ⁿ") {
                // 如果有空白或未填充的幂次，不进行计算
                return
            }
            
            // 检查括号是否匹配
            let leftBrackets = currentExpression.filter { $0 == "(" }.count
            let rightBrackets = currentExpression.filter { $0 == ")" }.count
            if leftBrackets != rightBrackets {
                // 括号不匹配，不进行计算
                return
            }
            
            // 检查分数是否完整
            if currentExpression.contains("/") {
                let parts = currentExpression.components(separatedBy: "/")
                if parts.count != 2 || parts[0].isEmpty || parts[1].isEmpty {
                    // 分数不完整，不进行计算
                    return
                }
            }
            
            // 检查ANS是否可用
            if currentExpression.lowercased().contains("ans") && lastAnswer.isEmpty {
                // 如果表达式包含ans但没有ANS值，不进行计算
                return
            }
            
            // 执行计算
            do {
                let result = try evaluateExpression(currentExpression)
                
                // 存储答案到ANS变量
                ansValue = result
                lastAnswer = formatNumberForDisplay(result, format: displayFormat)
                showAnswer = true
                
                // 不清除表达式，保持原样
                // 答案会显示在右下角
            } catch {
                ansValue = 0.0
                lastAnswer = "错误"
                showAnswer = true
            }
        }
    }
    
    // MARK: - 功能键
    private func showOptions() {
        currentExpression = "选项菜单"
    }
    
    private func showSetup() {
        if currentView == .calculation {
            showSettings = true
        }
    }
    
    // MARK: - 内存功能
    private func memoryAdd() {
        if currentView != .main {
            isMemoryActive = true
        }
    }
    
    private func memorySubtract() {
        if currentView != .main {
            isMemoryActive = true
        }
    }
    
    private func memoryRecall() {
        if currentView != .main {
            currentExpression = "MR"
        }
    }
    
    private func memoryClear() {
        memoryValue = 0.0
        isMemoryActive = false
    }
    
    // MARK: - 光标显示
    private func cursorView(for expression: String) -> some View {
        HStack(spacing: 0) {
            ForEach(Array(expression.enumerated()), id: \.offset) { index, character in
                if index == cursorPosition {
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: 2, height: 20)
                        .opacity(cursorOpacity)
                }
                
                if character == "□" {
                    Rectangle()
                        .stroke(Color.white, lineWidth: 1)
                        .frame(width: 20, height: 20)
                        .background(Color.clear)
                } else if character == "ⁿ" {
                    Text("ⁿ")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.yellow)
                } else {
                    Text(String(character))
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                }
            }
            
            if cursorPosition == expression.count {
                Rectangle()
                    .fill(Color.white)
                    .frame(width: 2, height: 20)
                    .opacity(cursorOpacity)
            }
        }
    }
    
    // MARK: - 固定键盘布局
    var fixedKeyboardLayout: some View {
        VStack(spacing: 4) {
            // 第一行：M+, M-, MR, MC, SHIFT
            HStack(spacing: 4) {
                CalculatorButton(title: "M+", color: .blue, action: memoryAdd)
                CalculatorButton(title: "M-", color: .blue, action: memorySubtract)
                CalculatorButton(title: "MR", color: .blue, action: memoryRecall)
                CalculatorButton(title: "MC", color: .blue, action: memoryClear)
                CalculatorButton(title: "SHIFT", color: .yellow, action: { isShiftPressed.toggle() })
            }
            
            // 第二行：sin, cos, tan, ÷, MODE
            HStack(spacing: 4) {
                CalculatorButton(title: "sin", shiftTitle: "sin⁻¹", color: .purple, action: { insertFunction("sin") })
                CalculatorButton(title: "cos", shiftTitle: "cos⁻¹", color: .purple, action: { insertFunction("cos") })
                CalculatorButton(title: "tan", shiftTitle: "tan⁻¹", color: .purple, action: { insertFunction("tan") })
                CalculatorButton(title: "÷", color: .orange, action: { insertOperator("÷") })
                CalculatorButton(title: "MODE", color: .blue, action: { currentView = .main })
            }
            
            // 第三行：7 8 9 DEL AC
            HStack(spacing: 8) {
                CalculatorButton(title: "7", action: { insertNumber("7") })
                CalculatorButton(title: "8", action: { insertNumber("8") })
                CalculatorButton(title: "9", action: { insertNumber("9") })
                CalculatorButton(title: "=", color: .orange, action: calculate)
                CalculatorButton(title: "AC", action: clearAll)
            }
            
            // 第四行：4 5 6 ( )
            HStack(spacing: 8) {
                CalculatorButton(title: "4", action: { insertNumber("4") })
                CalculatorButton(title: "5", action: { insertNumber("5") })
                CalculatorButton(title: "6", action: { insertNumber("6") })
                CalculatorButton(title: "(", action: { insertLeftBracket() })
                CalculatorButton(title: ")", action: { insertRightBracket() })
            }
            
            // 第五行：1, 2, 3, 空白键, 退回
            HStack(spacing: 4) {
                CalculatorButton(title: "1", action: { insertNumber("1") })
                CalculatorButton(title: "2", action: { insertNumber("2") })
                CalculatorButton(title: "3", action: { insertNumber("3") })
                CalculatorButton(title: "□/□", color: .gray, action: { insertBlankFraction() })
                CalculatorButton(title: "←", color: .red, action: { backspaceAtCursor() })
            }
            
            // 第六行：0, ., +/-, AC, ×10ⁿ
            HStack(spacing: 4) {
                CalculatorButton(title: "0", isWide: true, action: { insertNumber("0") })
                CalculatorButton(title: ".", action: { insertDecimal() })
                CalculatorButton(title: "+/-", color: .orange, action: toggleSign)
                CalculatorButton(title: "AC", color: .red, action: clearAll)
                CalculatorButton(title: "×10ⁿ", color: .cyan, action: { insertTimes10Power() })
            }
            
            // 第七行：左括号, 右括号, 格式, √□, □², log□
            HStack(spacing: 4) {
                CalculatorButton(title: "(", color: .cyan, action: { insertLeftBracket() })
                CalculatorButton(title: ")", color: .cyan, action: { insertRightBracket() })
                CalculatorButton(title: "格式", shiftTitle: "ANS", color: .green, action: { formatButton() })
                CalculatorButton(title: "√□", color: .purple, action: { insertSqrtBlank() })
                CalculatorButton(title: "□²", color: .purple, action: { insertSquareBlank() })
                CalculatorButton(title: "log□", color: .purple, action: { insertLogBlank() })
            }
        }
        .padding(.horizontal, 10)
        .padding(.bottom, 10)
    }
    
    // MARK: - 表达式计算
    private func evaluateExpression(_ expression: String) throws -> Double {
        // 清理表达式，移除空格
        let cleanExpression = expression.trimmingCharacters(in: .whitespaces)
        
        // 如果是纯数字，直接返回
        if let number = Double(cleanExpression) {
            return number
        }
        
        // 如果是"ans"，返回ANS值
        if cleanExpression.lowercased() == "ans" {
            return ansValue
        }
        
        // 处理简单的数学表达式
        // 这里实现一个简化的表达式解析器
        // 支持基本的四则运算和数学函数
        
        // 移除所有空格
        let expr = cleanExpression.replacingOccurrences(of: " ", with: "")
        
        // 检查是否包含运算符或数学函数
        if expr.contains("+") || expr.contains("-") || expr.contains("×") || expr.contains("÷") || expr.contains("*") || expr.contains("/") ||
           expr.contains("√") || expr.contains("²") || expr.contains("log") || expr.contains("sin") || expr.contains("cos") || expr.contains("tan") ||
           expr.contains("×10^") {
            // 有运算符或数学函数，需要计算
            return try evaluateMathExpression(expr)
        } else {
            // 没有运算符或函数，尝试转换为数字
            if let result = Double(expr) {
                return result
            } else {
                throw NSError(domain: "Calculator", code: 1, userInfo: [NSLocalizedDescriptionKey: "无法解析表达式"])
            }
        }
    }
    
    // MARK: - 处理数字和函数的组合
    private func processNumberFunctionCombinations(_ expression: String) -> String {
        var expr = expression
        
        // 处理数字+根号（如3√3 -> 3*√3）
        let sqrtPattern = try! NSRegularExpression(pattern: "(\\d+(\\.\\d+)?)√", options: [])
        let sqrtMatches = sqrtPattern.matches(in: expr, options: [], range: NSRange(expr.startIndex..., in: expr))
        
        for match in sqrtMatches.reversed() {
            if let range = Range(match.range, in: expr) {
                let matchedText = String(expr[range])
                // 提取数字部分（去掉√）
                let numberPart = String(matchedText.dropLast())
                let replacement = numberPart + "*√"
                expr = expr.replacingCharacters(in: range, with: replacement)
            }
        }
        
        // 处理数字+log（如3log2 -> 3*log2）
        let logPattern = try! NSRegularExpression(pattern: "(\\d+(\\.\\d+)?)log", options: [])
        let logMatches = logPattern.matches(in: expr, options: [], range: NSRange(expr.startIndex..., in: expr))
        
        for match in logMatches.reversed() {
            if let range = Range(match.range, in: expr) {
                let number = String(expr[range])
                let replacement = number + "*log"
                expr = expr.replacingCharacters(in: range, with: replacement)
            }
        }
        
        // 处理数字+×10^（如3×10^2 -> 3*×10^2）
        let powerPattern = try! NSRegularExpression(pattern: "(\\d+(\\.\\d+)?)×10\\^", options: [])
        let powerMatches = powerPattern.matches(in: expr, options: [], range: NSRange(expr.startIndex..., in: expr))
        
        for match in powerMatches.reversed() {
            if let range = Range(match.range, in: expr) {
                let number = String(expr[range])
                let replacement = number + "*×10^"
                expr = expr.replacingCharacters(in: range, with: replacement)
            }
        }
        
        // 处理数字+左括号（如3(2+1) -> 3*(2+1)）
        let bracketPattern = try! NSRegularExpression(pattern: "(\\d+(\\.\\d+)?)\\(", options: [])
        let bracketMatches = bracketPattern.matches(in: expr, options: [], range: NSRange(expr.startIndex..., in: expr))
        
        for match in bracketMatches.reversed() {
            if let range = Range(match.range, in: expr) {
                let number = String(expr[range])
                let replacement = number + "*("
                expr = expr.replacingCharacters(in: range, with: replacement)
            }
        }
        
        // 处理右括号+数字（如(2+1)3 -> (2+1)*3）
        let rightBracketPattern = try! NSRegularExpression(pattern: "\\)(\\d+(\\.\\d+)?)", options: [])
        let rightBracketMatches = rightBracketPattern.matches(in: expr, options: [], range: NSRange(expr.startIndex..., in: expr))
        
        for match in rightBracketMatches.reversed() {
            if let range = Range(match.range, in: expr) {
                let number = String(expr[range])
                let replacement = ")*" + number
                expr = expr.replacingCharacters(in: range, with: replacement)
            }
        }
        
        // 处理右括号+根号（如(2+1)√3 -> (2+1)*√3）
        let rightBracketSqrtPattern = try! NSRegularExpression(pattern: "\\)√", options: [])
        let rightBracketSqrtMatches = rightBracketSqrtPattern.matches(in: expr, options: [], range: NSRange(expr.startIndex..., in: expr))
        
        for match in rightBracketSqrtMatches.reversed() {
            if let range = Range(match.range, in: expr) {
                expr = expr.replacingCharacters(in: range, with: ")*√")
            }
        }
        
        // 处理右括号+log（如(2+1)log2 -> (2+1)*log2）
        let rightBracketLogPattern = try! NSRegularExpression(pattern: "\\)log", options: [])
        let rightBracketLogMatches = rightBracketLogPattern.matches(in: expr, options: [], range: NSRange(expr.startIndex..., in: expr))
        
        for match in rightBracketLogMatches.reversed() {
            if let range = Range(match.range, in: expr) {
                expr = expr.replacingCharacters(in: range, with: ")*log")
            }
        }
        
        // 处理右括号+×10^（如(2+1)×10^2 -> (2+1)*×10^2）
        let rightBracketPowerPattern = try! NSRegularExpression(pattern: "\\)×10\\^", options: [])
        let rightBracketPowerMatches = rightBracketPowerPattern.matches(in: expr, options: [], range: NSRange(expr.startIndex..., in: expr))
        
        for match in rightBracketPowerMatches.reversed() {
            if let range = Range(match.range, in: expr) {
                expr = expr.replacingCharacters(in: range, with: ")*×10^")
            }
        }
        
        // 处理数字+²（如3² -> 3*²，但这里²是平方符号，需要特殊处理）
        // 注意：²的处理在processMathFunctions中已经完成，这里不需要额外处理
        
        // 处理右括号+²（如(2+1)² -> (2+1)*²）
        let rightBracketSquarePattern = try! NSRegularExpression(pattern: "\\)²", options: [])
        let rightBracketSquareMatches = rightBracketSquarePattern.matches(in: expr, options: [], range: NSRange(expr.startIndex..., in: expr))
        
        for match in rightBracketSquareMatches.reversed() {
            if let range = Range(match.range, in: expr) {
                expr = expr.replacingCharacters(in: range, with: ")*²")
            }
        }
        
        // 处理函数+左括号（如sin(2+1) -> sin*(2+1)，但这里sin是函数，不需要处理）
        // 注意：函数调用如sin(2+1)是标准语法，不需要添加乘号
        
        // 处理数字+函数名（如3sin -> 3*sin，但这里sin是函数，需要特殊处理）
        let functionNames = ["sin", "cos", "tan", "log", "ln"]
        for funcName in functionNames {
            let funcPattern = try! NSRegularExpression(pattern: "(\\d+(\\.\\d+)?)\(funcName)", options: [])
            let funcMatches = funcPattern.matches(in: expr, options: [], range: NSRange(expr.startIndex..., in: expr))
            
            for match in funcMatches.reversed() {
                if let range = Range(match.range, in: expr) {
                    let number = String(expr[range])
                    let replacement = number + "*" + funcName
                    expr = expr.replacingCharacters(in: range, with: replacement)
                }
            }
        }
        
        // 处理数字+反函数名（如3sin⁻¹ -> 3*sin⁻¹）
        let inverseFunctionNames = ["sin⁻¹", "cos⁻¹", "tan⁻¹"]
        for funcName in inverseFunctionNames {
            let funcPattern = try! NSRegularExpression(pattern: "(\\d+(\\.\\d+)?)\(funcName)", options: [])
            let funcMatches = funcPattern.matches(in: expr, options: [], range: NSRange(expr.startIndex..., in: expr))
            
            for match in funcMatches.reversed() {
                if let range = Range(match.range, in: expr) {
                    let number = String(expr[range])
                    let replacement = number + "*" + funcName
                    expr = expr.replacingCharacters(in: range, with: replacement)
                }
            }
        }
        
        // 处理右括号+反函数名（如(2+1)sin⁻¹ -> (2+1)*sin⁻¹）
        for funcName in inverseFunctionNames {
            let funcPattern = try! NSRegularExpression(pattern: "\\)\(funcName)", options: [])
            let funcMatches = funcPattern.matches(in: expr, options: [], range: NSRange(expr.startIndex..., in: expr))
            
            for match in funcMatches.reversed() {
                if let range = Range(match.range, in: expr) {
                    expr = expr.replacingCharacters(in: range, with: ")*" + funcName)
                }
            }
        }
        
        return expr
    }
    
    // MARK: - 处理数学函数
    private func processMathFunctions(_ expression: String) throws -> String {
        var expr = expression
        
        // 处理根号 √x
        while let sqrtRange = expr.range(of: "√") {
            let sqrtStart = sqrtRange.upperBound
            var sqrtEnd = sqrtStart
            
            // 找到根号内的数字
            while sqrtEnd < expr.endIndex {
                let char = expr[sqrtEnd]
                if char.isNumber || char == "." || char == "-" {
                    sqrtEnd = expr.index(after: sqrtEnd)
                } else {
                    break
                }
            }
            
            // 确保找到了数字
            if sqrtEnd > sqrtStart {
                let numberStr = String(expr[sqrtStart..<sqrtEnd])
                guard let number = Double(numberStr) else {
                    throw NSError(domain: "Calculator", code: 2, userInfo: [NSLocalizedDescriptionKey: "根号内数字无效"])
                }
                
                if number < 0 {
                    throw NSError(domain: "Calculator", code: 4, userInfo: [NSLocalizedDescriptionKey: "负数不能开平方根"])
                }
                
                let result = sqrt(number)
                let before = String(expr[..<sqrtRange.lowerBound])
                let after = String(expr[sqrtEnd...])
                expr = before + String(result) + after
            } else {
                // 如果没有找到数字，跳过这个根号
                break
            }
        }
        
        // 处理平方 x²
        while let squareRange = expr.range(of: "²") {
            let squareEnd = squareRange.lowerBound
            var squareStart = squareEnd
            
            // 找到平方前的数字
            while squareStart > expr.startIndex {
                let prevIndex = expr.index(before: squareStart)
                let char = expr[prevIndex]
                if char.isNumber || char == "." || char == "-" {
                    squareStart = prevIndex
                } else {
                    break
                }
            }
            
            let numberStr = String(expr[squareStart..<squareEnd])
            guard let number = Double(numberStr) else {
                throw NSError(domain: "Calculator", code: 2, userInfo: [NSLocalizedDescriptionKey: "平方前数字无效"])
            }
            
            let result = pow(number, 2)
            let before = String(expr[..<squareStart])
            let after = String(expr[squareRange.upperBound...])
            expr = before + String(result) + after
        }
        
        // 处理log函数 logx
        while let logRange = expr.range(of: "log") {
            let logStart = logRange.upperBound
            var logEnd = logStart
            
            // 找到log后的数字
            while logEnd < expr.endIndex {
                let char = expr[logEnd]
                if char.isNumber || char == "." || char == "-" {
                    logEnd = expr.index(after: logEnd)
                } else {
                    break
                }
            }
            
            let numberStr = String(expr[logStart..<logEnd])
            guard let number = Double(numberStr) else {
                throw NSError(domain: "Calculator", code: 2, userInfo: [NSLocalizedDescriptionKey: "log后数字无效"])
            }
            
            if number <= 0 {
                throw NSError(domain: "Calculator", code: 4, userInfo: [NSLocalizedDescriptionKey: "log函数定义域错误"])
            }
            
            let result = log10(number)
            let before = String(expr[..<logRange.lowerBound])
            let after = String(expr[logEnd...])
            expr = before + String(result) + after
        }
        
        // 处理×10^n
        while let powerRange = expr.range(of: "×10^") {
            let powerStart = powerRange.upperBound
            var powerEnd = powerStart
            
            // 找到指数
            while powerEnd < expr.endIndex {
                let char = expr[powerEnd]
                if char.isNumber || char == "." || char == "-" {
                    powerEnd = expr.index(after: powerEnd)
                } else {
                    break
                }
            }
            
            let exponentStr = String(expr[powerStart..<powerEnd])
            guard let exponent = Double(exponentStr) else {
                throw NSError(domain: "Calculator", code: 2, userInfo: [NSLocalizedDescriptionKey: "指数无效"])
            }
            
            let result = pow(10, exponent)
            let before = String(expr[..<powerRange.lowerBound])
            let after = String(expr[powerEnd...])
            expr = before + String(result) + after
        }
        
        // 处理三角函数 sin(x)
        while let sinRange = expr.range(of: "sin(") {
            let sinStart = sinRange.upperBound
            var bracketCount = 1
            var sinEnd = sinStart
            
            // 找到匹配的右括号
            while sinEnd < expr.endIndex && bracketCount > 0 {
                let char = expr[sinEnd]
                if char == "(" {
                    bracketCount += 1
                } else if char == ")" {
                    bracketCount -= 1
                }
                sinEnd = expr.index(after: sinEnd)
            }
            
            if bracketCount == 0 {
                let argumentStr = String(expr[sinStart..<expr.index(before: sinEnd)])
                guard let argument = Double(argumentStr) else {
                    throw NSError(domain: "Calculator", code: 2, userInfo: [NSLocalizedDescriptionKey: "sin函数参数无效"])
                }
                
                let result = sin(argument * .pi / 180) // 转换为弧度
                let before = String(expr[..<sinRange.lowerBound])
                let after = String(expr[sinEnd...])
                expr = before + String(result) + after
            }
        }
        
        // 处理三角函数 cos(x)
        while let cosRange = expr.range(of: "cos(") {
            let cosStart = cosRange.upperBound
            var bracketCount = 1
            var cosEnd = cosStart
            
            // 找到匹配的右括号
            while cosEnd < expr.endIndex && bracketCount > 0 {
                let char = expr[cosEnd]
                if char == "(" {
                    bracketCount += 1
                } else if char == ")" {
                    bracketCount -= 1
                }
                cosEnd = expr.index(after: cosEnd)
            }
            
            if bracketCount == 0 {
                let argumentStr = String(expr[cosStart..<expr.index(before: cosEnd)])
                guard let argument = Double(argumentStr) else {
                    throw NSError(domain: "Calculator", code: 2, userInfo: [NSLocalizedDescriptionKey: "cos函数参数无效"])
                }
                
                let result = cos(argument * .pi / 180) // 转换为弧度
                let before = String(expr[..<cosRange.lowerBound])
                let after = String(expr[cosEnd...])
                expr = before + String(result) + after
            }
        }
        
        // 处理三角函数 tan(x)
        while let tanRange = expr.range(of: "tan(") {
            let tanStart = tanRange.upperBound
            var bracketCount = 1
            var tanEnd = tanStart
            
            // 找到匹配的右括号
            while tanEnd < expr.endIndex && bracketCount > 0 {
                let char = expr[tanEnd]
                if char == "(" {
                    bracketCount += 1
                } else if char == ")" {
                    bracketCount -= 1
                }
                tanEnd = expr.index(after: tanEnd)
            }
            
            if bracketCount == 0 {
                let argumentStr = String(expr[tanStart..<expr.index(before: tanEnd)])
                guard let argument = Double(argumentStr) else {
                    throw NSError(domain: "Calculator", code: 2, userInfo: [NSLocalizedDescriptionKey: "tan函数参数无效"])
                }
                
                let result = tan(argument * .pi / 180) // 转换为弧度
                let before = String(expr[..<tanRange.lowerBound])
                let after = String(expr[tanEnd...])
                expr = before + String(result) + after
            }
        }
        
        // 处理反三角函数 sin⁻¹(x)
        while let asinRange = expr.range(of: "sin⁻¹(") {
            let asinStart = asinRange.upperBound
            var bracketCount = 1
            var asinEnd = asinStart
            
            // 找到匹配的右括号
            while asinEnd < expr.endIndex && bracketCount > 0 {
                let char = expr[asinEnd]
                if char == "(" {
                    bracketCount += 1
                } else if char == ")" {
                    bracketCount -= 1
                }
                asinEnd = expr.index(after: asinEnd)
            }
            
            if bracketCount == 0 {
                let argumentStr = String(expr[asinStart..<expr.index(before: asinEnd)])
                guard let argument = Double(argumentStr) else {
                    throw NSError(domain: "Calculator", code: 2, userInfo: [NSLocalizedDescriptionKey: "sin⁻¹函数参数无效"])
                }
                
                if argument < -1 || argument > 1 {
                    throw NSError(domain: "Calculator", code: 4, userInfo: [NSLocalizedDescriptionKey: "sin⁻¹函数定义域错误"])
                }
                
                let result = asin(argument) * 180 / .pi // 转换为角度
                let before = String(expr[..<asinRange.lowerBound])
                let after = String(expr[asinEnd...])
                expr = before + String(result) + after
            }
        }
        
        // 处理反三角函数 cos⁻¹(x)
        while let acosRange = expr.range(of: "cos⁻¹(") {
            let acosStart = acosRange.upperBound
            var bracketCount = 1
            var acosEnd = acosStart
            
            // 找到匹配的右括号
            while acosEnd < expr.endIndex && bracketCount > 0 {
                let char = expr[acosEnd]
                if char == "(" {
                    bracketCount += 1
                } else if char == ")" {
                    bracketCount -= 1
                }
                acosEnd = expr.index(after: acosEnd)
            }
            
            if bracketCount == 0 {
                let argumentStr = String(expr[acosStart..<expr.index(before: acosEnd)])
                guard let argument = Double(argumentStr) else {
                    throw NSError(domain: "Calculator", code: 2, userInfo: [NSLocalizedDescriptionKey: "cos⁻¹函数参数无效"])
                }
                
                if argument < -1 || argument > 1 {
                    throw NSError(domain: "Calculator", code: 4, userInfo: [NSLocalizedDescriptionKey: "cos⁻¹函数定义域错误"])
                }
                
                let result = acos(argument) * 180 / .pi // 转换为角度
                let before = String(expr[..<acosRange.lowerBound])
                let after = String(expr[acosEnd...])
                expr = before + String(result) + after
            }
        }
        
        // 处理反三角函数 tan⁻¹(x)
        while let atanRange = expr.range(of: "tan⁻¹(") {
            let atanStart = atanRange.upperBound
            var bracketCount = 1
            var atanEnd = atanStart
            
            // 找到匹配的右括号
            while atanEnd < expr.endIndex && bracketCount > 0 {
                let char = expr[atanEnd]
                if char == "(" {
                    bracketCount += 1
                } else if char == ")" {
                    bracketCount -= 1
                }
                atanEnd = expr.index(after: atanEnd)
            }
            
            if bracketCount == 0 {
                let argumentStr = String(expr[atanStart..<expr.index(before: atanEnd)])
                guard let argument = Double(argumentStr) else {
                    throw NSError(domain: "Calculator", code: 2, userInfo: [NSLocalizedDescriptionKey: "tan⁻¹函数参数无效"])
                }
                
                let result = atan(argument) * 180 / .pi // 转换为角度
                let before = String(expr[..<atanRange.lowerBound])
                let after = String(expr[atanEnd...])
                expr = before + String(result) + after
            }
        }
        
        return expr
    }
    
    // MARK: - 数学表达式计算
    private func evaluateMathExpression(_ expression: String) throws -> Double {
        // 简化的数学表达式计算
        // 支持基本的四则运算和数学函数
        
        var expr = expression
            .replacingOccurrences(of: "×", with: "*")
            .replacingOccurrences(of: "÷", with: "/")
        
        // 替换ans为数值
        expr = expr.replacingOccurrences(of: "ans", with: String(ansValue))
        
        // 处理数字和函数的组合（如3√3 -> 3*√3）
        expr = processNumberFunctionCombinations(expr)
        
        // 处理数学函数（根号、平方、log等）
        expr = try processMathFunctions(expr)
        
        // 处理分数（ans/数字 或 数字/ans）
        if expr.contains("/") {
            let parts = expr.components(separatedBy: "/")
            if parts.count == 2 {
                let numerator = parts[0].trimmingCharacters(in: .whitespaces)
                let denominator = parts[1].trimmingCharacters(in: .whitespaces)
                
                let numValue: Double
                let denValue: Double
                
                if numerator == "ans" {
                    numValue = ansValue
                } else if let num = Double(numerator) {
                    numValue = num
                } else {
                    throw NSError(domain: "Calculator", code: 2, userInfo: [NSLocalizedDescriptionKey: "分子无效"])
                }
                
                if denominator == "ans" {
                    denValue = ansValue
                } else if let den = Double(denominator) {
                    denValue = den
                } else {
                    throw NSError(domain: "Calculator", code: 2, userInfo: [NSLocalizedDescriptionKey: "分母无效"])
                }
                
                if denValue == 0 {
                    throw NSError(domain: "Calculator", code: 3, userInfo: [NSLocalizedDescriptionKey: "除零错误"])
                }
                
                return numValue / denValue
            }
        }
        
        // 处理乘除
        while let multiplyIndex = expr.firstIndex(of: "*") ?? expr.firstIndex(of: "/") {
            let operatorChar = expr[multiplyIndex]
            
            // 找到左操作数
            var leftStart = multiplyIndex
            while leftStart > expr.startIndex {
                let prevIndex = expr.index(before: leftStart)
                let char = expr[prevIndex]
                if char.isNumber || char == "." || char == "-" {
                    leftStart = prevIndex
                } else {
                    break
                }
            }
            
            // 找到右操作数
            var rightEnd = expr.index(after: multiplyIndex)
            while rightEnd < expr.endIndex {
                let char = expr[rightEnd]
                if char.isNumber || char == "." || char == "-" {
                    rightEnd = expr.index(after: rightEnd)
                } else {
                    break
                }
            }
            
            let leftStr = String(expr[leftStart..<multiplyIndex])
            let rightStr = String(expr[expr.index(after: multiplyIndex)..<rightEnd])
            
            guard let left = Double(leftStr), let right = Double(rightStr) else {
                throw NSError(domain: "Calculator", code: 2, userInfo: [NSLocalizedDescriptionKey: "操作数无效"])
            }
            
            let result: Double
            if operatorChar == "*" {
                result = left * right
            } else {
                if right == 0 {
                    throw NSError(domain: "Calculator", code: 3, userInfo: [NSLocalizedDescriptionKey: "除零错误"])
                }
                result = left / right
            }
            
            // 替换表达式中的这部分
            let before = String(expr[..<leftStart])
            let after = String(expr[rightEnd...])
            expr = before + String(result) + after
        }
        
        // 处理加减
        while let addIndex = expr.firstIndex(of: "+") ?? expr.firstIndex(of: "-") {
            // 跳过开头的负号
            if addIndex == expr.startIndex {
                break
            }
            
            let operatorChar = expr[addIndex]
            
            // 找到左操作数
            var leftStart = addIndex
            while leftStart > expr.startIndex {
                let prevIndex = expr.index(before: leftStart)
                let char = expr[prevIndex]
                if char.isNumber || char == "." || char == "-" {
                    leftStart = prevIndex
                } else {
                    break
                }
            }
            
            // 找到右操作数
            var rightEnd = expr.index(after: addIndex)
            while rightEnd < expr.endIndex {
                let char = expr[rightEnd]
                if char.isNumber || char == "." || char == "-" {
                    rightEnd = expr.index(after: rightEnd)
                } else {
                    break
                }
            }
            
            let leftStr = String(expr[leftStart..<addIndex])
            let rightStr = String(expr[expr.index(after: addIndex)..<rightEnd])
            
            guard let left = Double(leftStr), let right = Double(rightStr) else {
                throw NSError(domain: "Calculator", code: 2, userInfo: [NSLocalizedDescriptionKey: "操作数无效"])
            }
            
            let result: Double
            if operatorChar == "+" {
                result = left + right
            } else {
                result = left - right
            }
            
            // 替换表达式中的这部分
            let before = String(expr[..<leftStart])
            let after = String(expr[rightEnd...])
            expr = before + String(result) + after
        }
        
        // 最终结果应该是单个数字
        guard let finalResult = Double(expr) else {
            throw NSError(domain: "Calculator", code: 4, userInfo: [NSLocalizedDescriptionKey: "计算结果无效"])
        }
        
        return finalResult
    }
    
    private func formatResult(_ result: Double) -> String {
        if result.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", result)
        } else {
            return String(format: "%.6f", result)
        }
    }
    
    // MARK: - 设置界面
    var settingsView: some View {
        VStack(alignment: .leading, spacing: 10) {
            // 设置标题
            Text("设置")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
            
            // 设置标签页
            HStack(spacing: 0) {
                SettingTabButton(title: "计算设置", isSelected: currentSettingTab == .calculation) {
                    currentSettingTab = .calculation
                }
                SettingTabButton(title: "系统设置", isSelected: currentSettingTab == .system) {
                    currentSettingTab = .system
                }
                SettingTabButton(title: "复位", isSelected: currentSettingTab == .reset) {
                    currentSettingTab = .reset
                }
            }
            .background(Color.gray.opacity(0.3))
            .cornerRadius(8)
            
            // 设置内容
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    switch currentSettingTab {
                    case .calculation:
                        calculationSettingsView
                    case .system:
                        systemSettingsView
                    case .reset:
                        resetSettingsView
                    }
                }
            }
            
            // 关闭按钮
            HStack {
                Spacer()
                Button("关闭") {
                    showSettings = false
                }
                .foregroundColor(.blue)
                .padding(.top, 10)
            }
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 10)
        .background(Color.black.opacity(0.9))
        .cornerRadius(10)
    }
    
    // MARK: - 计算设置视图
    var calculationSettingsView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("输入输出设置")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.yellow)
            
            Text("角度单位")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.yellow)
            
            Text("显示格式")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.yellow)
            
            Text("工程符号")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.yellow)
            
            Text("分数结果")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.yellow)
            
            Text("复数结果")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.yellow)
            
            Text("小数点显示")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.yellow)
            
            Text("数字分隔符")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.yellow)
        }
        .foregroundColor(.white)
    }
    
    // MARK: - 系统设置视图
    var systemSettingsView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("系统设置选项")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.yellow)
            
            Text("（待实现）")
                .font(.system(size: 12))
                .foregroundColor(.gray)
        }
        .foregroundColor(.white)
    }
    
    // MARK: - 复位设置视图
    var resetSettingsView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("复位选项")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.yellow)
            
            Text("（待实现）")
                .font(.system(size: 12))
                .foregroundColor(.gray)
        }
        .foregroundColor(.white)
    }
}

// MARK: - 计算器按钮组件

struct CalculatorButton: View {
    let title: String
    let shiftTitle: String?
    let color: Color
    let isWide: Bool
    let isTall: Bool
    let action: () -> Void
    
    init(title: String, shiftTitle: String? = nil, color: Color = .gray, isWide: Bool = false, isTall: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.shiftTitle = shiftTitle
        self.color = color
        self.isWide = isWide
        self.isTall = isTall
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                // Shift功能显示
                if let shiftTitle = shiftTitle {
                    Text(shiftTitle)
                        .font(.system(size: 8, weight: .medium))
                        .foregroundColor(.yellow)
                        .frame(height: 12)
                }
                
                // 主按钮文字
                Text(title)
                    .font(.system(size: title.count > 2 ? 12 : 16, weight: .medium))
                    .foregroundColor(.white)
                    .frame(
                        width: isWide ? 120 : 60,
                        height: isTall ? 120 : (shiftTitle != nil ? 38 : 50)
                    )
                    .background(color)
            }
            .clipShape(RoundedRectangle(cornerRadius: 6))
        }
        .scaleEffect(0.95)
        .animation(.easeInOut(duration: 0.1), value: title)
    }
}

// MARK: - 格式选项按钮
struct FormatOptionButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(isSelected ? .black : .white)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(isSelected ? Color.yellow : Color.gray.opacity(0.3))
                .cornerRadius(4)
        }
    }
}

// MARK: - 设置标签页按钮
struct SettingTabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(isSelected ? .black : .white)
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(isSelected ? Color.yellow : Color.clear)
                .cornerRadius(6)
        }
    }
}

#Preview {
    ContentView()
}

