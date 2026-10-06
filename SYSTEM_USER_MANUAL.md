**S Y S T E M U S E R M A N U A L** 

# **Nirvoor Learning** 

Online Learning Management System What it does, where everything is, and how to test it 

Version 1.0  ·  August 2026 

For: testers, reviewers and new team members 

Live site: learning.nirvoor.com  ·  API: api.nirvoor.com 

Page 1 of 14 

Nirvoor Learning — System User Manual 

**Contents** 

1. What this system is 

2. The three roles and how to get into each panel 

3. **Read this first — 13 rules you cannot guess from the screen** 

4. Student panel — every feature, where it is, what to do 

5. Teacher panel 

6. Admin panel 

7. A 30-minute test walkthrough 

8. Things that are switched off or limited right now 

9. Quick reference — all page addresses 

**How to read this manual.** Section 3 is the important one. Everything else describes buttons you can find by clicking around. Section 3 describes behaviour you will _never_ work out by clicking, and will report as a bug if nobody tells you. 

Page 2 of 14 

Nirvoor Learning — System User Manual 

## **1. What this system is** 

Nirvoor Learning is an online course platform for Bangladeshi students. Students buy courses, watch video lessons, join live classes, sit exams, and get certificates. Teachers run the live classes and mark the exams. Admin runs everything else. 

The system has three parts: 

**Website (frontend)** — what everyone sees in the browser. Angular. 

**API (backend)** — the server that stores data and enforces the rules. ASP.NET Core. 

**Database** — SQL Server. 

The whole site works in **two languages** . There is a language switch in the top navigation bar — English and Bangla. Almost every screen is translated, so please test both. 

## **2. The three roles and how to get into each panel** 

|**Role**|**How an account is created**|**Where the panel is**|**What they control**|
|---|---|---|---|
|**Student**|Sign up at<br>`/register` . Must confirm a 6-<br>digit code sent by email, then fill a short<br>profile form.|Profile menu (top right)<br>→**Dashboard**, or<br>`/profile`|Their own learning only.|
|**Teacher**|Two ways. (a) Sign up at<br>`/register/teacher`— then**waits for**<br>**admin approval**. (b) Admin sends an email<br>invitation — that teacher is**approved**<br>**instantly**.|Profile menu →<br>**Teacher Panel**, or<br>`/teacher`|Live classes, recordings and<br>exams for their courses.|
|**Admin**|Created directly in the database / seeded at<br>startup. You cannot sign up as an admin.|Profile menu →<br>**Admin Panel**, or<br>`/admin`|Everything — courses, users,<br>money, content, settings.|



**Rule 1 — Teacher and Admin do different halves of the same job.** Admin creates the course and uploads lessons, practice sets and AI-writing tasks. The teacher only handles **live classes, recordings and exams** . If you log in as a teacher and cannot find the "Lessons" tab, that is correct — it is not missing, teachers never had it. 

Page 3 of 14 

Nirvoor Learning — System User Manual 

## **3. Read this first — 13 rules you cannot guess from the screen** 

These are the behaviours that look like bugs but are deliberate. Please read all thirteen before you start testing, or you will file the same reports we already know about. 

#### **Rule 2 — A course disappears from the catalogue once its start date passes.** 

The course **start date is also the last day to enrol** . You can join right up to and including the start day. From the next day the course is **completely hidden** from students — it is gone from the course list, the search, the home page and even its own direct link. 

**Who still sees it:** admin, teachers, and any student **already enrolled** (it stays in their My Courses forever). So if a student says "my course vanished", check whether they were actually enrolled. If a tester says "the course I created is not in the list", check the start date first. 

#### **Rule 3 — "Coming soon" courses are the opposite: visible but not buyable.** 

A course marked _Upcoming_ is shown on purpose, so people can see what is coming. But the Buy button is refused, there is no price, and the word "Free" is never displayed. It is also kept out of "Most popular". You can give it a date to open by itself — on that day it starts selling with nobody having to touch anything. 

#### **Rule 4 — Discounts never add up. The biggest one wins.** 

