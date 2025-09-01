import Foundation
#if canImport(AppKit)
import AppKit
#endif
#if canImport(UIKit)
import UIKit
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif
#if canImport(DeveloperToolsSupport)
import DeveloperToolsSupport
#endif

#if SWIFT_PACKAGE
private let resourceBundle = Foundation.Bundle.module
#else
private class ResourceBundleClass {}
private let resourceBundle = Foundation.Bundle(for: ResourceBundleClass.self)
#endif

// MARK: - Color Symbols -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension DeveloperToolsSupport.ColorResource {

}

// MARK: - Image Symbols -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension DeveloperToolsSupport.ImageResource {

    /// The "Ignite_Celebrating" asset catalog image resource.
    static let igniteCelebrating = DeveloperToolsSupport.ImageResource(name: "Ignite_Celebrating", bundle: resourceBundle)

    /// The "Ignite_Heart" asset catalog image resource.
    static let igniteHeart = DeveloperToolsSupport.ImageResource(name: "Ignite_Heart", bundle: resourceBundle)

    /// The "Ignite_Leyendo" asset catalog image resource.
    static let igniteLeyendo = DeveloperToolsSupport.ImageResource(name: "Ignite_Leyendo", bundle: resourceBundle)

    /// The "Ignite_Meditation" asset catalog image resource.
    static let igniteMeditation = DeveloperToolsSupport.ImageResource(name: "Ignite_Meditation", bundle: resourceBundle)

    /// The "Ignite_Neutral" asset catalog image resource.
    static let igniteNeutral = DeveloperToolsSupport.ImageResource(name: "Ignite_Neutral", bundle: resourceBundle)

    /// The "Ignite_Running" asset catalog image resource.
    static let igniteRunning = DeveloperToolsSupport.ImageResource(name: "Ignite_Running", bundle: resourceBundle)

    /// The "Ignite_Sad" asset catalog image resource.
    static let igniteSad = DeveloperToolsSupport.ImageResource(name: "Ignite_Sad", bundle: resourceBundle)

    /// The "Ignite_Sleep" asset catalog image resource.
    static let igniteSleep = DeveloperToolsSupport.ImageResource(name: "Ignite_Sleep", bundle: resourceBundle)

    /// The "Ignite_Thinking" asset catalog image resource.
    static let igniteThinking = DeveloperToolsSupport.ImageResource(name: "Ignite_Thinking", bundle: resourceBundle)

    /// The "Ignite_Trophy" asset catalog image resource.
    static let igniteTrophy = DeveloperToolsSupport.ImageResource(name: "Ignite_Trophy", bundle: resourceBundle)

    /// The "Ignite_Waving" asset catalog image resource.
    static let igniteWaving = DeveloperToolsSupport.ImageResource(name: "Ignite_Waving", bundle: resourceBundle)

}

// MARK: - Color Symbol Extensions -

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSColor {

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIColor {

}
#endif

#if canImport(SwiftUI)
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.Color {

}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.ShapeStyle where Self == SwiftUI.Color {

}
#endif

// MARK: - Image Symbol Extensions -

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSImage {

    /// The "Ignite_Celebrating" asset catalog image.
    static var igniteCelebrating: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .igniteCelebrating)
#else
        .init()
#endif
    }

    /// The "Ignite_Heart" asset catalog image.
    static var igniteHeart: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .igniteHeart)
#else
        .init()
#endif
    }

    /// The "Ignite_Leyendo" asset catalog image.
    static var igniteLeyendo: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .igniteLeyendo)
#else
        .init()
#endif
    }

    /// The "Ignite_Meditation" asset catalog image.
    static var igniteMeditation: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .igniteMeditation)
#else
        .init()
#endif
    }

    /// The "Ignite_Neutral" asset catalog image.
    static var igniteNeutral: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .igniteNeutral)
#else
        .init()
#endif
    }

    /// The "Ignite_Running" asset catalog image.
    static var igniteRunning: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .igniteRunning)
