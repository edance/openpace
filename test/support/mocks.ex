# Strava Mocks
Mox.defmock(Squeeze.Strava.MockActivities, for: Strava.ActivitiesBehavior)
Mox.defmock(Squeeze.Strava.MockAuth, for: Strava.AuthBehavior)
Mox.defmock(Squeeze.Strava.MockClient, for: Strava.ClientBehavior)
Mox.defmock(Squeeze.Strava.MockStreams, for: Strava.StreamsBehavior)

# Stripe Mocks
Mox.defmock(Squeeze.Stripe.MockCard, for: Stripe.CardBehavior)
