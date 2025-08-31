# Ignite Premium Design System Style Guide

## Design Philosophy

Our design system embodies the principles of iconic designers to create an everyday success companion that feels premium, purposeful, and delightful.

### Core Principles

#### 1. **Dieter Rams: "Less, but better"**
- Eliminate unnecessary elements
- Every component serves a clear purpose
- Simplicity without sacrificing functionality

#### 2. **Apple: Clarity, Deference, Depth**
- **Clarity**: Legible text, precise icons, clear affordances
- **Deference**: Content is king, UI supports but doesn't overshadow
- **Depth**: Subtle layers and motion create hierarchy

#### 3. **Charles & Ray Eames: Function with Soul**
- Warm, human touches in functional design
- Rounded corners and soft edges for approachability
- Thoughtful details that spark joy

#### 4. **Philippe Starck: Sophisticated Minimalism**
- Elegant simplicity with character
- Premium materials and finishes
- Unexpected delightful moments

---

## Color System

### Primary Brand Colors
```swift
premiumIndigo    = Color(red: 0.345, green: 0.337, blue: 0.839)  // #5856D6
premiumBlue      = Color(red: 0.0, green: 0.478, blue: 1.0)      // #007AFF
premiumTeal      = Color(red: 0.352, green: 0.796, blue: 0.823)  // #5AC8D2
```

### Accent Colors
```swift
premiumCoral     = Color(red: 1.0, green: 0.584, blue: 0.459)    // #FF9575
premiumMint      = Color(red: 0.0, green: 0.780, blue: 0.746)    // #00C7BE
premiumAmber     = Color(red: 1.0, green: 0.624, blue: 0.039)    // #FF9F0A
```

### Semantic Colors
```swift
premiumSuccess   = Color(red: 0.204, green: 0.780, blue: 0.349)  // #34C759
premiumWarning   = Color(red: 1.0, green: 0.584, blue: 0.0)      // #FF9500
premiumError     = Color(red: 1.0, green: 0.231, blue: 0.188)    // #FF3B30
```

### Neutral Palette
A sophisticated grayscale from pure black to white:
- **premiumBlack**: Pure black for maximum contrast
- **premiumGray1-6**: Six levels of gray for hierarchy
- **premiumWhite**: Clean white for surfaces

### Dynamic Backgrounds
Time-aware gradients that shift throughout the day:
- **Morning**: Warm, energizing tones
- **Afternoon**: Clear, productive blues
- **Evening**: Calming purples
- **Night**: Deep, restful blues

---

## Typography System

### Type Scale
```swift
premiumLargeTitle  // 34pt Bold Rounded - Hero headers
premiumTitle1      // 28pt Semibold Rounded - Page titles
premiumTitle2      // 22pt Semibold Rounded - Section headers
premiumTitle3      // 20pt Medium Rounded - Subsections
premiumHeadline    // 17pt Semibold - Important text
premiumSubheadline // 15pt Medium - Secondary headers
premiumBody        // 16pt Regular - Body text
premiumCallout     // 15pt Regular - Callout text
premiumFootnote    // 13pt Regular - Supporting text
premiumCaption1    // 12pt Regular - Small labels
premiumCaption2    // 11pt Regular - Tiny labels
```

### Typography Rules
1. **SF Rounded** for display text (titles, numbers)
2. **SF Pro** for body and UI text
3. **Consistent hierarchy** - skip no more than one level
4. **Tracking** - Use letter-spacing for CAPS labels (1.2-1.5)

---

## Spacing System (4pt Grid)

All spacing follows a 4-point grid system for consistency:

```swift
spacing2   = 2    // Hairline spacing
spacing4   = 4    // Tight spacing
spacing8   = 8    // Compact spacing
spacing12  = 12   // Default small spacing
spacing16  = 16   // Default medium spacing
spacing20  = 20   // Comfortable spacing
spacing24  = 24   // Default large spacing
spacing32  = 32   // Section spacing
spacing40  = 40   // Large section spacing
spacing48  = 48   // Extra large spacing
spacing64  = 64   // Hero spacing
spacing80  = 80   // Maximum spacing
```

### Usage Guidelines
- **Between elements**: spacing8-spacing16
- **Section padding**: spacing20-spacing24
- **Between sections**: spacing32-spacing40
- **Screen margins**: spacing20

---

## Corner Radius System

