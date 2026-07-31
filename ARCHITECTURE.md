# Smart Home Architekturstandard

Dokument kein Abbild aktuellen Dateibestands. Verbindliches Schema für neue Features und Änderungen im Smart Home.

Struktur folgt DDD-Prinzipien aus [Reso-Coder-DDD-Artikel](https://resocoder.com/2020/03/09/flutter-firebase-ddd-course-1-domain-driven-design-principles/): Features organisiert über architektonische Schichten, Domain bleibt unabhängig, Application-Schicht koordiniert Abläufe zwischen UI, Domain und Datenquellen.

## 1. Grundprinzipien

- Fachliche Sprache Produkts bestimmt Feature-Grenzen.
- Domain enthält nur fachliche Regeln. Keine Flutter-, API-, Datenbank- oder Infrastrukturklassen-Imports.
- Presentation-Schicht stellt Daten dar, nimmt Eingaben entgegen. Keine Repository-Aufrufe, keine fachlichen Berechnungen.
- Application-Schicht orchestriert Use Cases, Controller, BLoCs. Entscheidet nächsten Schritt, implementiert Infrastruktur nicht selbst.
- Infrastructure-Schicht kapselt APIs, Home Assistant, Datenbanken, Sensoren, lokale Speicherung.
- Abhängigkeiten immer nach innen: Presentation → Application → Domain. Infrastructure → Domain.
- Konkrete Verdrahtung von Implementierungen nur im Composition Root unter `app/`.
- Features importieren nicht direkt Presentation oder Infrastructure anderer Features.
- State Management verbindlich mit `flutter_bloc` und BLoC-Muster.

## 2. Verbindliche Projektstruktur

```text
lib/
├── main.dart                         # Nur runApp und Prozess-Einstieg
├── app.dart                          # Composition Root
│
├── app/
│   ├── shell/                        # Globales Layout und globale Navigation
│   └── routing/                      # Globale Routen und Deep Links
│
├── core/
│   ├── theme/                        # Design-System
│   ├── widgets/                      # Feature-neutrale UI-Bausteine
│   ├── errors/                       # Globale technische Fehler, falls nötig
│   └── utils/                        # Kleine, wirklich globale Hilfsfunktionen
│
└── features/
    └── {feature}/
        ├── domain/
        │   ├── entities/             # Fachliche Entitäten
        │   ├── value_objects/        # Validierte fachliche Werte
        │   ├── failures/             # Erwartbare fachliche Fehler
        │   ├── repositories/         # Abstrakte Verträge
        │   └── services/             # Fachliche Domain-Services
        │
        ├── application/
        │   ├── use_cases/            # Ein klar abgegrenzter Anwendungsfall pro Klasse
        │   ├── controllers/          # UI-unabhängige Orchestrierung und State
        │   └── state/                 # Events/States oder View-State-Verträge
        │
        ├── infrastructure/
        │   ├── data_sources/         # REST, Home Assistant, Firebase, lokale Quellen
        │   ├── models/                # DTOs und Serialisierung
        │   └── repositories/         # Implementierungen der Domain-Verträge
        │
        └── presentation/
            ├── pages/                # Seiten und Navigation innerhalb des Features
            ├── widgets/              # Feature-spezifische Widgets
            └── components/           # Größere UI-Kompositionen, falls erforderlich
```

Nicht jedes Feature braucht jede Schicht. Reines Darstellungs-Feature z.B. ohne Domain oder Infrastructure. Ordner nicht als Platzhalter anlegen.

## 3. Verantwortlichkeiten der Schichten

### Domain

Fachlicher Kern, vollständig framework-unabhängig.

Enthält:

- Entitäten mit Identität und fachlicher Bedeutung
- Value Objects gegen ungültige Zustände
- fachliche Berechnungen und Regeln
- erwartbare Fehler als `Failure`-Typen
- Repository-Interfaces, nie deren Implementierungen

Nicht erlaubt:

- `package:flutter/...`
- HTTP-, Firebase-, Home-Assistant- oder Datenbankklassen
- JSON-Parsing
- Widget-State oder Navigation

### Application

Application-Schicht koordiniert Ablauf.

Beispiele:

- `LoadEnergyDashboard`
- `SelectEnergyPeriod`
- `RefreshHomeAssistantValues`
- `AddRoomDevice`

Use Cases und Controller nutzen Domain-Verträge. Wissen nicht, ob Daten aus Home Assistant, Cache oder Dummy-Daten kommen.

## 4. State Management: BLoC

Projekt nutzt für globalen, Feature- und Seiten-State ausschließlich BLoC-Muster aus `flutter_bloc`.

```text
Presentation Widget
    ↓ Event
Feature BLoC
    ↓ Use Case / Repository-Vertrag
Application + Domain
    ↓ State
Presentation Widget
```

Verbindliche Regeln:

- Jeder relevante Ablauf startet über klar benanntes Event.
- Jeder BLoC hat typisierte States für Initialisierung, Laden, Erfolg, Fehler (soweit Zustände auftreten können).
- BLoCs liegen in Application-Schicht, nicht in `presentation/`.
- Widgets nutzen `BlocProvider`, `BlocBuilder`, `BlocListener` oder `BlocConsumer`.
- Widgets rufen Repositorys nicht direkt auf, keine fachliche State-Logik.
- `ChangeNotifier`, eigene globale Singleton-States, verstreute `setState`-Logik: nicht für Feature-State.
- `setState` nur für rein lokale, kurzlebige UI-Zustände erlaubt, z.B. temporär geöffnetes Menü.
- Globale Navigation: eigener `AppNavigationBloc`; Energie und Rooms je eigene Feature-BLoCs.
- `Cubit` kein Ersatz, wenn Ablauf fachliche Events braucht. Dann vollständiger BLoC mit Events und States.

Beispielstruktur:

```text
features/energy/application/
├── energy_bloc.dart
├── energy_event.dart
└── energy_state.dart
```

BLoC orchestriert Use Cases, übersetzt Ergebnisse in States. Kein Widget-Code, keine direkten API-/Datenbankzugriffe.

### Infrastructure

Infrastructure übersetzt Außenwelt in Domain-Daten.

Jede externe Quelle über drei Bausteine:

1. `DataSource`: technische Kommunikation mit API, Home Assistant oder Speicher.
2. `Model/DTO`: JSON-nahe Datenstruktur mit `fromJson`/`toJson`.
3. `Repository`: implementiert Domain-Vertrag, konvertiert DTOs zu Entities, wandelt technische Exceptions in Domain-Failures um.

`try/catch` für technische Quellen gehört in Repository-Grenze, nicht in Widgets.

### Presentation

Presentation ist Flutter-spezifisch, möglichst „dumm".

- Pages komponieren Bildschirm.
- Widgets stellen Werte dar.
- Events gehen an Application-Controller oder Use Cases.
- Validierung und fachliche Berechnung gehören nicht in Widgets.
- Feature-Widgets greifen nur auf eigenes Feature und `core/widgets` zu.

## 5. Globale App-Shell und Navigation

Globale Shell liegt außerhalb der Features:

```text
app/shell/
├── app_shell.dart
├── app_section.dart
└── app_navigation.dart
```

Shell enthält nur globale Verantwortlichkeiten:

- Hintergrund und globales Layout
- globale Navigation
- globale Routen
- generische Slots für seitenspezifische Aktionen

Keine Energy-, Rooms- oder Home-Widget-Imports zur eigenen Implementierung. Seitenspezifische Inhalte über Routen, Slots oder Composition in `app.dart` eingespeist.

Beispiel neutraler Slot:

```dart
AppNavigationBar(
  trailing: currentPageAction,
)
```

Energie-Seite liefert dort Zeitraum-Selector, Rooms einen Geräte-Button. Navigation selbst kennt nur `Widget?` oder globalen Vertrag.

## 6. Regeln für Pages und Widgets

- Page gehört genau zu einem Feature.
- Page bettet keine andere Feature-Page direkt ein.
- Widget kommt in `widgets/`, sobald außerhalb einzelner Page wiederverwendbar.
- Widget kommt in `core/widgets/`, wenn keine fachliche Bedeutung, z.B. `GlassCard`.
- Widget mit Energiebegriffen wie `EnergyChartCard` bleibt unter `features/energy/presentation/widgets`.
- Private Hilfswidgets dürfen in Page-Datei bleiben, solange nicht wiederverwendet.
- Dateien benannt nach fachlicher Rolle, nicht nach Sammelbegriff wie `dashboard_page.dart`.

## 7. Datenfluss

```text
User interaction
    ↓
Presentation Page / Widget
    ↓
Application Controller oder Use Case
    ↓
Domain Repository Interface
    ↓
Infrastructure Repository
    ↓
Data Source / Home Assistant / Local Storage
```

Rückrichtung liefert Domain-Entities oder `Failure`-Ergebnisse zurück. Widgets kennen weder DTOs noch technische Exceptions.

## 8. Tests

Tests spiegeln Schichten:

```text
test/
├── features/{feature}/domain/
├── features/{feature}/application/
├── features/{feature}/infrastructure/
└── features/{feature}/presentation/
```

- Domain: reine Unit-Tests ohne Flutter
- Application: Use Cases und State-Übergänge mit Fake-Repositories
- Infrastructure: DTO-Mapping und Repository-Verhalten mit Fake-Data-Sources
- Presentation: Widget- und Navigations-Tests
- App: Shell- und Routing-Integrationstests

## 9. Neue Features: Entscheidungsregeln

Vor Anlegen neuen Ordners klären:

1. Fachlich neues Feature oder nur Widget bestehenden Features?
2. Welche Domain-Entität oder Use Case zentraler Begriff?
3. Welche Datenquelle nötig?
4. Was global, was nur zum Feature?
5. Welche Schicht darf neue Klasse importieren?

Klasse nicht eindeutig einer Schicht zuordenbar → nicht in Sammeldatei. Verantwortung zuerst fachlich trennen.