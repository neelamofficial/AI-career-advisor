-- Run AFTER career_advisor.sql. Clears the sample rows and loads the full data.
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE resources;
TRUNCATE TABLE roadmap_steps;
TRUNCATE TABLE career_interests;
TRUNCATE TABLE career_skills;
TRUNCATE TABLE careers;
TRUNCATE TABLE interests;
TRUNCATE TABLE skills;
TRUNCATE TABLE education_levels;
SET FOREIGN_KEY_CHECKS = 1;

INSERT INTO education_levels (name) VALUES
('Matric / O-Level'),('Intermediate / A-Level'),('Bachelor''s (in progress)'),('Bachelor''s (completed)'),('Master''s'),('Self-taught');

INSERT INTO skills (name) VALUES
('Python'),('JavaScript'),('HTML/CSS'),('SQL'),('Excel'),('Statistics'),('Machine Learning'),('Data Visualization'),('Git'),('React'),
('Mobile Development'),('Linux'),('Networking'),('Cybersecurity Basics'),('Cloud Basics'),('UI/UX Design'),('Communication'),('Writing'),
('Marketing Basics'),('Project Management'),('Leadership'),('Problem Solving'),('Research'),('Teaching'),('Accounting Basics'),('Creativity');

INSERT INTO interests (name) VALUES
('Technology'),('Programming'),('Data'),('Design'),('Business'),('Teaching'),('Writing'),('Security'),('Science'),('Management'),('Finance'),('Social Media'),('Mobile Apps'),('Cloud');

INSERT INTO careers (slug, title, icon, description) VALUES
('web-dev','Web Developer','🌐','Build websites and web apps used by businesses and people every day.'),
('data-analyst','Data Analyst','📊','Turn raw data into insights and dashboards that guide decisions.'),
('ai-engineer','AI / Machine Learning Engineer','🤖','Design models and AI-powered products that learn from data.'),
('mobile-dev','Mobile App Developer','📱','Create Android and iOS apps that people install and use daily.'),
('ux-designer','UI/UX Designer','🎨','Design products that are beautiful, simple and enjoyable to use.'),
('cyber','Cybersecurity Analyst','🛡️','Protect systems, networks and data from attacks.'),
('devops','Cloud / DevOps Engineer','☁️','Deploy, scale and keep applications running reliably in the cloud.'),
('marketer','Digital Marketer','📣','Grow brands online using social media, content, SEO and ads.'),
('teacher-tech','Teacher / EdTech Specialist','🎓','Educate others and use technology to improve learning.'),
('pm','Project / Product Manager','🧭','Lead teams to deliver products and projects on time.'),
('writer','Content Writer / Journalist','✍️','Write articles, blogs, scripts and stories that inform and inspire.'),
('accountant','Accountant / Finance Analyst','💼','Manage money, budgets, audits and financial reports.');

-- ===== web-dev =====
SET @c = (SELECT career_id FROM careers WHERE slug='web-dev');
INSERT INTO career_skills SELECT @c, skill_id FROM skills WHERE name IN ('HTML/CSS','JavaScript','Git','React','Problem Solving','SQL');
INSERT INTO career_interests SELECT @c, interest_id FROM interests WHERE name IN ('Technology','Programming','Design');
INSERT INTO roadmap_steps (career_id, step_no, description) VALUES
(@c,1,'Learn HTML & CSS and build 3 static pages'),(@c,2,'Learn JavaScript fundamentals (DOM, fetch, ES6)'),(@c,3,'Learn Git & GitHub; publish your projects'),
(@c,4,'Learn a framework such as React'),(@c,5,'Learn a backend + SQL database; build a full-stack app'),(@c,6,'Deploy a portfolio and apply for internships / freelance gigs');
INSERT INTO resources (career_id, name) VALUES (@c,'freeCodeCamp'),(@c,'MDN Web Docs'),(@c,'The Odin Project'),(@c,'CS50 Web (edX)');

-- ===== data-analyst =====
SET @c = (SELECT career_id FROM careers WHERE slug='data-analyst');
INSERT INTO career_skills SELECT @c, skill_id FROM skills WHERE name IN ('Excel','SQL','Statistics','Data Visualization','Communication','Python');
INSERT INTO career_interests SELECT @c, interest_id FROM interests WHERE name IN ('Data','Business','Science');
INSERT INTO roadmap_steps (career_id, step_no, description) VALUES
(@c,1,'Master Excel (formulas, pivot tables, charts)'),(@c,2,'Learn SQL queries and joins'),(@c,3,'Learn basic statistics and probability'),
(@c,4,'Learn Python with pandas for data cleaning'),(@c,5,'Build dashboards (Power BI / Tableau / Looker Studio)'),(@c,6,'Complete 3 portfolio projects with real datasets (Kaggle)');
INSERT INTO resources (career_id, name) VALUES (@c,'Kaggle Learn'),(@c,'Google Data Analytics Certificate'),(@c,'Mode SQL Tutorial');

