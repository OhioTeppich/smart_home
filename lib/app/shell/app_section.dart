enum AppSection { home, energy, livingRoom, bedroom, kitchen, bathroom, hallway }

/// Order of the horizontally swipeable top-level pages. The Energy Analysis
/// drill-down is not part of this sequence — it is local navigation inside
/// the Energie section, not a global AppSection.
const List<AppSection> kTopLevelSections = AppSection.values;
