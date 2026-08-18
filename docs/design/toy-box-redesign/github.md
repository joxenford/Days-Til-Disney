repo: joxenford/Days-Til-Disney
branch: main
path: ios/Days-Til-Disney

## Last sync
date: 2026-08-16T22:53:00Z

### Updated in this project
- Design system: tokens, 14 components, iOS + website UI kits
- Chosen direction "Toy Box" built out to 14 screens, light and dark
- Attraction rows now show only fields LiveAttraction actually provides
- Earlier paper/letterpress directions kept for reference only
- Recreated the current iOS UI (9 screens + widgets) from SwiftUI source
- Park palettes and milestones lifted verbatim from the repo

## Screen map
| Project screen | Repo files |
|---|---|
| Recreation — Welcome | Features/Onboarding/WelcomeView.swift |
| Recreation — Home / Empty | Features/Home/HomeView.swift, Home/Components/CountdownHeroView.swift, TripCardView.swift, DailyContentCardView.swift |
| Recreation — Trip detail | Features/TripDetail/TripDetailView.swift, LiveParkCard.swift |
| Recreation — Packing list | Features/PackingList/PackingListView.swift, Core/Models/PackingCategory.swift, DefaultPackingItems.swift |
| Recreation — Park dashboard | Features/ParkDashboard/ParkDashboardView.swift |
| Recreation — Add trip | Features/AddEditTrip/AddEditTripView.swift, Components/ParkSelectorView.swift |
| Recreation — Settings | Features/Settings/SettingsView.swift |
| Recreation — Widgets | DaysTilDisneyWidget/DaysTilDisneyWidget.swift |
| Toy Box — all 14 screens | Features/* (Home, TripDetail, AddEditTrip, PackingList, ParkDashboard, Settings, Onboarding, Splash), Core/Models/Milestone.swift, ParkColorPalette.swift, DefaultPackingItems.swift, Engine/LiveParkData/ParkLiveData.swift, DaysTilDisneyWidget/DaysTilDisneyWidget.swift |
| Travel Log — splash | Features/Splash/SplashView.swift |
| Travel Log — milestones | Core/Models/Milestone.swift, DesignSystem/Animations/CelebrationOverlay.swift |
| Travel Log — share cards | Features/TripDetail/ShareCountdownCard.swift |
| Website UI kit | website/index.html, website/styles.css, website/app.js |
| New design (all directions) | DesignSystem/Typography.swift, Core/Models/ParkColorPalette.swift, shared/design/color-palettes.md, Core/Models/DisneyPark.swift, Trip.swift |
