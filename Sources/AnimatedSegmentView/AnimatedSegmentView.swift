//
//  AnimatedSegmentView.swift
//
//
//  Created by ahmed suliman on 10/08/2024.
//

import SwiftUI

public struct AnimatedSegmentView<T: Equatable, Content: View, Background: View>: View {
    @Namespace private var selectionAnimation
    /// The currently selected item, if there is one
    @Binding var selectedItem: T?
    /// The list of options available in this picker
    private let items: [T]
    /// The View that takes in one of the elements from the items array to display an item
    private let content: (T) -> Content
    private let background: (T) -> Background
    private let animation: Animation

    /// Create a new Segmented Picker
    /// - Parameters:
    ///     - selectedItem: The currently selected item, optional
    ///     - items: The list of items to display as options, can be any Equatable type such as String, Int, etc.
    ///     - content: The View to display for elements of the items array
    public init(
        animation: Animation = .spring,
        _ items: [T],
        selectedItem: Binding<T?>,
        @ViewBuilder content: @escaping (T) -> Content,
        @ViewBuilder background: @escaping (T) -> Background
    ) {
        self.animation = animation
        self._selectedItem = selectedItem
        self.items = items
        self.content = content
        self.background = background
    }

    public var body: some View {
        HStack {
            ForEach(0..<items.count, id: \.self) { index in
                let item = items[index]
                if selectedItem == item {
                    content(item)
                        .background(
                            background(item)
                                .matchedGeometryEffect(id: "selectedSegmentHighlight", in: self.selectionAnimation)
                        )
                        .onTapFullGesture {
                            withAnimation(animation) {
                                selectedItem = item
                            }
                        }
                } else {
                    content(item)
                        .onTapFullGesture {
                            withAnimation(animation) {
                                selectedItem = item
                            }
                        }
                }

            }
        }
    }
}

extension View {
    func onTapFullGesture(count: Int = 1, perform action: @escaping () -> Void) -> some View {
        self.contentShape(Rectangle())
            .onTapGesture(count: count, perform: action)
    }
}

extension Binding {
    static func optionalBinding<T>(_ bindingValue: Binding<T>) -> Binding<T?> {
        Binding<T?>(
            get: {
                bindingValue.wrappedValue
            }, set: { value in
                if let value {
                    bindingValue.wrappedValue = value
                }
            }
        )
    }
}

#if DEBUG
struct TestView1: View {
    @Namespace private var selectionAnimation
    @State private var selectedItem = "Food"


    var body: some View {
        AnimatedSegmentView(
            ["Food", "Grocery"],
            selectedItem: .optionalBinding($selectedItem),
            content: { item in
                Text(item.description.uppercased())
                    .padding(.vertical)
                    .frame(maxWidth: .infinity)
            },
            background: { _ in
                VStack {
                    Spacer()
                    Color.black.frame(height: 2)
                }
            }
            )
    }
}

struct TestView2: View {
    enum SegmentType: String, CaseIterable {
        case food
        case grocery
    }
    @Namespace private var selectionAnimation
    @State private var selectedItem: SegmentType? = .food


    var body: some View {
        AnimatedSegmentView(
            animation: .linear(duration: 0.25),
            SegmentType.allCases,
            selectedItem: $selectedItem,
            content: { item in
                Text(item.rawValue.capitalized)
                    .font(.subheadline)
                    .padding(.vertical)
                    .frame(maxWidth: .infinity)
            },
            background: { _ in
                Capsule().fill(Color(red: 245 / 255, green: 245 / 255, blue: 245 / 255))
            }
        )
        .padding(4)
        .background(Capsule().fill(Color(red: 225 / 255, green: 225 / 255, blue: 225 / 255)))
        .padding(.horizontal)
    }
}

struct TestView3: View {
    enum SegmentType: String, CaseIterable {
        case food
        case coffee
        case grocery
        case flowers
    }
    @Namespace private var selectionAnimation
    @State private var selectedItem: SegmentType?


    var body: some View {
        AnimatedSegmentView(
            animation: .linear(duration: 0.25),
            SegmentType.allCases,
            selectedItem: $selectedItem,
            content: { item in
                Text(item.rawValue.capitalized)
                    .font(.subheadline)
                    .padding(.vertical)
                    .frame(maxWidth: .infinity)
            },
            background: { _ in
                RoundedRectangle(cornerRadius: 8).fill(Color(red: 245 / 255, green: 245 / 255, blue: 245 / 255))
            }
        )
        .padding(4)
        .background(RoundedRectangle(cornerRadius: 8).fill(Color(red: 225 / 255, green: 225 / 255, blue: 225 / 255)))
        .padding(.horizontal)
    }
}

#Preview("Test1") {
    TestView1()
}


#Preview("Test2") {
    TestView2()
}

#Preview("Test3") {
    TestView3()
}

#endif

