# DateNight iOS — MVP Implementation Plan

> Generated 2026-03-28 from full screen-by-screen audit of all 37 screens.
> **87 tasks** across 6 categories. Every ViewModel is mocked except FeedbackChatViewModel.

---

## Priority Legend

| Priority | Meaning |
|----------|---------|
| P0 | **Blocker** — nothing else works without this |
| P1 | **Core functionality** — essential for MVP launch |
| P2 | **Important UX** — needed for a polished MVP |
| P3 | **Nice to have** — can ship without, but should follow soon |

---

## Phase 1: Foundation (P0 — Do First)

These tasks unblock everything else. Auth and real user data must come first.

| # | Task | Screen Area |
|---|------|-------------|
| 2 | Wire AuthViewModel to Supabase Auth | Auth |
| 1 | Add loading state to ContentView during auth check | Navigation |
| 5 | Add Face ID / biometric authentication | Auth |
| 72 | Wire ProfileViewModel to Supabase for real user data | Profile |
| 13 | Persist profileComplete flag via backend instead of UserDefaults | Navigation |
| 7 | Wire ProfileSetupViewModel.completeSetup() to Supabase | Onboarding |
| 6 | Implement real photo picker and upload in ProfileSetup | Onboarding |

---

## Phase 2: Core Data (P1 — Wire All ViewModels to Supabase)

Replace every mocked ViewModel with real Supabase queries.

### Events & Feed
| # | Task | Screen Area |
|---|------|-------------|
| 20 | Wire FeedViewModel to fetch events from Supabase | Feed |
| 21 | Persist event likes to Supabase | Feed |
| 26 | Wire EventSwipeViewModel to Supabase and persist swipe actions | Events |
| 30 | Wire AddEventViewModel.createEvent() to Supabase | Events |
| 34 | Wire MyEventsViewModel to Supabase | Events |
| 39 | Wire EventDetailView comments to Supabase | EventDetail |
| 43 | Wire CreateDateSheet to Supabase | EventDetail |

### Discover & Matching
| # | Task | Screen Area |
|---|------|-------------|
| 45 | Wire DiscoverViewModel to Supabase for user discovery | Discover |
| 51 | Connect SwipeFiltersView to DiscoverViewModel | Discover |
| 55 | Wire MatchesViewModel to Supabase for date requests | Matches |
| 56 | Implement joinDate() with backend call and UI update | Matches |

### Dates
| # | Task | Screen Area |
|---|------|-------------|
| 59 | Wire MyDatesViewModel to Supabase | Dates |
| 60 | Wire DateDetailViewModel confirm/cancel to Supabase | Dates |
| 61 | Wire InviteToDateViewModel to Supabase | Dates |
| 62 | Wire EventAgreementViewModel to Supabase with real-time sync | Dates |

### Chat (Realtime)
| # | Task | Screen Area |
|---|------|-------------|
| 65 | Wire ChatListViewModel to Supabase with Realtime | Chat |
| 66 | Wire ConversationChatViewModel to Supabase with Realtime | Chat |
| 67 | Wire GroupChatViewModel to Supabase with Realtime | Chat |

### Profile & Settings
| # | Task | Screen Area |
|---|------|-------------|
| 73 | Wire ProfileEditViewModel save and photo upload to Supabase | Profile |
| 74 | Wire MatchPreferencesViewModel to Supabase | Profile |
| 83 | Wire SettingsViewModel to Supabase and implement all actions | Settings |

### Social
| # | Task | Screen Area |
|---|------|-------------|
| 79 | Wire FriendsViewModel to Supabase | Friends |
| 80 | Wire RateMatchViewModel.submitRating() to Supabase | Rating |
| 81 | Wire MyReviewsViewModel to Supabase | Rating |
| 82 | Wire NotificationsViewModel to Supabase and add navigation | Notifications |
| 85 | Wire ReportUserViewModel to Supabase | Safety |

---

## Phase 3: Missing Core Features (P1)

Functionality that must exist for the app to make sense.

### Auth & Validation
| # | Task | Screen Area |
|---|------|-------------|
| 3 | Add basic input validation to Login and SignUp | Auth |
| 15 | Add password confirmation validation in SignUpView | Auth |
| 16 | Add email format and password strength validation | Auth |
| 17 | Implement Remember Me functionality in LoginView | Auth |

### Navigation & Infrastructure
| # | Task | Screen Area |
|---|------|-------------|
| 11 | Add programmatic tab switching for notifications | Navigation |
| 14 | Add deep link handling to ContentView | Navigation |
| 9 | Add tab badge indicators to MainTabView | Navigation |
| 12 | Verify DNTabButton component exists and works | Navigation |

### Events
| # | Task | Screen Area |
|---|------|-------------|
| 31 | Wire image picker in AddEventView | Events |
| 35 | Implement edit event flow from MyEventsView | Events |
| 41 | Add RSVP/"I'm going" action to EventDetailView | EventDetail |
| 40 | Implement share button in EventDetailView | EventDetail |
| 33 | Add capacity/total spots field to AddEventView | Events |
| 44 | Add user selection/invitation to CreateDateSheet | EventDetail |

