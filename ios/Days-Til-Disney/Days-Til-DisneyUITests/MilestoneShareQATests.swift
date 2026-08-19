//
//  MilestoneShareQATests.swift
//  Days-Til-DisneyUITests
//
//  Verifies the milestone screen's "Share it" button actually presents the system
//  share sheet — and, critically, that it presents a SECOND time after the first
//  one is dismissed. UIActivityViewController dismisses itself, so a share flag
//  that is never cleared yields a button that works exactly once per visit.
//
//  Same launch-arg state control as RebrandQATests; no seeding hooks exist, so the
//  test creates its trip through the real UI (default start date is today + 30,
//  which leaves a milestone below it and keeps the "Next up" tile tappable).
//

import XCTest

final class MilestoneShareQATests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = true
    }

    private func snap(_ app: XCUIApplication, _ name: String) {
        let a = XCTAttachment(screenshot: app.screenshot())
        a.name = name
        a.lifetime = .keepAlways
        add(a)
    }

    /// The system share sheet, matched by the activity list's stable identifier with
    /// a fallback on the always-present "Copy" activity.
    private func shareSheetVisible(_ app: XCUIApplication, timeout: TimeInterval = 6) -> Bool {
        let list = app.otherElements["ActivityListView"]
        if list.waitForExistence(timeout: timeout) { return true }
        return app.buttons["Copy"].waitForExistence(timeout: 2)
            || app.collectionViews.firstMatch.waitForExistence(timeout: 2)
    }

    /// The activity sheet's own dismiss control — `header.closeButton` (label "close").
    /// Falls back to a swipe for any OS version that drops the header button.
    private func dismissShareSheet(_ app: XCUIApplication) {
        let close = app.buttons["header.closeButton"]
        if close.waitForExistence(timeout: 3) {
            close.tap()
        } else {
            app.swipeDown(velocity: .fast)
        }
        // Wait for the sheet to actually leave before the next assertion.
        let gone = NSPredicate(format: "exists == false")
        expectation(for: gone, evaluatedWith: app.otherElements["ActivityListView"])
        waitForExpectations(timeout: 6)
    }

    @MainActor
    func test_milestoneShareButton_presentsSheetAndRepresentsAfterDismiss() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-userPrefs.hasCompletedOnboarding", "NO"]
        app.launch()

        // Create a trip (default start = today + 30).
        let createFirst = app.buttons["Create your first trip"]
        XCTAssertTrue(createFirst.waitForExistence(timeout: 10), "Welcome screen never appeared")
        createFirst.tap()

        let nameField = app.textFields["Trip name"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 6), "Add-Trip form never appeared")
        nameField.tap()
        nameField.typeText("Share QA Trip")
        app.swipeUp()
        let create = app.buttons["Create Trip"]
        XCTAssertTrue(create.waitForExistence(timeout: 3), "Create Trip button not found")
        create.tap()

        // First save asks for notification permission.
        let sb = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        for label in ["Allow", "Allow While Using App", "Don’t Allow", "OK"] {
            let b = sb.buttons[label]
            if b.waitForExistence(timeout: 3) { b.tap(); break }
        }

        _ = app.staticTexts["Countdown to Magic"].waitForExistence(timeout: 10)
        sleep(1)
        snap(app, "01-home")

        // A trip 30 days out lands exactly on the 30-day milestone, so the trigger
        // pushes MilestoneView on its own. Fall back to Home's "Next up" tile if a
        // future default ever stops landing on a threshold.
        let shareIt = app.buttons["Share it"]
        if !shareIt.waitForExistence(timeout: 6) {
            let nextUp = app.buttons.containing(
                NSPredicate(format: "label CONTAINS[c] 'Next up'")).firstMatch
            XCTAssertTrue(nextUp.waitForExistence(timeout: 6),
                          "Neither the milestone screen nor Home's 'Next up' tile appeared")
            nextUp.tap()
        }
        XCTAssertTrue(shareIt.waitForExistence(timeout: 6), "Milestone screen 'Share it' button not found")
        snap(app, "02-milestone")

        // First tap.
        shareIt.tap()
        XCTAssertTrue(shareSheetVisible(app), "Share sheet did not appear on the first tap")
        snap(app, "03-sharesheet-first")
        dismissShareSheet(app)

        // Second tap — the regression this test exists for.
        XCTAssertTrue(shareIt.waitForExistence(timeout: 6), "Returned to a screen without 'Share it'")
        XCTAssertTrue(shareIt.isHittable, "'Share it' is still covered after dismissing the first share sheet")
        shareIt.tap()
        XCTAssertTrue(shareSheetVisible(app),
                      "Share sheet did not re-present after dismissal — the share image flag is never cleared")
        snap(app, "04-sharesheet-second")
        dismissShareSheet(app)
    }
}
