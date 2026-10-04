-- Career Advisor database (MySQL / PostgreSQL friendly; SQLite works with minor changes)

CREATE TABLE education_levels (
  edu_id   INT PRIMARY KEY AUTO_INCREMENT,
  name     VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE skills (
  skill_id INT PRIMARY KEY AUTO_INCREMENT,
  name     VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE interests (
  interest_id INT PRIMARY KEY AUTO_INCREMENT,
  name        VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE careers (
  career_id   INT PRIMARY KEY AUTO_INCREMENT,
  slug        VARCHAR(30) NOT NULL UNIQUE,      -- e.g. 'web-dev'
  title       VARCHAR(80) NOT NULL,
  icon        VARCHAR(10),
  description VARCHAR(255)
);

CREATE TABLE career_skills (
  career_id INT NOT NULL,
  skill_id  INT NOT NULL,
  PRIMARY KEY (career_id, skill_id),
  FOREIGN KEY (career_id) REFERENCES careers(career_id) ON DELETE CASCADE,
  FOREIGN KEY (skill_id)  REFERENCES skills(skill_id)   ON DELETE CASCADE
);

CREATE TABLE career_interests (
  career_id   INT NOT NULL,
  interest_id INT NOT NULL,
  PRIMARY KEY (career_id, interest_id),
  FOREIGN KEY (career_id)   REFERENCES careers(career_id)     ON DELETE CASCADE,
  FOREIGN KEY (interest_id) REFERENCES interests(interest_id) ON DELETE CASCADE
);

CREATE TABLE roadmap_steps (
  step_id     INT PRIMARY KEY AUTO_INCREMENT,
  career_id   INT NOT NULL,
  step_no     INT NOT NULL,
  description VARCHAR(255) NOT NULL,
  UNIQUE (career_id, step_no),
  FOREIGN KEY (career_id) REFERENCES careers(career_id) ON DELETE CASCADE
);

CREATE TABLE resources (
  resource_id INT PRIMARY KEY AUTO_INCREMENT,
  career_id   INT NOT NULL,
  name        VARCHAR(100) NOT NULL,
  FOREIGN KEY (career_id) REFERENCES careers(career_id) ON DELETE CASCADE
);

-- ---------- User side ----------

CREATE TABLE users (
  user_id       INT PRIMARY KEY AUTO_INCREMENT,
  full_name     VARCHAR(100) NOT NULL,
  email         VARCHAR(120) NOT NULL UNIQUE,
  password_hash VARCHAR(128) NOT NULL,
  salt          VARCHAR(32)  NOT NULL,
  created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE profiles (
  user_id     INT PRIMARY KEY,                 -- 1-to-1 with users
  edu_id      INT,
  field       VARCHAR(100),
  career_goal VARCHAR(200),
  updated_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
  FOREIGN KEY (edu_id)  REFERENCES education_levels(edu_id)
);

CREATE TABLE user_skills (
  user_id  INT NOT NULL,
  skill_id INT NOT NULL,
  PRIMARY KEY (user_id, skill_id),
  FOREIGN KEY (user_id)  REFERENCES users(user_id)   ON DELETE CASCADE,
  FOREIGN KEY (skill_id) REFERENCES skills(skill_id) ON DELETE CASCADE
);

CREATE TABLE user_interests (
  user_id     INT NOT NULL,
  interest_id INT NOT NULL,
  PRIMARY KEY (user_id, interest_id),
  FOREIGN KEY (user_id)     REFERENCES users(user_id)         ON DELETE CASCADE,
  FOREIGN KEY (interest_id) REFERENCES interests(interest_id) ON DELETE CASCADE
);

-- One row per "Save & Get Recommendations" click (replaces the History tab)
CREATE TABLE recommendation_runs (
  run_id       INT PRIMARY KEY AUTO_INCREMENT,
  user_id      INT NOT NULL,
  generated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- Top 6 careers for each run
CREATE TABLE recommendation_items (
  run_id    INT NOT NULL,
  career_id INT NOT NULL,
  rank_no   INT NOT NULL,                      -- 1..6
  score     INT NOT NULL CHECK (score BETWEEN 0 AND 100),
  PRIMARY KEY (run_id, career_id),
  FOREIGN KEY (run_id)    REFERENCES recommendation_runs(run_id) ON DELETE CASCADE,
  FOREIGN KEY (career_id) REFERENCES careers(career_id)
);

-- Ticked roadmap checkboxes
CREATE TABLE user_progress (
  user_id      INT NOT NULL,
  step_id      INT NOT NULL,
  completed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (user_id, step_id),
  FOREIGN KEY (user_id) REFERENCES users(user_id)          ON DELETE CASCADE,
  FOREIGN KEY (step_id) REFERENCES roadmap_steps(step_id)  ON DELETE CASCADE
);

CREATE TABLE chat_messages (
  msg_id     INT PRIMARY KEY AUTO_INCREMENT,
  user_id    INT NOT NULL,
  role       VARCHAR(10) NOT NULL CHECK (role IN ('user','assistant')),
  content    TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- ---------- Sample data ----------

INSERT INTO education_levels (name) VALUES
 ('Matric / O-Level'),('Intermediate / A-Level'),("Bachelor's (in progress)"),
 ("Bachelor's (completed)"),("Master's"),('Self-taught');

INSERT INTO skills (name) VALUES ('Python'),('JavaScript'),('HTML/CSS'),('SQL'),('Git'),('Problem Solving');
INSERT INTO interests (name) VALUES ('Technology'),('Programming'),('Design');

INSERT INTO careers (slug, title, icon, description)
VALUES ('web-dev','Web Developer','🌐','Build websites and web apps used by businesses and people every day.');

INSERT INTO career_skills VALUES (1,2),(1,3),(1,4),(1,5),(1,6);
INSERT INTO career_interests VALUES (1,1),(1,2),(1,3);
INSERT INTO roadmap_steps (career_id, step_no, description) VALUES
 (1,1,'Learn HTML & CSS and build 3 static pages'),
 (1,2,'Learn JavaScript fundamentals (DOM, fetch, ES6)');
INSERT INTO resources (career_id, name) VALUES (1,'freeCodeCamp'),(1,'MDN Web Docs');

-- ---------- Useful queries ----------

-- Latest recommendations for a user
SELECT c.title, ri.score
FROM recommendation_items ri
JOIN careers c ON c.career_id = ri.career_id
WHERE ri.run_id = (SELECT MAX(run_id) FROM recommendation_runs WHERE user_id = 1)
ORDER BY ri.rank_no;

-- Skills a user still needs for a career (skill gap)
SELECT s.name
FROM career_skills cs
JOIN skills s ON s.skill_id = cs.skill_id
WHERE cs.career_id = 1
  AND cs.skill_id NOT IN (SELECT skill_id FROM user_skills WHERE user_id = 1);

-- Roadmap completion % per career for a user
SELECT c.title,
       ROUND(100.0 * COUNT(up.step_id) / COUNT(rs.step_id)) AS pct_complete
FROM careers c
JOIN roadmap_steps rs ON rs.career_id = c.career_id
LEFT JOIN user_progress up ON up.step_id = rs.step_id AND up.user_id = 1
GROUP BY c.career_id, c.title;

-- History tab: top career of each run
SELECT r.generated_at, c.title, ri.score
FROM recommendation_runs r
JOIN recommendation_items ri ON ri.run_id = r.run_id AND ri.rank_no = 1
JOIN careers c ON c.career_id = ri.career_id
WHERE r.user_id = 1
ORDER BY r.generated_at DESC
LIMIT 10;