```swift
radiusXS   = 4    // Subtle rounding
radiusS    = 8    // Small components
radiusM    = 12   // Default radius
radiusL    = 16   // Cards and containers
radiusXL   = 20   // Large components
radius2XL  = 28   // Extra large elements
radiusFull = 999  // Perfect circles
```

---

## Elevation & Shadows

### Shadow Levels
```swift
premiumShadowXS()  // Barely visible (buttons, inputs)
premiumShadowS()   // Subtle depth (cards)
premiumShadowM()   // Medium elevation (modals)
premiumShadowL()   // High elevation (floating buttons)
premiumShadowXL()  // Maximum elevation (overlays)
```

### Glass Morphism
- **Background**: 72% white opacity
- **Overlay**: 30% white opacity
- **Border**: 60% white opacity
- **Blur**: Ultra-thin material effect

---

## Animation System

### Animation Curves
```swift
premiumSpring  // 0.38s, 82% damping - Smooth, controlled
premiumBounce  // 0.5s, 65% damping - Playful feedback
premiumSmooth  // 0.35s ease-in-out - General transitions
premiumQuick   // 0.25s ease-out - Immediate response
premiumSlow    // 0.6s ease-in-out - Dramatic reveals
```

### Animation Principles
1. **Purpose**: Every animation has a clear purpose
2. **Performance**: 60fps always, prefer transforms
3. **Consistency**: Same actions use same timing
4. **Delight**: Subtle bounces and springs for feedback

---

## Component Library

### Primary Button
- Gradient background (indigo → blue)
- 16pt padding vertical, 24pt horizontal
- Medium shadow on rest, scale to 97% on press
- Rounded corners (radiusM)

### Glass Card
- Ultra-thin material background
- 0.5pt white border
- Medium shadow
- Scale effect on interaction

### Progress Ring
- Gradient stroke (indigo → teal)
- Animated fill with spring curve
- Optional percentage display

### Floating Action Button
- 60×60pt circle
- Gradient fill
- Large shadow
- Scale and rotation on press

### Checkbox
- 28×28pt rounded square
- Spring animation on toggle
- Haptic feedback
- Checkmark scales in

---

## Micro-interactions

### Haptic Feedback
- **Light**: Toggle switches, checkboxes
- **Medium**: Button presses, completions
- **Success**: Achievement unlocked, goal reached

### Visual Feedback
- **Scale**: 97% on press for buttons
- **Color**: Gradient shifts for progress
- **Motion**: Spring animations for state changes

---

## Responsive Design

### Breakpoints
- **Compact**: iPhone SE, older devices
- **Regular**: iPhone 14/15/16
- **Large**: iPhone Pro Max, iPads

### Adaptive Layouts
- Stack views that reflow
- Dynamic type support
- Flexible spacing that adjusts

---

## Best Practices

### Do's
✅ Use consistent spacing from the grid
✅ Apply shadows purposefully for hierarchy
✅ Animate with intention and meaning
✅ Test on both light and dark backgrounds
✅ Consider haptic feedback for interactions

### Don'ts
❌ Mix corner radius sizes randomly
❌ Use more than 3 shadow levels per screen
❌ Animate everything - be selective
❌ Ignore platform conventions
❌ Forget about accessibility

---

## Implementation Example

```swift
struct PremiumCard: View {
    var body: some View {
        VStack(spacing: .spacing16) {
            Text("Title")
                .font(.premiumHeadline)
                .foregroundColor(.premiumGray1)
            
            Text("Description")
                .font(.premiumBody)
                .foregroundColor(.premiumGray3)
        }
        .padding(.spacing20)
        .premiumGlassCard()
        .premiumShadowM()
    }
}
```

---

## Future Considerations

### Dark Mode
- Invert grays, maintain brand colors
- Reduce opacity on glass effects
- Adjust shadows for dark backgrounds

### Accessibility
- Minimum touch targets: 44×44pt
- Color contrast ratios: 4.5:1 minimum
- Support Dynamic Type
- VoiceOver labels for all interactive elements

### Performance
- Limit blur effects on older devices
- Reduce animation complexity when Low Power Mode
- Cache gradient calculations
- Optimize shadow rendering

---

## Version History

**v1.0** - Initial Premium Design System
- Established core principles
- Defined color, typography, and spacing
- Created component library
- Added animation system

---

*This design system is a living document. Update it as the product evolves while maintaining the core principles that make the experience premium and delightful.*