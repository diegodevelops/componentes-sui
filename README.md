# ComponentesSUI

A Swift Package containing reusable SwiftUI views for iOS 17+.

## Installation

Add this package to your Xcode project via Swift Package Manager:

```
https://github.com/diegodevelops/ComponentesSUI.git
```

## Available Views

### WithBinding

A wrapper view that creates internal `@State` and exposes it as a `Binding` to its content. Useful for SwiftUI previews or when you need self-contained state without an external source.

**Usage:**

```swift
WithBinding(data: "Initial value") { textBinding in
    TextField("Enter text", text: textBinding)
}
```

---

### OffsetObservingScrollView

A `ScrollView` that tracks its content offset and reports it through a `Binding<CGPoint>`. Ideal for scroll-driven animations, parallax effects, or custom scroll indicators.

**Parameters:**
- `axis`: Scroll direction (`.vertical` or `.horizontal`)
- `showsIndicators`: Whether to show scroll indicators
- `enablePaging`: Enable paging behavior
- `offset`: Binding to receive the current scroll offset

**Usage:**

```swift
@State private var scrollOffset: CGPoint = .zero

OffsetObservingScrollView(
    axis: .vertical,
    showsIndicators: true,
    enablePaging: false,
    offset: $scrollOffset
) {
    // Your scrollable content
}
```

## Requirements

- iOS 17.0+
- Swift 6.2+

## License

MIT License