A course can have a campaign discount, a coupon code, and a company (corporate) discount all at once. They do **not** stack. The system compares them in taka and applies only the **single largest** saving. 

At checkout you will see the losing corporate offer still listed, greyed out and marked as not applied. That is deliberate — it shows the student the offer existed and why it was not used. 

#### **Rule 5 — The enrolment number on a course card is not the real number.** 

Every course card shows an inflated count: a fixed baseline (between 25 and 55, different per course but always the same for that course) **plus** the real enrolments. Video and practice counts on cards are also fixed marketing text ("24+", "50+"). 

**So do not use the card number to check whether an enrolment worked.** Use the admin panel (Courses → enrolled students) or the student's My Courses page. The course _details_ page shows true counts. 

#### **Rule 6 — Course "duration" is counted in MONTHS, not minutes.** 

The field is stored with a name that says minutes, but every screen treats it as months, and the course end date is calculated from it. If you type 6, that means six months. 

#### **Rule 7 — Deleting a course or a category destroys everything inside it.** 

Deleting a course wipes its lessons, videos, quizzes, exams, live classes, recordings and files — from both the database and the server's disk. Nothing is left behind and there is no undo. 

Deleting a **category** is worse: it deletes **every course inside that category** the same way. That is why it asks you to type the word DELETE first. Please do not test this on real data. 

Page 4 of 14 

Nirvoor Learning — System User Manual 

#### **Rule 8 — Three categories can never be deleted.** 

SSC 2027, HSC 2027 and Professional are built into the code. They are always shown to students even when they contain no courses (students see a "coming soon" state instead of an empty page). Admin can add and delete any other category. 

#### **Rule 9 — Approving a refund removes the student from the course.** 

When admin approves a refund, the enrolment is **deleted** , not marked as cancelled. The student loses access immediately. 

There is an **Undo** button on an approved refund. That undo is the **only** way in the whole system to put a student back into a course without paying again. Admin cannot manually enrol anybody by any other route. 

Also note: the system **records** the refund. It does not move any money. Someone must send the money back by hand. 

#### **Rule 10 — Only the teacher can create and mark a live-class exam. Admin can only look.** 

For the Google-Forms style live exams, admin has **read-only** access. Admin can open the responses page and read the answers, but cannot write questions or change marks. This is on purpose, so admin cannot alter results. 

#### **Rule 11 — Live classes are recorded by the teacher's browser, not by the server.** 

There is no automatic recording. The teacher must press record inside the live class, keep the tab open until the end, and then upload the file. If the teacher closes the tab, the recording is gone. 

The upload keeps running in the background while the teacher moves around the site — a small floating box shows the progress. Do not close the browser during upload. 

#### **Rule 12 — Free live classes need no account at all.** 

`/free-live` is fully public. Anyone can watch without logging in or registering. This is the marketing entry point. Every other live class requires login and enrolment in the course. 

#### **Rule 13 — Too many login attempts will lock you out for a minute.** 

The server allows **8 login / signup / password attempts per minute from one internet connection** . While testing you will hit this. The site will start refusing you with an error even though your password is right. Wait 60 seconds and it clears by itself. 

The support widget has its own limit: **5 messages per 10 minutes** . 

#### **Rule 14 — Verification and notification emails often land in the spam folder.** 

This is a known issue with the mail server, not a bug in the site. If a sign-up code does not arrive, check the spam and promotions folders. The code screen now says this on screen too. 

Page 5 of 14 

Nirvoor Learning — System User Manual 

## **4. Student panel — every feature, where it is, what to do** 

### **4.1 Getting an account** 

|**Feature**|**Where**|**What to do**|
|---|---|---|
|Sign up|**/register**|Name, email, mobile, group (optional), password.<br>Mobile must be a real Bangladeshi number (11 digits<br>starting 01, or +880…).|
|Email verification|Appears straight after sign up|Type the 6-digit code from the email. Code lasts 15<br>minutes, 5 wrong tries and it dies, new code available<br>after 60 seconds.**Students only**— teachers skip this<br>step.|
|Profile form|Pops up automatically after<br>verification|A short compulsory form (school, batch, guardian<br>details). Cannot be skipped.|
|Log in|**/login**|Email + password. An unverified student is sent to the<br>code screen instead of getting an error.|
|Password rules|Sign-up and Settings|Strong password required; a live strength meter shows<br>as you type.|



