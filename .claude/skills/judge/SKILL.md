---
name: judge
description: Review a deadline project (hackathon profile) as its sceptical judge in a fresh session - score against the brief, ask the first question, rank issues by value per hour. "final" adds hand-in checks.
disable-model-invocation: true
---

# judge - the project through the eyes of the person it is for

Review type: the arguments (empty means the judge pass, "final" the final
review). Run it in a new session: a reviewer that watched the work being
built ends up grading its own work.

1. Before opening the code, read the brief and rules the human attaches and
   take the role of the person in "For". If nothing is attached, use
   `docs/brief.md`.
2. Then open the repo. Run the app and the Check command. Read the data and
   every published file.
3. Score the project against "Judged on", with evidence for each score. If no
   criteria were given, use: answers the first question, sound method, clear
   result, usable next week, data handled properly.
4. Ask the First question and read the top results. Do they answer it
   usefully? Does every user group named in the brief get something it can use?
5. List the issues ranked by value per hour of fixing. Don't fix anything;
   the human decides.
6. If this is the final review, also: check every item in "Hand-in"; if
   there's a deck, export it to PDF and read the PDF; if there's a video, look
   at one still per scene (the video project's notes say how) and read the
   narration; compare the scores with the last judge pass in docs/history.md.
7. Append the result to docs/history.md and add one line to PROGRESS.md.
