struct Config: Decodable {

	let application: String
	let urlPatterns: [String]

	func matches(url: String) -> String? {
		for pattern in urlPatterns where url ~= pattern {
			return pattern
		}
		return nil
	}

}

extension String {

	static func ~= (lhs: String, rhs: String) -> Bool {
		let text = lhs
		let pattern = rhs
		return text.range(of: pattern, options: .regularExpression) != nil
	}

}