#else
        .init()
#endif
    }

    /// The "Ignite_Sad" asset catalog image.
    static var igniteSad: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .igniteSad)
#else
        .init()
#endif
    }

    /// The "Ignite_Sleep" asset catalog image.
    static var igniteSleep: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .igniteSleep)
#else
        .init()
#endif
    }

    /// The "Ignite_Thinking" asset catalog image.
    static var igniteThinking: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .igniteThinking)
#else
        .init()
#endif
    }

    /// The "Ignite_Trophy" asset catalog image.
    static var igniteTrophy: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .igniteTrophy)
#else
        .init()
#endif
    }

    /// The "Ignite_Waving" asset catalog image.
    static var igniteWaving: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .igniteWaving)
#else
        .init()
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

    /// The "Ignite_Celebrating" asset catalog image.
    static var igniteCelebrating: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .igniteCelebrating)
#else
        .init()
#endif
    }

    /// The "Ignite_Heart" asset catalog image.
    static var igniteHeart: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .igniteHeart)
#else
        .init()
#endif
    }

    /// The "Ignite_Leyendo" asset catalog image.
    static var igniteLeyendo: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .igniteLeyendo)
#else
        .init()
#endif
    }

    /// The "Ignite_Meditation" asset catalog image.
    static var igniteMeditation: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .igniteMeditation)
#else
        .init()
#endif
    }

    /// The "Ignite_Neutral" asset catalog image.
    static var igniteNeutral: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .igniteNeutral)
#else
        .init()
#endif
    }

    /// The "Ignite_Running" asset catalog image.
    static var igniteRunning: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .igniteRunning)
#else
        .init()
#endif
    }

    /// The "Ignite_Sad" asset catalog image.
    static var igniteSad: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .igniteSad)
#else
        .init()
#endif
    }

    /// The "Ignite_Sleep" asset catalog image.
    static var igniteSleep: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .igniteSleep)
#else
        .init()
#endif
    }

    /// The "Ignite_Thinking" asset catalog image.
    static var igniteThinking: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .igniteThinking)
#else
        .init()
#endif
    }

    /// The "Ignite_Trophy" asset catalog image.
    static var igniteTrophy: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .igniteTrophy)
#else
        .init()
#endif
    }

    /// The "Ignite_Waving" asset catalog image.
    static var igniteWaving: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .igniteWaving)
#else
        .init()
#endif
    }

}
#endif

// MARK: - Thinnable Asset Support -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@available(watchOS, unavailable)
extension DeveloperToolsSupport.ColorResource {

    private init?(thinnableName: Swift.String, bundle: Foundation.Bundle) {
#if canImport(AppKit) && os(macOS)
        if AppKit.NSColor(named: NSColor.Name(thinnableName), bundle: bundle) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#elseif canImport(UIKit) && !os(watchOS)
        if UIKit.UIColor(named: thinnableName, in: bundle, compatibleWith: nil) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIColor {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
#if !os(watchOS)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(SwiftUI)
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.Color {

    private init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
        if let resource = thinnableResource {
            self.init(resource)
        } else {
            return nil
        }
    }

}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.ShapeStyle where Self == SwiftUI.Color {

    private init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
        if let resource = thinnableResource {
            self.init(resource)
        } else {
            return nil
        }
    }

}
#endif

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@available(watchOS, unavailable)
extension DeveloperToolsSupport.ImageResource {

    private init?(thinnableName: Swift.String, bundle: Foundation.Bundle) {
#if canImport(AppKit) && os(macOS)
        if bundle.image(forResource: NSImage.Name(thinnableName)) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#elseif canImport(UIKit) && !os(watchOS)
        if UIKit.UIImage(named: thinnableName, in: bundle, compatibleWith: nil) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSImage {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ImageResource?) {
#if !targetEnvironment(macCatalyst)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ImageResource?) {
#if !os(watchOS)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

