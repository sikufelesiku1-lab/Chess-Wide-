# GLOBAL CHESS ARENA — free starter

This is a starter website for your tournament project. The front page works immediately in **preview/demo mode**. Real accounts and saved tournaments require connecting the free Supabase backend. The app is not a completed, production-ready chess server yet: authoritative move validation, full tournament fixture automation, anti-cheat review, and secure real-time match play still need to be implemented before running serious competitions.

## Free services
- **Cloudflare Pages** can host the static website on its free plan. Official limits: https://developers.cloudflare.com/pages/platform/limits/
- **Supabase Free** provides authentication, database and Realtime for small projects. It currently includes 2 active free projects and 500 MB database storage; inactive free projects may pause after a week. Details: https://supabase.com/pricing

## Setup from an Android phone

### 1. Create your free database
1. Open https://supabase.com and create a free account.
2. Create a project. Save the database password somewhere private.
3. Open **SQL Editor**, create a new query, paste all of `schema.sql`, and run it.
4. Open **Project Settings → API**. Copy the Project URL and anon/public key.

### 2. Connect this website
1. Open `app.js` in the project files.
2. Put your Supabase Project URL inside `SUPABASE_URL` and your anon/public key inside `SUPABASE_ANON_KEY`.
3. Save the file. Never put your database password or service-role key in the website.

### 3. Make yourself Super Admin
1. Register your own account on the website.
2. In Supabase → SQL Editor, run this statement after replacing the email:
   `update public.profiles set is_admin=true where id=(select id from auth.users where email='YOUR_EMAIL_HERE');`
3. Refresh the website. Your Super Admin panel will appear.

### 4. Publish free
1. Create a free account at https://github.com and make a new repository.
2. Upload the files in this folder to the repository (not the ZIP itself).
3. Create a free account at https://cloudflare.com, open **Workers & Pages → Create → Pages → Connect to Git**.
4. Select your repository. For a plain HTML site, use no build command and set the output directory to `/` (or the repository root, depending on the dashboard prompt).
5. Deploy. Cloudflare gives you a public `*.pages.dev` link to share.

## Tournament rules already specified
- Four players per group.
- Each player faces each of the other three players three times: 9 games per player.
- Win 3 points, draw 1, loss 0.
- Top two in each group qualify.
- Knockouts: cross-group pairings, quarter-finals, semi-finals, final; best-of-three, first to two wins.

## Important
The free plan is suitable for a small community project and has usage/inactivity limits. The starter currently demonstrates the public site, registration flow wiring, tournament creation/joining, and tournament information. It does **not** yet provide a fully secure, production-grade multiplayer chess service. Do not collect payments or run high-stakes events on this starter until the missing server-side game and tournament logic is completed and tested.
