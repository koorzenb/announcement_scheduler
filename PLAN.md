# Announcement Scheduler - Development Plan

This document outlines the phased development plan for the `announcement_scheduler` package. Each phase includes specific goals, tasks, and acceptance criteria.

---

## Phase 1: Fix Scheduled Notification Time Display

**Status**: 🔄 In Progress  
**Priority**: High  
**Started**: November 11, 2025

### Problem Statement

Currently, when viewing scheduled notifications in the "View Scheduled Notifications" dialog, the displayed time shows when the notification was created (via `DateTime.now().millisecondsSinceEpoch ~/ 1000`), not when it is actually scheduled to fire.

**Current Behavior**:
```dart
// In _scheduleOneTimeNotification and _scheduleRecurringNotification
final notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

// Later in getScheduledAnnouncements
final storedTime = scheduledTimes[notification.id.toString()];
final scheduledTime = storedTime != null
    ? DateTime.fromMillisecondsSinceEpoch(storedTime)
    : DateTime.now();
```

The issue: `scheduledTimes` uses the notification ID as a key, but when the notification is created, it uses the current timestamp as the ID. The stored time should be the actual scheduled `TZDateTime`, not the creation time.

### Goals

- [ ] Display the actual scheduled time for notifications in the UI
- [ ] Ensure one-time notifications show the correct future date/time
- [ ] Ensure recurring notifications show the next occurrence time
- [ ] Maintain backward compatibility with existing tests

### Technical Analysis

**Current Flow**:
1. `scheduleOneTimeAnnouncement()` creates notification ID from current timestamp
2. Calls `_scheduleOneTimeNotification()` with `scheduledDate` (correct future time)
3. Stores mapping: `notificationId -> scheduledDate.millisecondsSinceEpoch`
4. `getScheduledAnnouncements()` retrieves this mapping correctly

**Root Cause**:
The code appears to be storing the scheduled time correctly via:
```dart
await _settingsService.setScheduledTime(notificationId, tzDateTime);
```

However, the issue may be in:
- How `setScheduledTime()` persists the data
- How `getScheduledTimes()` retrieves the data
- Type conversion between `tz.TZDateTime` and storage format

### Tasks

#### 1. Investigate Storage Layer
- [ ] Review `SchedulingSettingsService.setScheduledTime()` implementation
- [ ] Review `SchedulingSettingsService.getScheduledTimes()` implementation
- [ ] Verify data is persisted correctly in Hive storage
- [ ] Check for timezone conversion issues

#### 2. Add Debug Logging
- [ ] Add logging in `setScheduledTime()` to verify what's being stored
- [ ] Add logging in `getScheduledTimes()` to verify what's being retrieved
- [ ] Add logging in `getScheduledAnnouncements()` to show the mapping

#### 3. Fix the Issue
- [ ] Identify the exact cause of the time mismatch
- [ ] Implement fix in the appropriate service layer
- [ ] Ensure timezone handling is correct (Halifax: `America/Halifax`)

#### 4. Testing
- [ ] Add unit test for `setScheduledTime()` and `getScheduledTimes()`
- [ ] Add integration test verifying scheduled time display
- [ ] Test one-time announcements
- [ ] Test recurring announcements (should show next occurrence)
- [ ] Verify all existing 28 tests still pass

#### 5. Documentation
- [ ] Update code comments to clarify scheduled time storage
- [ ] Add example in README showing scheduled time display
- [ ] Update CHANGELOG.md with bug fix

### Acceptance Criteria

✅ **Definition of Done**:
1. View Scheduled Notifications dialog shows actual scheduled time, not creation time
2. One-time announcements display the correct future date/time
3. Recurring announcements display the next scheduled occurrence
4. All times are displayed in Halifax timezone (`America/Halifax`)
5. All existing tests pass
6. New tests added to prevent regression
7. Code follows copilot instructions (single quotes, documentation, SOLID principles)

### Testing Checklist

- [ ] **One-time announcement scheduled for 2 hours from now**
  - Expected: Shows time 2 hours in future
  - Actual: _______________
  
- [ ] **Daily recurring announcement at 8:00 AM**
  - Expected: Shows next 8:00 AM occurrence
  - Actual: _______________
  
- [ ] **Custom recurring (Mon, Wed, Fri at 3:00 PM)**
  - Expected: Shows next Mon/Wed/Fri at 3:00 PM
  - Actual: _______________

### Files to Modify

**Primary**:
- `lib/src/services/scheduling_settings_service.dart` - Storage/retrieval logic
- `lib/src/services/hive_storage_service.dart` - Persistence layer

**Secondary** (if needed):
- `lib/src/services/core_notification_service.dart` - May need adjustment
- `test/src/services/scheduling_settings_service_test.dart` - Add tests

**Example App** (verify fix):
- `example/lib/pages/example_home_page.dart` - View scheduled notifications UI

### Notes

- The `flutter_local_notifications` package doesn't expose scheduled times via its API, so we must persist them separately
- Ensure timezone conversions handle Halifax timezone correctly
- Consider edge cases: past times, timezone changes, DST transitions

### Timeline

- **Investigation & Debug**: 1-2 hours
- **Implementation**: 1-2 hours  
- **Testing**: 1 hour
- **Documentation**: 30 minutes

**Estimated Completion**: November 11-12, 2025

---

## Phase 2: Future Enhancements

**Status**: 📋 Planned

### Potential Features
- Add notification action buttons (dismiss, snooze)
- Implement notification grouping for multiple announcements
- Add support for custom notification sounds
- Implement notification history/logs
- Add analytics for announcement delivery success rate

---

## Phase 3: Performance & Optimization

**Status**: 📋 Planned

### Potential Improvements
- Optimize Hive storage queries
- Add caching layer for frequently accessed data
- Reduce memory footprint for long-running apps
- Benchmark notification scheduling performance

---

## Development Workflow

### Before Starting Any Phase
1. Review `copilot-instructions.md` for coding standards
2. Check latest `PRD.md` for requirements (if exists)
3. Run `flutter analyze` to ensure clean baseline
4. Run `flutter test` to ensure all tests pass

### During Development
1. Follow SOLID principles
2. Use single quotes for all strings
3. Add `///` documentation for public APIs
4. Add `reason` property to all test `expect` statements
5. Keep functions under 30-50 lines
6. Use `Enum` instead of `String` where applicable

### Before Committing
1. Run `flutter analyze` - must pass with no issues
2. Run `flutter test` - all tests must pass
3. Update `CHANGELOG.md` using `dart run update_version.dart`
4. Verify changes on physical device (if UI-related)

---

## Glossary

- **TTS**: Text-to-Speech
- **TZDateTime**: Timezone-aware DateTime from the `timezone` package
- **Hive**: Local storage solution used for persistence
- **Halifax**: Default timezone (`America/Halifax`) for all time operations

---

**Last Updated**: November 11, 2025  
**Maintained By**: Development Team
