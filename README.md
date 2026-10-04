# AI Student Career & Skill Advisor

A web app that recommends careers based on a student's skills and interests, shows skill gaps, gives learning roadmaps with progress tracking, and includes a chat advisor.

**Tech stack:** HTML/CSS/JavaScript (frontend) · Node.js + Express (backend) · MySQL (database)

---

## Project structure

```
career-advisor/
├── server.js            # Backend API (Express)
├── package.json         # Dependencies
├── .env.example         # Template for settings (copy to .env)
├── career_advisor.sql   # Creates all database tables
├── seed.sql             # Loads skills, interests and 12 careers
└── public/
    └── index.html       # Frontend (served by the backend)
```

## Requirements

| Tool | Notes |
|---|---|
| [Node.js](https://nodejs.org) (LTS) | Download the Windows Installer (.msi). Do **not** tick "Automatically install the necessary tools" |
| MySQL Server + MySQL Workbench | Remember the **root password** you set during install |
| VS Code (optional) | Any editor works |

---

## Setup (one time)

### 1. Create the database

Open MySQL Workbench, connect to your local server, open a new SQL tab and run:

```sql
CREATE DATABASE career_advisor CHARACTER SET utf8mb4;
USE career_advisor;
```

### 2. Create the tables

Open `career_advisor.sql` in Workbench (**File → Open SQL Script**), add this as the **first line**, then click the ⚡ button:

```sql
USE career_advisor;
```

Then run this in a new SQL tab (the backend uses bcrypt, which doesn't need this column):

```sql
USE career_advisor;
ALTER TABLE users DROP COLUMN salt;
```

### 3. Load the data

Open `seed.sql`, add `USE career_advisor;` as the first line, and click ⚡.

Check it worked:

```sql
SELECT title FROM careers;   -- should return 12 rows
```

### 4. Create the settings file

Copy `.env.example` and rename the copy to `.env`. Edit it:

```
DB_HOST=localhost
DB_USER=root
DB_PASS=your_mysql_root_password
DB_NAME=career_advisor
JWT_SECRET=any_long_random_text_you_choose
PORT=3000
```

- No spaces around `=`.
- `.env` must be named exactly `.env` (not `.env.txt`).

### 5. Install and run

Open a terminal inside the project folder and run:

```
npm install
npm start
```

You should see: `API running on port 3000`. Keep this terminal open.

### 6. Open the app

Go to **http://localhost:3000** in your browser.

> Don't open `index.html` by double-clicking it. It must be opened through the server.

---

## Running it again later

1. Make sure the **MySQL80** service is running (Windows Services).
2. In the project folder: `npm start`
3. Open http://localhost:3000

Stop the server with **Ctrl + C**.

---

## Quick test

1. Sign up with a name, email and password (6+ characters).
2. Pick some skills and interests, click **Save & Get Recommendations**.
3. Check **Matches**, tick steps in **Roadmap**, ask something in **Ask Advisor**.
4. Refresh the page. Your data should still be there.

---

## API endpoints

| Method | Endpoint | Login needed | Purpose |
|---|---|---|---|
| POST | `/api/auth/register` | No | Create account |
| POST | `/api/auth/login` | No | Log in, get token |
| GET | `/api/meta` | No | Skills, interests, education lists |
| GET / PUT | `/api/profile` | Yes | Read / save profile |
| POST | `/api/recommendations` | Yes | Generate new recommendations |
| GET | `/api/recommendations/latest` | Yes | Latest recommendations |
| GET | `/api/history` | Yes | Past top matches |
| GET | `/api/roadmap` | Yes | Roadmaps with progress |
| PUT | `/api/progress/:stepId` | Yes | Tick / untick a roadmap step |
| GET / POST | `/api/chat` | Yes | Chat history / send message |

Login-protected endpoints need the header `Authorization: Bearer <token>`.

---

## Database tables

`users` · `profiles` · `education_levels` · `skills` · `interests` · `user_skills` · `user_interests` · `careers` · `career_skills` · `career_interests` · `roadmap_steps` · `resources` · `recommendation_runs` · `recommendation_items` · `user_progress` · `chat_messages`

---

## Troubleshooting

| Problem | Fix |
|---|---|
| `npm` blocked in PowerShell ("running scripts is disabled") | Run `Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned`, or use Command Prompt |
| `node is not recognized` | Restart VS Code / the PC after installing Node.js |
| `Access denied for user 'root'` | Wrong `DB_PASS` in `.env` |
| `ECONNREFUSED` | MySQL isn't running. Start the **MySQL80** service |
| `Unknown database 'career_advisor'` | Step 1 wasn't done, or `DB_NAME` in `.env` is different |
| `Cannot find module ...` | Run `npm install` in the project folder |
| Port 3000 already in use | Change `PORT` in `.env` (e.g. 3001) and open that port instead |
| Signup fails mentioning `salt` | Run the `ALTER TABLE users DROP COLUMN salt;` command from Step 2 |
| Page loads but buttons do nothing | Open via http://localhost:3000, not the file directly. Check the browser console (F12) |

---

## Security notes

- Passwords are hashed with bcrypt. Plain passwords are never stored.
- Never share or upload your `.env` file. It contains your database password and secret key.
