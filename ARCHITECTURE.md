# Smart Home Architekturstandard

Dieses Dokument ist kein Abbild des aktuellen Dateibestands. Es ist das verbindliche Schema, nach dem neue Features und Änderungen im Smart Home aufgebaut werden.

Die Struktur orientiert sich an den DDD-Prinzipien aus dem [Reso-Coder-DDD-Artikel](https://resocoder.com/2020/03/09/flutter-firebase-ddd-course-1-domain-driven-design-principles/): Features werden über die architektonischen Schichten organisiert, die Domain bleibt unabhängig, und die Application-Schicht koordiniert die Abläufe zwischen UI, Domain und Datenquellen.

## 1. Grundprinzipien

- Die fachliche Sprache des Produkts bestimmt die Feature-Grenzen.
- Die Domain enthält ausschließlich fachliche Regeln und darf keine Flutter-, API-, Datenbank- oder Infrastrukturklassen importieren.
- Die Presentation-Schicht stellt Daten dar und nimmt Benutzereingaben entgegen. Sie enthält keine Repository-Aufrufe und keine fachlichen Berechnungen.
- Die Application-Schicht orchestriert Use Cases, Controller oder BLoCs. Sie entscheidet, was als Nächstes passiert, implementiert aber nicht die eigentliche Infrastruktur.
- Die Infrastructure-Schicht kapselt APIs, Home Assistant, Datenbanken, Sensoren und lokale Speicherung.
- Abhängigkeiten zeigen immer nach innen: Presentation → Application → Domain. Infrastructure → Domain.
- Die konkrete Verdrahtung von Implementierungen erfolgt ausschließlich im Composition Root unter `app/`.
- Features dürfen nicht direkt die Presentation oder Infrastructure eines anderen Features importieren.
- Das State Management erfolgt verbindlich mit `flutter_bloc` und dem BLoC-Muster.

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

Nicht jedes Feature muss jede Schicht besitzen. Ein reines Darstellungs-Feature braucht beispielsweise keine Domain oder Infrastructure. Ordner werden nicht als Platzhalter angelegt.

## 3. Verantwortlichkeiten der Schichten

### Domain

Die Domain ist der fachliche Kern und vollständig framework-unabhängig.

Hier liegen:

- Entitäten mit Identität und fachlicher Bedeutung
- Value Objects, die ungültige Zustände verhindern
- fachliche Berechnungen und Regeln
- erwartbare Fehler als `Failure`-Typen
- Repository-Interfaces, niemals deren Implementierungen

Nicht erlaubt:

- `package:flutter/...`
- HTTP-, Firebase-, Home-Assistant- oder Datenbankklassen
- JSON-Parsing
- Widget-State oder Navigation

### Application

Die Application-Schicht koordiniert einen Ablauf.

Beispiele:

- `LoadEnergyDashboard`
- `SelectEnergyPeriod`
- `RefreshHomeAssistantValues`
- `AddRoomDevice`

Use Cases und Controller dürfen Domain-Verträge verwenden. Sie dürfen aber nicht wissen, ob die Daten aus Home Assistant, einem Cache oder Dummy-Daten kommen.

## 4. State Management: BLoC

Das Projekt verwendet für globalen, Feature- und Seiten-State ausschließlich das BLoC-Muster aus `flutter_bloc`.

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

- Jeder relevante Ablauf wird über ein klar benanntes Event gestartet.
- Jeder BLoC besitzt typisierte States für Initialisierung, Laden, Erfolg und Fehler, sofern diese Zustände auftreten können.
- BLoCs liegen in der Application-Schicht, nicht in `presentation/`.
- Widgets verwenden `BlocProvider`, `BlocBuilder`, `BlocListener` oder `BlocConsumer`.
- Widgets dürfen keine Repositorys direkt aufrufen und keine fachliche State-Logik enthalten.
- `ChangeNotifier`, eigene globale Singleton-States und verstreute `setState`-Logik werden für Feature-State nicht verwendet.
- `setState` ist nur für rein lokale, kurzlebige UI-Zustände erlaubt, zum Beispiel ein temporär geöffnetes Menü.
- Für die globale Navigation wird ein eigener `AppNavigationBloc` verwendet; Energie und Rooms besitzen jeweils eigene Feature-BLoCs.
- `Cubit` wird nicht als Ersatz verwendet, wenn der Ablauf fachliche Events benötigt. Wir verwenden dann den vollständigen BLoC mit Events und States.

Beispielstruktur:

```text
features/energy/application/
├── energy_bloc.dart
├── energy_event.dart
└── energy_state.dart
```

Ein BLoC orchestriert Use Cases und übersetzt deren Ergebnisse in States. Er enthält weder Widget-Code noch direkte API-/Datenbankzugriffe.

### Infrastructure

Infrastructure übersetzt die Außenwelt in Domain-Daten.

Jede externe Quelle wird über drei Bausteine organisiert:

1. `DataSource`: technische Kommunikation mit API, Home Assistant oder Speicher.
2. `Model/DTO`: JSON-nahe Datenstruktur mit `fromJson`/`toJson`.
3. `Repository`: implementiert den Domain-Vertrag, konvertiert DTOs zu Entities und wandelt technische Exceptions in Domain-Failures um.

`try/catch` für technische Quellen gehört in die Repository-Grenze, nicht in Widgets.

### Presentation

Presentation ist Flutter-spezifisch und möglichst „dumm“.

- Pages komponieren den Bildschirm.
- Widgets stellen Werte dar.
- Events werden an Application-Controller oder Use Cases weitergegeben.
- Validierung und fachliche Berechnung gehören nicht in Widgets.
- Feature-Widgets dürfen nur auf das eigene Feature und `core/widgets` zugreifen.

## 5. Globale App-Shell und Navigation

Die globale Shell liegt außerhalb der Features:

```text
app/shell/
├── app_shell.dart
├── app_section.dart
└── app_navigation.dart
```

Die Shell darf nur globale Verantwortlichkeiten enthalten:

- Hintergrund und globales Layout
- globale Navigation
- globale Routen
- generische Slots für seitenspezifische Aktionen

Sie darf keine Energy-, Rooms- oder Home-Widgets importieren, um deren Inhalt selbst zu implementieren. Seitenspezifische Inhalte werden über Routen, Slots oder Composition im `app.dart` eingespeist.

Beispiel für einen neutralen Slot:

```dart
AppNavigationBar(
  trailing: currentPageAction,
)
```

Die Energie-Seite kann dort einen Zeitraum-Selector liefern, Rooms einen Geräte-Button. Die Navigation selbst kennt nur `Widget?` oder einen globalen Vertrag.

## 6. Regeln für Pages und Widgets

- Eine Page gehört genau zu einem Feature.
- Eine Page darf keine andere Feature-Page direkt einbetten.
- Ein Widget kommt in `widgets/`, sobald es außerhalb einer einzelnen Page wiederverwendbar ist.
- Ein Widget kommt in `core/widgets/`, wenn es keine fachliche Bedeutung hat, zum Beispiel `GlassCard`.
- Ein Widget mit Energiebegriffen wie `EnergyChartCard` bleibt unter `features/energy/presentation/widgets`.
- Private Hilfswidgets dürfen in einer Page-Datei bleiben, solange sie nicht wiederverwendet werden.
- Dateien sollen nach ihrer fachlichen Rolle benannt werden, nicht nach einem Sammelbegriff wie `dashboard_page.dart`.

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

Die Rückrichtung liefert Domain-Entities oder `Failure`-Ergebnisse zurück. Widgets kennen weder DTOs noch technische Exceptions.

## 8. Tests

Tests spiegeln die Schichten:

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

Vor dem Anlegen eines neuen Ordners muss geklärt werden:

1. Ist es fachlich ein neues Feature oder nur ein Widget des bestehenden Features?
2. Welche Domain-Entität oder welcher Use Case ist der zentrale Begriff?
3. Welche Datenquelle wird benötigt?
4. Welche Teile sind global und welche gehören ausschließlich zum Feature?
5. Welche Schicht darf die neue Klasse importieren?

Wenn eine Klasse nicht eindeutig einer Schicht zugeordnet werden kann, wird sie nicht in eine Sammeldatei gelegt. Stattdessen wird die Verantwortung zuerst fachlich getrennt.
