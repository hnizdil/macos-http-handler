import class Cocoa.Process
import struct os.Logger

class App {

	let config: Config
	let logger: Logger

	init(config: Config, logger: Logger) {
		self.config = config
		self.logger = logger
	}

	func launch(url: String) {
		let path = "/usr/bin/open"
		let args = ["-a", config.application, url]
		let process = Process()
		process.launchPath = path
		process.arguments = args
		process.launch()
		logger.info("Launched: \(path, privacy: .public) \(args.joined(separator: " "), privacy: .public)")
	}

}