### **4.2 Finding and buying a course** 

|**Feature**|**Where**|**What to do**|
|---|---|---|
|Browse all courses|**/courses**|Filter rail on the left: category, level, price, rating,<br>availability. Sorting and paging are done by the server,<br>so results are fast even with many courses.|
|Course details|Click any course card|Description, price, teacher, what you get. One single<br>layout for every course.|
|Wishlist|Heart icon on a course, or**/wishlist**|Save a course for later. Also reachable from the profile<br>menu.|
|Buy a course|Course details → Enroll / Buy|Goes to checkout. Enter a coupon code if you have one,<br>choose "Pay via" company if a corporate discount<br>applies, then pay through SSLCommerz.|
|Free course|Same button|If the price is zero, or a discount covers the full price,<br>you are enrolled immediately with no payment page.|
|Refund request|Profile → My Courses → the course|Student asks for a refund with a reason. It goes to an<br>admin queue. See Rule 9.|



### **4.3 Learning inside a course** 

Open **Profile → My Courses** and click a course. You land on the **course hub** — five big cards: 

Page 6 of 14 

Nirvoor Learning — System User Manual 

|**Hub card**|**What is inside**|
|---|---|
|**Practice**|Board questions, model tests and other practice files uploaded by admin. Open them in a<br>built-in viewer (PDF, image or video) — they do not open in a blank new tab.|
|**Live Class**|Upcoming and running live classes. Click Join to enter. Attendance is recorded.|
|**Recordings**|Past live classes the teacher uploaded. Plays in the site's own video player.|
|**Exam**|The four course exams — 1st, 2nd, 3rd and Final. See 4.4.|
|**Suggestion**|Exam suggestions uploaded by admin.|



Video lessons, quizzes and progress sit on the same course page: 

|**Feature**|**Where**|**What to do**|
|---|---|---|
|Watch a video lesson|Lesson list inside the course|Video is streamed with a security token — the file link<br>cannot be copied and shared. Progress is saved as you<br>watch.|
|Take a quiz|Under a lesson that has one|Multiple choice. Marked instantly.|
|Progress bar|Course page and dashboard|One combined number: video 40%, quiz 15%, exam<br>15%, live exam 20%, attendance 10%.|
|Watch history|Profile menu →**/history**|Everything watched, newest first, like YouTube history.<br>Removing an item only hides it — it does not delete the<br>progress.|



### **4.4 Exams and AI writing** 

|**Feature**|**Where**|**What to do**|
|---|---|---|
|Course exams|Course hub → Exam|Four slots: 1st, 2nd, 3rd, Final. The exam window**opens**<br>**when the teacher uploads the question file**, and<br>everyone gets the same clock. Download the question,<br>write the answer, upload your answer file before the<br>deadline.|
|Live-class exam|Link appears in the live class|Google-Forms style — questions on screen, answer<br>inside the browser. Can include a file the teacher<br>attached, and file answers from the student.|
|AI writing task|Course hub, or**/ai-writing/<id>**|Student uploads a handwritten answer photo. The AI<br>reads the handwriting and gives a mark out of 100 with<br>feedback. Admin can overwrite the mark afterwards.<br>Multiple attempts allowed — the last one counts.|
|Certificate|Profile →**Certificates**|Issued for completed courses. Downloadable.|
|Leaderboard|**/leaderboard**|Student ranking. Admin can switch the whole<br>leaderboard on or off for everyone.|
|Rate the teacher|**/teacher-evaluation/<courseId>**|After a course finishes.**Anonymous to the teacher, but**<br>**admin can see who wrote what.**|



Page 7 of 14 

Nirvoor Learning — System User Manual 

### **4.5 Everyday things** 