-- ===== ai-engineer =====
SET @c = (SELECT career_id FROM careers WHERE slug='ai-engineer');
INSERT INTO career_skills SELECT @c, skill_id FROM skills WHERE name IN ('Python','Machine Learning','Statistics','SQL','Git','Problem Solving','Research');
INSERT INTO career_interests SELECT @c, interest_id FROM interests WHERE name IN ('Technology','Programming','Data','Science');
INSERT INTO roadmap_steps (career_id, step_no, description) VALUES
(@c,1,'Get strong in Python and NumPy / pandas'),(@c,2,'Learn math basics: linear algebra, probability, statistics'),(@c,3,'Study classical ML with scikit-learn'),
(@c,4,'Learn deep learning (PyTorch or TensorFlow)'),(@c,5,'Build and deploy an ML app (API + simple UI)'),(@c,6,'Join hackathons and publish projects / papers');
INSERT INTO resources (career_id, name) VALUES (@c,'fast.ai'),(@c,'Andrew Ng''s ML Specialization'),(@c,'Kaggle Competitions'),(@c,'Hugging Face Course');

-- ===== mobile-dev =====
SET @c = (SELECT career_id FROM careers WHERE slug='mobile-dev');
INSERT INTO career_skills SELECT @c, skill_id FROM skills WHERE name IN ('Mobile Development','JavaScript','Git','UI/UX Design','Problem Solving');
INSERT INTO career_interests SELECT @c, interest_id FROM interests WHERE name IN ('Mobile Apps','Programming','Technology','Design');
INSERT INTO roadmap_steps (career_id, step_no, description) VALUES
(@c,1,'Learn a language (Kotlin, Dart or JavaScript)'),(@c,2,'Pick a framework: Flutter or React Native'),(@c,3,'Build a to-do app with local storage'),
(@c,4,'Connect your app to an online API / database'),(@c,5,'Publish an app on Google Play');
INSERT INTO resources (career_id, name) VALUES (@c,'Flutter Docs'),(@c,'Android Developers Training'),(@c,'React Native Docs');

-- ===== ux-designer =====
SET @c = (SELECT career_id FROM careers WHERE slug='ux-designer');
INSERT INTO career_skills SELECT @c, skill_id FROM skills WHERE name IN ('UI/UX Design','Creativity','Communication','Research','HTML/CSS');
INSERT INTO career_interests SELECT @c, interest_id FROM interests WHERE name IN ('Design','Technology','Social Media');
INSERT INTO roadmap_steps (career_id, step_no, description) VALUES
(@c,1,'Learn design principles: color, typography, layout'),(@c,2,'Learn Figma and build clickable prototypes'),(@c,3,'Learn user research and usability testing'),
(@c,4,'Redesign 3 real apps as case studies'),(@c,5,'Publish a portfolio on Behance or a personal site');
INSERT INTO resources (career_id, name) VALUES (@c,'Figma Learn'),(@c,'Google UX Design Certificate'),(@c,'Laws of UX');

-- ===== cyber =====
SET @c = (SELECT career_id FROM careers WHERE slug='cyber');
INSERT INTO career_skills SELECT @c, skill_id FROM skills WHERE name IN ('Cybersecurity Basics','Networking','Linux','Python','Problem Solving');
INSERT INTO career_interests SELECT @c, interest_id FROM interests WHERE name IN ('Security','Technology','Science');
INSERT INTO roadmap_steps (career_id, step_no, description) VALUES
(@c,1,'Learn networking fundamentals (TCP/IP, DNS, HTTP)'),(@c,2,'Get comfortable with Linux command line'),(@c,3,'Learn security basics: encryption, authentication, OWASP Top 10'),
(@c,4,'Practice legally on TryHackMe / Hack The Box'),(@c,5,'Prepare for CompTIA Security+ or similar certification');
INSERT INTO resources (career_id, name) VALUES (@c,'TryHackMe'),(@c,'Cisco Networking Academy'),(@c,'OWASP');

-- ===== devops =====
SET @c = (SELECT career_id FROM careers WHERE slug='devops');
INSERT INTO career_skills SELECT @c, skill_id FROM skills WHERE name IN ('Cloud Basics','Linux','Networking','Git','Python','Problem Solving');
INSERT INTO career_interests SELECT @c, interest_id FROM interests WHERE name IN ('Cloud','Technology','Programming');
INSERT INTO roadmap_steps (career_id, step_no, description) VALUES
(@c,1,'Learn Linux and shell scripting'),(@c,2,'Learn Git and CI/CD basics'),(@c,3,'Learn Docker containers'),
(@c,4,'Learn a cloud platform (AWS / Azure / GCP) free tier'),(@c,5,'Deploy a full app with automated pipeline');
INSERT INTO resources (career_id, name) VALUES (@c,'AWS Skill Builder'),(@c,'Docker Docs'),(@c,'roadmap.sh/devops');

