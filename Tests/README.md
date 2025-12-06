# DiskDevil Tests

This directory contains unit tests for DiskDevil's core managers.

## Running Tests

Since DiskDevil is a macOS SwiftUI application (not a library), tests must be run through Xcode:

1. Open the project in Xcode
2. Create a new Xcode project targeting macOS
3. Add the test files to your test target
4. Run tests with `Cmd + U`

## Test Coverage

### UsageLimitsTests
- Initial state validation
- Hidden file reveal limits
- Network monitor usage limits
- Security scan limits
- Unlock all functionality
- Time until reset calculations

### SubscriptionManagerTests
- Initial tier state
- Tier updates (Premium, Elite)
- Subscription expiration handling
- Days remaining calculations
- Feature access validation
- Persistence across instances

### PrivacyEngineTests
- Initial privacy level
- Level setting and clamping
- Level descriptions
- Protection toggle
- Blocked connections tracking

## Future Improvements

- [ ] Add UI tests using XCUITest
- [ ] Add integration tests for StoreKit
- [ ] Add network mocking for API tests
- [ ] Set up CI with Xcode Cloud for test automation