|**Feature**|**Where**|**What to do**|
|---|---|---|
|Notifications|Bell icon in the top bar|Refreshes every 30 seconds. These are in-app only —<br>**no email or phone push is sent**for live classes.|
|Announcements|**/announcements**|Public notices from admin. They expire automatically on<br>a date admin sets.|
|Help / support|Floating button, bottom of every<br>page|Student writes a message; it is emailed to the support<br>inbox and the student gets a confirmation email.<br>Nothing is stored in the database — the mailbox_is_the<br>record.|
|Store|**/store**|Books and other items admin has listed.|
|Instructors|**/instructors**|Static teacher introduction page.|
|Settings|Profile → Settings|Change password, personal details.|



Page 8 of 14 

Nirvoor Learning — System User Manual 

## **5. Teacher panel** 

Go to **/teacher** (profile menu → Teacher Panel). Pick a course from the list, then use the section tabs inside it. A teacher sees three sections: **Live Classes, Recordings, Exams** . 

### **5.1 Becoming a teacher** 

|**Route in**|**What happens**|
|---|---|
|Normal sign-up at|Account is created but**locked**. Teacher gets a "registration received" email and waits.|
|`/register/teacher`|Admin must approve from Admin → Teachers. Then a second email arrives.|
|Admin invitation|Admin sends an invite from Admin → Teachers. The teacher clicks the link in the email<br>and registers.**No approval needed — the account is live immediately.**The link<br>works once and only for the invited email address.|



### **5.2 What a teacher can do** 

|**Task**|**Where**|**Steps**|
|---|---|---|
|Schedule a live class|Teacher panel → course →<br>**Live Classes**|Add a title, date and time, and whether it is free/public.<br>Enrolled students get an in-app notification.|
|Run the class|Same list → Join|Opens a Jitsi video room inside the site.|
|Record it|Inside the live room|Press record.**Keep the tab open.**Stop at the end, then<br>upload. Upload size is not limited and continues in the<br>background — a floating box shows progress. See Rule 11.|
|Manage recordings|Course →**Recordings**|Upload, rename, publish or delete. Students see published<br>ones in their Recordings card.|
|Create a course exam|Course →**Exams**|Pick the slot (1st / 2nd / 3rd / Final), set the window, upload<br>the question file.**Uploading the question is what opens**<br>**the exam**for students.|
|Mark exam answers|Exams → open an exam →<br>submissions|Download each student's answer file, type a mark and<br>feedback. Admin can open this page but only to read.|
|Build a live-class exam|Live class → Create exam|Google-Forms style builder — add questions, options, marks,<br>optional attachment.**Teacher only.**|
|See live-exam answers|Live exam → Responses|All student answers, auto-marked where possible, manual<br>marks where needed.|
|Attendance|Automatic|Recorded when a student joins a live class. It feeds 10% of<br>their progress score.|



Page 9 of 14 

Nirvoor Learning — System User Manual 

## **6. Admin panel** 

Go to **/admin** . There are 15 tabs down the left side. The panel remembers which tab you were on and returns you there after a refresh. 

