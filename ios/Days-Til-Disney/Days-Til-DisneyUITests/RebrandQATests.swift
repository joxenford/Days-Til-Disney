//
//  RebrandQATests.swift
//  Days-Til-DisneyUITests
//
//  Visual/simulator QA pass for the "Countdown to Magic" rebrand.
//  Drives the real UI (no seeding hooks exist) and captures a screenshot at each
//  hero surface so a human can eyeball: no castle, the Wish shooting-star mark
//  renders, the toolbar header does not clip/collide, and the Settings > About
//  disclaimer is present. Also empirically checks whether the reviewer-flagged
//  `about.disclaimer` accessibilityIdentifier (on a Section footer) is queryable.
//
//  State is controlled purely via the Foundation NSArgumentDomain launch-arg
//  trick (`-key value` lands in UserDefaults) — no app code changes.
//

import XCTest

final class RebrandQATests: XCTestCase {

    override func setUpWithError() throws {
        // Keep going after a failed assertion so one failed check never aborts
        // the remaining screenshots — the screenshots are the deliverable.
        continueAfterFailure = true
    }

    // MARK: - Helpers

    private func snap(_ app: XCUIApplication, _ name: String) {
        let shot = app.screenshot()
        let a = XCTAttachment(screenshot: shot)
        a.name = name
        a.lifetime = .keepAlways
        add(a)
    }

    private func note(_ name: String, _ body: String) {
        let a = XCTAttachment(string: body)
        a.name = name
        a.lifetime = .keepAlways
        add(a)
    }