-- ===== marketer =====
SET @c = (SELECT career_id FROM careers WHERE slug='marketer');
INSERT INTO career_skills SELECT @c, skill_id FROM skills WHERE name IN ('Marketing Basics','Communication','Writing','Creativity','Data Visualization');
INSERT INTO career_interests SELECT @c, interest_id FROM interests WHERE name IN ('Social Media','Business','Writing','Design');
INSERT INTO roadmap_steps (career_id, step_no, description) VALUES
(@c,1,'Learn marketing fundamentals and customer personas'),(@c,2,'Learn SEO and content marketing'),(@c,3,'Learn social media ads (Meta, Google Ads)'),
(@c,4,'Learn analytics (Google Analytics)'),(@c,5,'Run a real campaign for a small business or your own page');
INSERT INTO resources (career_id, name) VALUES (@c,'Google Digital Garage'),(@c,'HubSpot Academy'),(@c,'Meta Blueprint');

-- ===== teacher-tech =====
SET @c = (SELECT career_id FROM careers WHERE slug='teacher-tech');
INSERT INTO career_skills SELECT @c, skill_id FROM skills WHERE name IN ('Teaching','Communication','Leadership','Creativity','Writing');
INSERT INTO career_interests SELECT @c, interest_id FROM interests WHERE name IN ('Teaching','Technology','Management');
INSERT INTO roadmap_steps (career_id, step_no, description) VALUES
(@c,1,'Strengthen your subject knowledge'),(@c,2,'Learn lesson planning and classroom management'),(@c,3,'Learn digital tools (Google Classroom, Canva, Kahoot)'),
(@c,4,'Complete teacher training / certification'),(@c,5,'Create online lessons and build a teaching profile');
INSERT INTO resources (career_id, name) VALUES (@c,'Coursera: Learning How to Learn'),(@c,'Google for Education Training'),(@c,'Khan Academy');

-- ===== pm =====
SET @c = (SELECT career_id FROM careers WHERE slug='pm');
INSERT INTO career_skills SELECT @c, skill_id FROM skills WHERE name IN ('Project Management','Leadership','Communication','Problem Solving','Excel');
INSERT INTO career_interests SELECT @c, interest_id FROM interests WHERE name IN ('Management','Business','Technology');
INSERT INTO roadmap_steps (career_id, step_no, description) VALUES
(@c,1,'Learn Agile and Scrum basics'),(@c,2,'Learn tools: Trello, Jira, Notion'),(@c,3,'Practice writing requirements and user stories'),
(@c,4,'Lead a small team project or club'),(@c,5,'Earn CAPM / PSM certification');
INSERT INTO resources (career_id, name) VALUES (@c,'Atlassian Agile Coach'),(@c,'Google Project Management Certificate'),(@c,'Scrum Guide');

-- ===== writer =====
SET @c = (SELECT career_id FROM careers WHERE slug='writer');
INSERT INTO career_skills SELECT @c, skill_id FROM skills WHERE name IN ('Writing','Research','Creativity','Communication','Marketing Basics');
INSERT INTO career_interests SELECT @c, interest_id FROM interests WHERE name IN ('Writing','Social Media','Science');
INSERT INTO roadmap_steps (career_id, step_no, description) VALUES
(@c,1,'Write daily and start a blog'),(@c,2,'Learn SEO writing and editing'),(@c,3,'Learn research and fact-checking'),
(@c,4,'Build a portfolio of 10 published pieces'),(@c,5,'Pitch to magazines, agencies or freelance platforms');
INSERT INTO resources (career_id, name) VALUES (@c,'Medium'),(@c,'Hemingway Editor'),(@c,'Coursera: Writing courses');

-- ===== accountant =====
SET @c = (SELECT career_id FROM careers WHERE slug='accountant');
INSERT INTO career_skills SELECT @c, skill_id FROM skills WHERE name IN ('Accounting Basics','Excel','Statistics','Communication','Problem Solving');
INSERT INTO career_interests SELECT @c, interest_id FROM interests WHERE name IN ('Finance','Business','Data');
INSERT INTO roadmap_steps (career_id, step_no, description) VALUES
(@c,1,'Learn accounting fundamentals (ledger, balance sheet)'),(@c,2,'Master Excel for finance'),(@c,3,'Learn accounting software (QuickBooks, Tally)'),
(@c,4,'Study taxation basics'),(@c,5,'Start professional certification (ACCA / CA / CMA)');
INSERT INTO resources (career_id, name) VALUES (@c,'ACCA Learning'),(@c,'Khan Academy Finance'),(@c,'Corporate Finance Institute');