|**Tab**|**What it is for and what to do there**|
|---|---|
|📊 **Dashboard**|Counts of students, teachers, courses and enrolments; top courses; courses by category. A red alert<br>appears when teachers are waiting for approval — click it to jump to the queue.|
|🎓 **Teachers**|Approve or reject waiting teachers. Send email invitations (auto-approved). See, resend and cancel<br>invitations.|
|👨‍🎓 **Students**|All student accounts. Search, view details, remove.|
|🗂 **Categories**|Add, rename and delete categories.**Deleting a category deletes every course inside it**— you<br>must type DELETE to confirm. Three categories cannot be deleted (Rule 8).|
|📚 **Courses**|The main one. Create a course (title, price, category, teacher, start date, duration in months,<br>discount, upcoming flag, thumbnail). Open a course to add**lessons, videos, quizzes, practice**<br>**material, suggestions and AI-writing tasks**. Also see who is enrolled.<br>**New courses appear at the bottom of the list**— the order is the order you added them, not<br>newest-first.|
|💬 **Comments**|Read and remove comments students left on courses.|
|📣 **Announcements**|Publish site-wide notices with an expiry date. They disappear on their own afterwards.|
|🛍 **Store Items**|Add and edit the products on the public Store page.|
|🎟 **Coupons**|Create discount codes tied to specific courses. A code is only counted as used when a payment<br>actually completes. Remember Rule 4 — it may lose to a bigger discount.|
|🏢 **Corporate**<br>**Coupon**|Company-wide discounts that need**no code**. The student picks the company at checkout under<br>"Pay via".|
|💳 **Payments**|Every payment, with the discount that was applied.<br>**Warning:**payments made before this feature existed have a zero original price, so old rows can<br>make "total discount given" look wrong. Treat very old rows with suspicion.|
|💸 **Refunds**|The refund queue. Approve (removes the student — Rule 9), reject, or undo an approval.|
|🎓 **Teacher Feedback**|Read what students said about teachers. Anonymous to the teacher, not to you.|
|📧 **Parent Reports**|Monthly Bangla report card emailed to a student's guardian. Preview any student's report, or send<br>the month manually.<br>**CURRENTLY OFF**— see section 8.|
|⚙ **Settings**|Site-wide switches, including turning the student leaderboard on or off.|



**Where do I add lesson videos?** Admin → Courses → open the course → **Lessons** . This trips up most new testers, because the same screen is also the teacher's panel — but the Lessons, Practice and AI Writing tabs only appear when an admin opens it. 

Page 10 of 14 

Nirvoor Learning — System User Manual 

## **7. A 30-minute test walkthrough** 

Follow these in order. This path touches every important part of the system and will show you whether the build is healthy. 

1. **Log in as admin** → `/admin` . Check the dashboard numbers load. 

2. **Create a category** (Categories tab) — call it "Test Category". 

3. **Create a course** in it (Courses tab). Set the price to 1000, duration 3 (= 3 months), and set the **start date to a future date** . If you set a past date the course will vanish from the student side (Rule 2). 

4. **Add a lesson with a video** , and a quiz under it. 

5. **Add a practice file** and a suggestion file. 

6. **Invite a teacher** (Teachers tab) to an email you can open. Register through the link — confirm you are approved immediately with no waiting. 

7. **As the teacher** , open `/teacher` → your course → schedule a live class for today, then create a 1st exam and upload a question file. 

8. **Sign up as a student** in a private browser window. Confirm the email code arrives — check spam (Rule 14). Complete the profile form. 

9. **As the student** , find the course in `/courses` . Add it to the wishlist. 

10. **Make a coupon** as admin, then use it at checkout as the student. Watch the price change, and check that only the biggest discount applies (Rule 4). 

11. **Complete the payment** (test/sandbox card). Confirm the course appears in My Courses. 

12. **Open the course hub** — check all five cards open: Practice, Live Class, Recordings, Exam, Suggestion. 

13. **Watch part of the video** , take the quiz, then check the progress bar moved. 

14. **Join the live class** as the student while the teacher is in it. Check attendance is recorded. 

15. **Submit the exam answer** as the student, then **mark it** as the teacher. 

16. **Request a refund** as the student, **approve it** as admin, and confirm the course disappears from the student's list. Then press **Undo** and confirm it comes back (Rule 9). 

17. **Test both languages** — switch to Bangla in the top bar and walk through the same pages. 

18. **Test on a phone** — the whole site is responsive and the mobile menu is different. 

**If the site suddenly refuses your login halfway through this test** , you have hit the 8-per-minute limit (Rule 13). Wait one minute. It is not broken. 

Page 11 of 14 

Nirvoor Learning — System User Manual 

## **8. Things that are switched off or limited right now** 

Please do not report these as bugs. They are known and deliberate. 

