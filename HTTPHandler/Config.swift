struct Config: Decodable {

	let application: String
	let urlPatterns: [String]

	func matches(url: String) -> Bool {
		for pattern in urlPatterns where url ~= pattern {
			return true
		}
		return false
	}

}

extension String {

	static func ~= (lhs: String, rhs: String) -> Bool {
		let text = lhs
		let pattern = rhs
		return text.range(of: pattern, options: .regularExpression) != nil
	}

}
