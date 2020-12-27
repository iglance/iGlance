import Foundation
import ServiceManagement
import Combine

public enum LaunchAtLogin {
	public static let kvo = KVO()

	@available(macOS 10.15, *)
	public static let observable = Observable()

	@available(macOS 10.15, *)
	private static var _publisher = CurrentValueSubject<Bool, Never>(isEnabled)
	@available(macOS 10.15, *)
	public static var publisher = _publisher.eraseToAnyPublisher()

	private static let id = "\(Bundle.main.bundleIdentifier!)-LaunchAtLoginHelper"

	public static var isEnabled: Bool {
		get {
			guard let jobs = (SMCopyAllJobDictionaries(kSMDomainUserLaunchd).takeRetainedValue() as? [[String: AnyObject]]) else {
				return false
			}

			let job = jobs.first { $0["Label"] as! String == id }

			return job?["OnDemand"] as? Bool ?? false
		}
		set {
			if #available(macOS 10.15, *) {
				observable.objectWillChange.send()
			}

			kvo.willChangeValue(for: \.isEnabled)
			SMLoginItemSetEnabled(id as CFString, newValue)
			kvo.didChangeValue(for: \.isEnabled)

			if #available(macOS 10.15, *) {
				_publisher.send(newValue)
			}
		}
	}
}

// MARK: - LaunchAtLoginObservable
extension LaunchAtLogin {
	@available(macOS 10.15, *)
	public final class Observable: ObservableObject {
		public var isEnabled: Bool {
			get { LaunchAtLogin.isEnabled }
			set {
				LaunchAtLogin.isEnabled = newValue
			}
		}
	}
}

// MARK: - LaunchAtLoginKVO
extension LaunchAtLogin {
	public final class KVO: NSObject {
		@objc dynamic public var isEnabled: Bool {
			get { LaunchAtLogin.isEnabled }
			set {
				LaunchAtLogin.isEnabled = newValue
			}
		}
	}
}