|**Item**|**State**|**Explanation**|
|---|---|---|
|Monthly parent report emails|**OFF**|Turned off in August 2026. The admin tab still works for previews,<br>but the Send button is refused and no automatic email goes out. It<br>was switched off because sending several hundred emails at once<br>can exceed the mail server's hourly limit.|
|Course recommendations|**OFF**|The "recommended for you" zones on the home page and course list<br>are switched off. The engine still exists and the leaderboard page still<br>shows a recommendation zone.|
|"Continue with Google" button|**REMOVED**|Removed from login and sign-up in August 2026. Google login was<br>never actually built, so the button did nothing when pressed.|
|Email delivery|**DEGRADED**|Emails often land in spam. The mail server is shared with other<br>customers, which damages the sending reputation. Being worked on.|
|Live class notifications by email|**NOT BUILT**|Live class alerts appear in the bell icon only. No email and no phone<br>notification is sent.|
|Automatic class recording|**NOT**<br>**POSSIBLE**|The server cannot record. Only the teacher's browser can (Rule 11).|
|Refund money transfer|**MANUAL**|Approving a refund records it and removes the enrolment. Sending<br>the money back is done by hand outside the system.|
|Student preference wizard|**OFF**|The 4-step interest questionnaire after sign-up is disabled. The short<br>profile form still runs.|
|Adaptive video quality (HLS)|**DORMANT**|Video plays as a single MP4 stream. Quality switching is written but<br>switched off because the server lacks the required tool.|



Page 12 of 14 

Nirvoor Learning — System User Manual 

## **9. Quick reference — all page addresses** 

|**Address**|**Who can open it**|**Page**|
|---|---|---|
|`/homepage`|Anyone|Home|
|`/courses`|Anyone|All courses, with filters|
|`/course-details/<id>`|Anyone|One course|
|`/instructors`|Anyone|Teacher introductions|
|`/store`|Anyone|Books and items|
|`/announcements`|Anyone|Notices|
|`/free-live`|**Anyone — no login**|Free public live classes|
|`/terms`|Anyone|Terms and conditions|
|`/register`·<br>`/login`|Anyone|Sign up / sign in|
|`/profile`|Logged in|Student dashboard — 8 tabs: dashboard, profile,<br>courses, classes, history, certificates, wishlist, settings|
|`/my-courses`|Logged in|Enrolled courses|
|`/enrolled-course/<id>`|Enrolled student|The course hub|
|`/wishlist`·<br>`/history`|Logged in|Saved courses / watch history|
|`/certificates`|Logged in|Certificates|
|`/leaderboard`|Students|Ranking|
|`/notifications`|Logged in|All notifications|
|`/live-class/<id>`|Enrolled student,<br>teacher|Live class room|
|`/quiz/<lessonId>`|Logged in|Take a quiz|
|`/ai-writing/<taskId>`|Logged in|AI writing task|
|`/live-exam/<examId>`|Logged in|Sit a live-class exam|
|`/teacher-evaluation/<courseId>`|Enrolled student|Rate the teacher|
|`/teacher`|**Teacher**|Teacher panel|
|`/live-exam-editor/<liveClassId>`|**Teacher only**|Build a live exam|
|`/exam-submissions/<examId>`|Teacher (mark), Admin<br>(read)|Exam answers|
|`/live-exam-responses/<examId>`|Teacher, Admin|Live exam answers|
|`/admin`|**Admin**|Admin panel — 15 tabs|



Page 13 of 14 

Nirvoor Learning — System User Manual 

|**Address**|**Who can open it**|**Page**|
|---|---|---|
|`/course-manager`|**Admin**|Course authoring (same screen as the teacher panel,<br>with more tabs)|
|`/enrolled-students/<courseId>`|**Admin**|Who is in a course|
|`/quiz-editor/<lessonId>`|**Admin**|Write quiz questions|



**One last thing about times.** Every date and time in the system is Bangladesh time. There is no time-zone conversion anywhere, so what a teacher types is exactly what a student sees. 

Nirvoor Learning — System User Manual, version 1.0, August 2026. Written for testers and new team members. If something behaves differently from this document, the document is probably out of date — please report it. 

Page 14 of 14 

Nirvoor Learning — System User Manual 

