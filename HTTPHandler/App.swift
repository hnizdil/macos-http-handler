import class Cocoa.Process
import struct os.Logger

class App {

	let path: String
	let args: [String]
	let logger: Logger
	let process: Process

	init(config: Config, url: String, logger: Logger) {
		path = "/usr/bin/open"
		args = ["-a", config.application, url]
		process = Process()
		process.launchPath = path
		process.arguments = args
		self.logger = logger
	}

	func launch() {
		process.launch()
		let args = self.args.joined(separator: " ")
		logger.info("Launched: \(self.path, privacy: .public) \(args, privacy: .public)")
	}

}