### Discover
| # | Task | Screen Area |
|---|------|-------------|
| 46 | Fix infinite cycling in UserSwipeView | Discover |
| 47 | Navigate to chat from MatchDetailView "Send Message" | Discover |
| 48 | Calculate real distance in SwipeCardView | Discover |
| 49 | Wire info button on SwipeCardView | Discover |
| 50 | Add photo carousel to SwipeCardView | Discover |
| 52 | Add gender preference filter to SwipeFiltersView | Discover |
| 53 | Use real current user data in MatchDetailView | Discover |
| 75 | Wire UserProfileModal action buttons | Profile |

### Chat
| # | Task | Screen Area |
|---|------|-------------|
| 68 | Implement photo/image sending in chat | Chat |
| 69 | Wire phone and video call buttons in ConversationChatView | Chat |
| 70 | Add read receipts and delivery status to messages | Chat |

### Misc
| # | Task | Screen Area |
|---|------|-------------|
| 77 | Wire settings gear button in ProfileView photo gallery | Profile |
| 76 | Remove dev-only settings items from ProfileView | Profile |
| 84 | Wire HelpSupportView report submission and contact email | Settings |

---

## Phase 4: UX Polish (P2)

Important for a good experience but not blocking core functionality.

| # | Task | Screen Area |
|---|------|-------------|
| 10 | Preserve tab state when switching in MainTabView | Navigation |
| 22 | Add pagination/infinite scroll to FeedView | Feed |
| 23 | Add empty state to FeedView for no matching events | Feed |
| 25 | Add search functionality to FeedView | Feed |
| 27 | Add undo/rewind last swipe in EventSwipeView | Events |
| 29 | Add tap-to-expand on EventSwipeCardView | Events |
| 36 | Add delete confirmation in MyEventsView | Events |
| 38 | Add pull-to-refresh to MyEventsView | Events |
| 58 | Add pull-to-refresh and loading state to MatchesView | Matches |
| 64 | Add cancel confirmation dialog to DateDetailView | Dates |
| 87 | Add friend removal confirmation dialog | Friends |
| 18 | Add height field validation and unit label in ProfileSetup | Onboarding |
| 19 | Fetch interests from backend instead of hardcoded list | Onboarding |

---

## Phase 5: Localization (P2)

The app has a mix of hardcoded English and Spanish. All strings need to use localization keys.

| # | Task | Screen Area |
|---|------|-------------|
| 4 | Localize hardcoded strings in ForgotPasswordView | Auth |
| 8 | Localize hardcoded strings in ProfileSetupView | Onboarding |
| 24 | Localize "Ver Detalles" button in EventCardView | Feed |
| 28 | Localize hardcoded strings in EventSwipeView | Events |
| 32 | Localize hardcoded strings in AddEventView | Events |
| 37 | Localize hardcoded strings in MyEventsView | Events |
| 42 | Localize hardcoded strings in EventDetailView and CreateDateSheet | EventDetail |
| 54 | Localize hardcoded strings in Discover screens | Discover |
| 57 | Localize hardcoded Spanish strings in MatchesView and DateRequestCard | Matches |
| 63 | Localize hardcoded strings in all Dates screens | Dates |
| 71 | Localize hardcoded strings in all Chat screens | Chat |
| 78 | Localize hardcoded strings in all Profile screens | Profile |
| 86 | Localize hardcoded strings in Friends, Rating, Notifications, Settings, Safety, and Feedback screens | Remaining |

---

## Summary by Screen Area

| Area | Total Tasks | Supabase Wiring | Missing Features | Localization | UX Polish |
|------|-------------|-----------------|------------------|--------------|-----------|
| Navigation/Shell | 7 | 1 | 4 | 0 | 2 |
| Auth | 7 | 1 | 5 | 1 | 0 |
| Onboarding | 5 | 2 | 1 | 1 | 1 |
| Feed | 6 | 2 | 1 | 1 | 2 |
| Events | 13 | 4 | 4 | 3 | 2 |
| EventDetail | 6 | 2 | 3 | 1 | 0 |
| Discover | 10 | 2 | 7 | 1 | 0 |
| Matches | 4 | 2 | 0 | 1 | 1 |
| Dates | 6 | 4 | 0 | 1 | 1 |
| Chat | 7 | 3 | 3 | 1 | 0 |
| Profile | 7 | 3 | 3 | 1 | 0 |
| Friends | 2 | 1 | 0 | 0 | 1 |
| Rating | 2 | 2 | 0 | 0 | 0 |
| Notifications | 1 | 1 | 0 | 0 | 0 |
| Settings | 3 | 1 | 1 | 0 | 0 |
| Safety | 1 | 1 | 0 | 0 | 0 |
| Feedback | 0 | 0 | 0 | 0 | 0 |
| **Cross-cutting** | 0 | 0 | 0 | **1** | 0 |
| **TOTAL** | **87** | **32** | **32** | **13** | **10** |

---

## The One Bright Spot

**FeedbackChatView** is fully functional with real Claude API + Supabase integration. It's the only screen with real backend connectivity and can serve as a reference pattern for wiring other ViewModels.

---

## Recommended Execution Order

1. **Phase 1** (7 tasks) — Auth + user foundation. ~2-3 days.
2. **Phase 2** (26 tasks) — Supabase wiring. Parallelize by feature area. ~5-7 days.
3. **Phase 3** (28 tasks) — Missing features. Many can run parallel with Phase 2. ~3-5 days.
4. **Phase 4** (13 tasks) — UX polish. ~2-3 days.
5. **Phase 5** (13 tasks) — Localization. Can batch with a single pass. ~1-2 days.
