import os
import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

	@IBOutlet weak var window: NSWindow!

	var logger: Logger = {
		let subsystem = Bundle.main.bundleIdentifier!
		return Logger(subsystem: subsystem, category: "default")
	}()

	struct HTTPHandlerError: Error {
		let message: String
	}

	func applicationDidFinishLaunching(_: Notification) {
		// For http:// or https://
		NSAppleEventManager.shared().setEventHandler(
			self,
			andSelector: #selector(openUrl(withEvent:)),
			forEventClass: AEEventClass(kInternetEventClass),
			andEventID: AEEventID(kAEGetURL)
		)
		// For file://
		NSAppleEventManager.shared().setEventHandler(
			self,
			andSelector: #selector(openUrl(withEvent:)),
			forEventClass: AEEventClass(kCoreEventClass),
			andEventID: AEEventID(kAEOpenDocuments)
		)
		if let bundleId = Bundle.main.bundleIdentifier as CFString? {
			LSSetDefaultHandlerForURLScheme("http" as CFString, bundleId)
			LSSetDefaultHandlerForURLScheme("https" as CFString, bundleId)
		}
		else {
			logger.error("Failed to register as HTTP handler")
		}
	}

	@objc
	func openUrl(withEvent event: NSAppleEventDescriptor) {
		do {
			guard let url = event.paramDescriptor(forKeyword: AEKeyword(keyDirectObject))?.stringValue else {
				throw HTTPHandlerError(message: "Failed to get URL parameter")
			}
			for config in try configs() {
				if let matchedPattern = config.matches(url: url) {
					logger.info("Matched '\(matchedPattern, privacy: .public)'")
					App(config: config, logger: logger).launch(url: url)
					return
				}
			}
			throw HTTPHandlerError(message: "Suitable config not found")
		}
		catch let error as HTTPHandlerError {
			logger.error("Error: \(error.message, privacy: .public)")
		}
		catch {
			logger.error("Error: \(error as NSError, privacy: .public)")
		}
	}

	private func configs() throws -> [Config] {
		let data = try Data(contentsOf: configURL())
		let decoder = PropertyListDecoder()
		guard let configs = try? decoder.decode([Config].self, from: data) else {
			throw HTTPHandlerError(message: "Failed to parse config file")
		}
		return configs
	}

	private func configURL() throws -> URL {
		let configUrl = try appSupportDirURL().appendingPathComponent("config.plist")
		if !FileManager.default.fileExists(atPath: configUrl.path) {
			throw HTTPHandlerError(message: "Please create config file at '\(configUrl.path)'")
		}
		return configUrl
	}

	private func appSupportDirURL() throws -> URL {
		let fileManager = FileManager.default
		guard let supportDirUrl = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
			throw HTTPHandlerError(message: "Unable to find support directory")
		}
		let appSupportDirURL = supportDirUrl.appendingPathComponent("HTTPHandler")
		var isDirectory: ObjCBool = false
		let exists = fileManager.fileExists(atPath: appSupportDirURL.path, isDirectory: &isDirectory)
		if !exists {
			try createDir(url: appSupportDirURL)
		}
		else if !isDirectory.boolValue {
			throw HTTPHandlerError(message: "App support dir '\(appSupportDirURL.path)' is file!")
		}
		return appSupportDirURL
	}

	private func createDir(url: URL) throws {
		do {
			try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
			logger.info("Created support directory '\(url.path, privacy: .public)'")
		}
		catch {
			throw HTTPHandlerError(message: "Failed to create support directory '\(url.path)'")
		}
	}

}
