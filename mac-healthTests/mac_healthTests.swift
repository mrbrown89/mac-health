//
//  mac_healthTests.swift
//  mac-healthTests
//
//  Created by Matt on 22/08/2026.
//

import Testing
@testable import mac_health

struct MacHealthTests {

    @Test
    func healthStatusEncodesCorrectly() throws {
        let status = HealthStatus.ok

        #expect(status == .ok)
    }
}