    /// Onboarding NOT completed -> Splash + Welcome show first.
    private func makeAppFreshOnboarding(ax5: Bool = false) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += ["-userPrefs.hasCompletedOnboarding", "NO"]
        if ax5 { appendAX5(app) }
        return app
    }

    /// Onboarding completed -> lands directly on Home (empty if app was uninstalled).
    private func makeAppAtHome(ax5: Bool = false) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += ["-userPrefs.hasCompletedOnboarding", "YES"]
        if ax5 { appendAX5(app) }
        return app
    }

    private func appendAX5(_ app: XCUIApplication) {
        app.launchArguments += ["-UIPreferredContentSizeCategoryName",
                                "UICTContentSizeCategoryAccessibilityXXXL"]
    }

    /// Dismiss a SpringBoard system alert (e.g. notification permission) by tapping
    /// the first matching button label. No-op if no alert appears.
    private func dismissSystemAlert(_ labels: [String]) {
        let sb = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        for label in labels {
            let b = sb.buttons[label]
            if b.waitForExistence(timeout: 3) {
                b.tap()
                return
            }
        }
    }

    // MARK: - Full walkthrough (all hero surfaces)

    @MainActor
    func test_walkthrough() throws {
        let app = makeAppFreshOnboarding()
        app.launch()

        // 01 — Splash. Grab immediately; splash auto-advances after ~2.2s.
        snap(app, "01-splash")

        // 02 — Welcome / Onboarding.
        let createFirst = app.buttons["Create your first trip"]
        if createFirst.waitForExistence(timeout: 6) {
            snap(app, "02-welcome")
            createFirst.tap()
        } else {
            note("02-welcome-MISSING",
                 "Welcome 'Create your first trip' button not found within 6s. "
                 + "Splash may not have advanced or onboarding was already completed.")
        }

        // 03 — Add-Trip form. Type a name so 'Create Trip' becomes enabled.
        let nameField = app.textFields["Trip name"]
        if nameField.waitForExistence(timeout: 6) {
            snap(app, "03-addtrip")
            nameField.tap()
            nameField.typeText("QA Magic Trip")
            snap(app, "03b-addtrip-named")
            // Swipe up: Form's default .interactively dismisses the keyboard and
            // scrolls the "Create Trip" button (last section, below the fold) up.
            app.swipeUp()
            // .tap() auto-scrolls the element to visible, so no isHittable gate.
            let create = app.buttons["Create Trip"]
            if create.waitForExistence(timeout: 3) {
                create.tap()
            } else {
                note("03-save-MISSING", "Could not find the Create Trip save button after swipe-up.")
            }
            // First trip save requests notification permission -> dismiss the system alert.
            dismissSystemAlert(["Allow", "Allow While Using App", "Don’t Allow", "OK"])
        } else {
            note("03-addtrip-MISSING", "Add-Trip 'Trip name' field not found within 6s.")
        }

        // 04 — Populated Home. Wait for the toolbar header to settle.
        let header = app.staticTexts["Countdown to Magic"]
        _ = header.waitForExistence(timeout: 8)
        // Give the countdown hero a beat to render.
        sleep(1)
        snap(app, "04-home-populated")

        // 05 — Trip Detail. Tap the hero card (top-center, below the toolbar).
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.34)).tap()
        sleep(1)
        snap(app, "05-tripdetail")

        // 06 — Share sheet (system UIActivityViewController; renders ShareCountdownCard).
        let share = app.buttons["Share countdown"]
        if share.waitForExistence(timeout: 5) {
            share.tap()
            sleep(2)
            snap(app, "06-sharesheet")
            // Dismiss the share sheet.
            app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.05)).tap()
            app.swipeDown()
        } else {
            note("06-share-MISSING",
                 "'Share countdown' button not found on Trip Detail within 5s "
                 + "(hero tap may not have navigated to detail).")
        }

        // Back to Home.
        let backBtn = app.navigationBars.buttons.element(boundBy: 0)
        if backBtn.exists { backBtn.tap() }
        sleep(1)

        // 07 — Settings > About disclaimer.
        let settings = app.buttons["Settings"]
        if settings.waitForExistence(timeout: 5) {
            settings.tap()
            checkDisclaimer(app)
        } else {
            note("07-settings-MISSING", "'Settings' toolbar button not found within 5s.")
        }
    }

    /// Item 4: empirically verify the disclaimer text is present AND record whether
    /// the `about.disclaimer` accessibilityIdentifier (on a Section footer) resolves.
    @MainActor
    private func checkDisclaimer(_ app: XCUIApplication) {
        let unofficial = NSPredicate(format: "label CONTAINS[c] 'unofficial app'")
        var footer = app.staticTexts.containing(unofficial).firstMatch

        // Scroll the footer into view.
        var tries = 0
        while !footer.exists && tries < 6 {
            app.swipeUp()
            footer = app.staticTexts.containing(unofficial).firstMatch
            tries += 1
        }

        let textPresent = footer.exists
        snap(app, "07-about-disclaimer")

        // Does the accessibilityIdentifier resolve, across any element type?
        let byIdAny = app.descendants(matching: .any).matching(identifier: "about.disclaimer").firstMatch
        let byIdStatic = app.staticTexts["about.disclaimer"]
        let idResolvesAny = byIdAny.exists
        let idResolvesStatic = byIdStatic.exists

        // Exact-text confirmation (item 4 asks for the precise string).
        let exact = "Countdown to Magic is an unofficial app. Not affiliated with, endorsed by, or sponsored by The Walt Disney Company."
        let exactPresent = app.staticTexts.containing(
            NSPredicate(format: "label == %@", exact)).firstMatch.exists

        note("07-disclaimer-RESULT",
             """
             disclaimer text visible (contains 'unofficial app'): \(textPresent)
             disclaimer EXACT text present: \(exactPresent)
             accessibilityIdentifier 'about.disclaimer' resolves (any element): \(idResolvesAny)
             accessibilityIdentifier 'about.disclaimer' resolves (staticTexts): \(idResolvesStatic)
             """)

        // Content check should pass; identifier check is recorded, not fatal.
        XCTAssertTrue(textPresent, "Disclaimer text not visible in Settings > About")
        XCTAssertTrue(exactPresent, "Exact disclaimer string not found")
        if !idResolvesAny {
            XCTContext.runActivity(named: "FINDING: about.disclaimer identifier not XCUITest-queryable") { _ in }
        }
    }

    // MARK: - Header at AX5 (item 3: .fixedSize() clip / collision on compact width)

    @MainActor
    func test_homeHeaderAX5() throws {
        let app = makeAppAtHome(ax5: true)
        app.launch()

        let header = app.staticTexts["Countdown to Magic"]
        _ = header.waitForExistence(timeout: 8)
        sleep(1)
        snap(app, "08-home-header-ax5")

        note("08-header-AX5-RESULT",
             "header 'Countdown to Magic' exists at AX5: \(header.exists); "
             + "frame: \(header.exists ? "\(header.frame)" : "n/a"); "
             + "app window: \(app.windows.firstMatch.frame)")
    }

    // MARK: - Header at default type (item 3 baseline + item 1 empty-state hero)

    @MainActor
    func test_homeHeaderDefault() throws {
        let app = makeAppAtHome()
        app.launch()
        let header = app.staticTexts["Countdown to Magic"]
        _ = header.waitForExistence(timeout: 8)
        sleep(1)
        snap(app, "09-home-empty-default")
    }
}
