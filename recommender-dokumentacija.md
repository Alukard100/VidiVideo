# VidiVideo Recommendation System Documentation

## 1. Overview

VidiVideo uses a hybrid and explainable recommendation system that combines:

- Content-based personalization
- Collaborative signals
- Popularity-based recommendations
- Cold-start handling
- Watch-completion affinity
- Recommendation explanations
- Subscriber-only access control

The system considers user interactions and preferences such as liked videos, followed and subscribed creators, watch completion, categories, hashtags, and creator location. It also incorporates collaborative recommendations, video popularity, and recency.

The recommender supports both authenticated and guest users:

- **Authenticated users** receive personalized recommendations based on their activity and preferences.
- **Cold-start users** receive popularity-based recommendations when insufficient interaction data is available.
- **Guests** receive public, popularity-based recommendations.
- **Subscriber-only videos** may be recommended to authenticated users, with access reflected through the `IsLocked` property.

Each recommendation includes a human-readable explanation describing why the video was recommended.

The main implementation is located in `RecommendationService`.

## 2. Cold Start

A user is treated as a cold-start user when they:

- have no liked videos,
- follow no creators,
- have no active creator subscriptions,
- have no meaningful video views.

A meaningful view has a completion rate of at least 25%.

## 3. Popularity Score

Popularity uses:

- views,
- likes,
- comments,
- average completion rate,
- recency.

Formula:

```text
Popularity =
    views * 1
    + likes * 5
    + comments * 8
    + averageCompletionRate * 20
    + recencyBonus
```

Recency bonus:

| Video age | Bonus |
|---|---:|
| Up to 1 day | 30 |
| Up to 3 days | 20 |
| Up to 7 days | 10 |
| Up to 30 days | 5 |
| Older than 30 days | 0 |

## 4. Content-Based Score

| Signal | Weight |
|---|---:|
| Same country as creator | +3 |
| Followed creator | +20 |
| Subscribed creator | +40 |
| Each liked video in the same category | +4 |
| Each matching hashtag from liked videos | +2 |

Watch history also affects category and hashtag affinity:

| Completion rate | Weight |
|---|---:|
| 80% or more | +3 |
| 50% to 79% | +2 |
| 25% to 49% | +1 |
| Below 25% | 0 |

## 5. Collaborative Score

Collaborative scores are retrieved through `GetCollaborativeVideoScoreAsync`.

If no collaborative score exists for a candidate, the value is treated as `0`.

## 6. Normalization and Final Score

Content, collaborative and popularity scores are normalized independently using min-max normalization:

```text
normalized = (value - min) / (max - min)
```

If `max <= min`, the normalized value is `0`.

Final score:

```text
Total =
    Content * 0.45
    + Collaborative * 0.30
    + Popularity * 0.25
```

This means:

- content relevance: 45%,
- collaborative relevance: 30%,
- popularity: 25%.

Videos are ordered by this final score.

## 7. Subscriber-Only Videos

Subscriber-only videos may appear in authenticated recommendations.

If the user does not have an active subscription:

- `IsLocked` is `true`,
- the stream URL is not returned.

Guests receive public videos only.

## 8. Recommendation Reasons

The service returns a human-readable reason for each recommendation.

Priority:

1. subscribed creator,
2. followed creator,
3. matching hashtag,
4. matching category,
5. collaborative signal,
6. same-country creator,
7. fallback: `Trending now`.

Examples:

```text
From <creator> you are subscribed to
Because you like #technology
Because you like Gaming
People with similar interests liked this
Popular with creators from your region
Trending now
```

## 9. Data Used

The recommender uses data from:

- Users,
- Videos,
- Likes,
- Follows,
- CreatorSubscriptions,
- VideoViews,
- Categories,
- Hashtags.