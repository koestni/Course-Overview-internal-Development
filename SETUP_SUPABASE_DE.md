# Supabase Setup für Anfänger (Schritt für Schritt)

Diese Anleitung zeigt dir ganz konkret, wie du deine Kursübersicht mit Login und persönlichem Bereich (**„Mein Studium“**) einrichtest.

---

## Zielbild

- **Alle angemeldeten Nutzer sehen alle Kurse** in der Übersicht.
- **Jeder Nutzer sieht in „Mein Studium“ nur seine eigenen gespeicherten Kurse/Semester**.
- Ohne Login ist die Seite gesperrt (Auth-Gate).

---

## 1) Supabase-Projekt anlegen

1. Gehe auf https://supabase.com und melde dich an.
2. Klicke auf **New project**.
3. Wähle Name + Passwort + Region.
4. Warte, bis das Projekt fertig erstellt ist.

---

## 2) Auth (Login) aktivieren

1. Im Supabase-Dashboard links auf **Authentication**.
2. Unter **Providers**: **Email** aktivieren.
3. Für den Anfang kannst du „Confirm email“ optional deaktivieren (einfacher Test).
   - Später für Produktion besser aktivieren.

---

## 3) Datenbank-Struktur erstellen

1. Im Dashboard auf **SQL Editor**.
2. Datei `supabase_auth_setup.sql` aus diesem Repo öffnen/kopieren.
3. SQL komplett ausführen.
4. Prüfen unter **Table Editor**, dass diese Tabellen existieren:
   - `courses` (war schon da)
   - `user_study_courses`
   - `user_semesters`

---

## 4) Projekt-URL und Key in den Code eintragen

In `index.html` stehen oben im Script diese beiden Werte:

```js
const SUPABASE_URL = 'https://...supabase.co';
const SUPABASE_KEY = 'sb_publishable_...';
```

So findest du deine Werte:

1. Supabase → **Project Settings** → **API**.
2. Kopiere:
   - **Project URL** → `SUPABASE_URL`
   - **publishable / anon key** → `SUPABASE_KEY`
3. In `index.html` ersetzen und speichern.

> Wichtig: Niemals den `service_role` Key im Frontend nutzen.

---

## 5) Lokal testen

Im Projektordner:

```bash
python3 -m http.server 4173
```

Dann im Browser öffnen:

- http://localhost:4173/index.html

Testablauf:

1. Registrieren
2. Einloggen
3. Kurs hinzufügen
4. Kurs zu „Mein Studium“ hinzufügen
5. Semester anlegen + Drag&Drop
6. Logout
7. Mit zweitem Nutzer einloggen und prüfen:
   - Kursübersicht global sichtbar
   - „Mein Studium“ ist separat

---

## 6) Optional: „zweites Supabase“ (zweites Projekt)

Wenn du wirklich ein **zweites Supabase-Projekt** nutzen willst (z. B. Test/Produktion getrennt):

1. Zweites Projekt in Supabase anlegen.
2. Dort auch `supabase_auth_setup.sql` ausführen.
3. In `index.html` URL + Key auf Projekt 2 ändern.
4. Seite neu deployen.

### Empfehlung

- **Projekt A = Entwicklung/Test**
- **Projekt B = Produktion**

So kannst du gefahrlos testen, ohne Live-Daten zu beschädigen.

---

## 7) Häufige Fehler

### Fehler: „permission denied" oder leere Daten

- SQL-Setup nicht ausgeführt oder RLS/Policies fehlen.
- Prüfe, ob du wirklich als Benutzer eingeloggt bist.

### Fehler: Login geht nicht

- Email-Provider nicht aktiviert.
- E-Mail-Bestätigung aktiviert, aber Mail nicht bestätigt.

### Fehler: Tabelle nicht gefunden

- SQL im falschen Projekt ausgeführt.

---

## 8) Deployment

Du kannst die statische Seite z. B. bei Netlify, Vercel oder GitHub Pages deployen.

Wichtig ist nur:

- `index.html` enthält die korrekte Supabase URL + publishable key.
- Die SQL-Struktur existiert im Zielprojekt.

---

## Kurz-Checkliste

- [ ] Supabase-Projekt erstellt
- [ ] Email-Auth aktiviert
- [ ] `supabase_auth_setup.sql` ausgeführt
- [ ] URL + publishable key in `index.html` gesetzt
- [ ] Login/Registrierung getestet
- [ ] Zwei Nutzer getestet (Trennung von „Mein Studium“)
