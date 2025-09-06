# activite6

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

# Gestion Notes – Flutter App

[![Flutter](https://img.shields.io/badge/Flutter-3.13-blue.svg)](https://flutter.dev/)

Une application Flutter simple pour gérer **utilisateurs** et **notes**, compatible **Web, Android et iOS**.

---

## Fonctionnalités

* Inscription / Connexion utilisateurs
* Ajouter, modifier et supprimer des notes
* Déconnexion
* Support Web avec **sqflite\_common\_ffi\_web** (Web Worker)

---

## Installation

1. **Cloner le projet**

```bash
git clone https://github.com/Simeonaho/flutter-.git
cd activite6
```

2. **Installer les dépendances**

```bash
flutter pub get
```

3. **Configurer pour Web** (si nécessaire)

```bash
dart run sqflite_common_ffi_web:setup
```

Vérifie que `sqflite_sw.js` et `sqlite3.wasm` sont dans `web/`.

Dans `web/index.html` :

```html
<script src="sqflite_sw.js" defer></script>
```

4. **Lancer l’application**

* Web :

```bash
flutter run -d chrome
```

* Android / iOS :

```bash
flutter run
```

---

## Utilisation

* **Ajouter une note** : bouton 
* **Modifier une note** : icône 
* **Supprimer une note** : icône 
* **Déconnexion** : icône logout en haut à droite

---

## Notes techniques

* Tables : `users` et `notes`
* Sur Web : WebAssembly + Web Worker pour SQLite
* Pour multi-utilisateurs : filtrer les notes par `userId`

---

## FAQ

**Q : Erreur `SqfliteFfiWebException` sur Web ?**

* Vérifie la présence de `sqflite_sw.js` et `sqlite3.wasm` dans `web/`
* Vérifie que `<script src="sqflite_sw.js" defer></script>` est dans `index.html`

**Q : Je veux tester uniquement sur mobile**

* Les fichiers Web ne sont pas nécessaires, le mode natif `sqflite` fonctionne automatiquement.
