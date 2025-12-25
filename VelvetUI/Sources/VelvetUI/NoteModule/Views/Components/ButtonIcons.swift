//
//  ButtonIcons.swift
//  VelvetUI
//
//  Created by Илья Востров on 22.12.2025.
//


import SwiftUI

// MARK: - Button Icons Enum
enum ButtonIcons: String, CaseIterable {
    case xmark
    case arrowRight = "arrow.right"
    case calendar
    // Можно добавить другие иконки, если нужно
}

// MARK: - Rounded Button View
struct RoundedButton: View {
    let icon: ButtonIcons
    let backgroundColor: Color
    let iconColor: Color
    let action: () -> Void

    // Инициализатор с параметрами по умолчанию
    init(
        icon: ButtonIcons,
        backgroundColor: Color = .gray.opacity(0.15),
        iconColor: Color = .gray,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.backgroundColor = backgroundColor
        self.iconColor = iconColor
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Circle()
                .frame(width: 40, height: 40) // Указываем ширину и высоту для квадратного круга
                .foregroundStyle(backgroundColor)
                .overlay {
                    Image(systemName: icon.rawValue)
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(iconColor)
                        .frame(width: 16, height: 16)
                }
        }
        // Убираем стандартный стиль кнопки для лучшего контроля
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
#Preview {
    VStack {
        RoundedButton(icon: .xmark, action: { })
        RoundedButton(icon: .calendar, action: { })
        RoundedButton(icon: .arrowRight, action: { })
    }
    .padding()
}