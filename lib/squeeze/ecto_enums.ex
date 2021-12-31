import EctoEnum

defenum ActivityStatusEnum, pending: 0, complete: 1, incomplete: 2, partial: 3
defenum DistanceUnitEnum, m: 0, km: 1, mi: 2
defenum ExperienceLevelEnum, novice: 0, intermediate: 1, advanced: 2
defenum GenderEnum, male: 0, female: 1, other: 2, prefer_not_to_say: 3
defenum SubscriptionStatusEnum, incomplete: 0, incomplete_expired: 1, trialing: 2,
  active: 3, past_due: 4, canceled: 5, unpaid: 6, free: 7
defenum WorkoutTypeEnum, race: 0, long_run: 1, workout: 2

defenum CourseProfileEnum, unknown: 0, downhill: 1, flat: 2, rolling_hills: 3, hilly: 4
defenum CourseTerrainEnum, unknown: 0, road: 1, trail: 2
defenum CourseTypeEnum, unknown: 0, loop: 1, out_and_back: 2, point_to_point: 3

defenum DistanceTypeEnum, other: 0, marathon: 1, half_marathon: 2, ultra_marathon: 3

# Challenges Enums
defenum ActivityTypeEnum, run: 0, bike: 1, swim: 2, other: 3
defenum ChallengeTypeEnum, distance: 0, time: 1, altitude: 2, segment: 3
defenum TimelineEnum, day: 0, week: 1, weekend: 2, month: 3, custom: 4
