/// The time-range filter used to request analytics data.
///
/// This is a domain concept (it drives fetch-parameter computation in
/// `computeAnalyticsParams`), not UI state — it lives here so the domain
/// layer never has to depend on presentation to know what a filter is.
enum AnalyticsFilter {
  latest,
  lastHour,
  last2Hours,
  last6Hours,
  last12Hours,
  last24Hours,
  custom,
}
