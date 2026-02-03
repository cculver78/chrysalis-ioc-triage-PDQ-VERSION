# Upload this project to a new GitHub repo

Follow these steps to create a new GitHub repository and push this project.

## 1. Create the repository on GitHub

1. Go to [GitHub](https://github.com) and sign in.
2. Click **New** (or **+** → **New repository**).
3. Set:
   - **Repository name:** e.g. `chrysalis-ioc-triage` (or any name you prefer).
   - **Description:** e.g. `Check Windows for Chrysalis / Lotus Blossom IoCs (Rapid7, Feb 2026)`.
   - **Visibility:** Public or Private.
   - **Do not** add a README, .gitignore, or license (this repo already has them).
4. Click **Create repository**.

## 2. Push from your machine

In PowerShell, from the **project root** (the folder that contains `README.md` and `scripts/`):

```powershell
# If you haven't committed yet (first-time setup)
git init
git add .
git status   # Confirm chrysalis-scan-*.json is not staged (ignored)
git commit -m "Initial commit: Chrysalis / Lotus Blossom IoC checker and docs"

# Add your new GitHub repo as remote (replace YOUR_USERNAME and REPO_NAME with yours)
git remote add origin https://github.com/YOUR_USERNAME/REPO_NAME.git

# If your default branch is 'main'
git branch -M main
git push -u origin main
```

**If you already use SSH:**

```powershell
git remote add origin git@github.com:YOUR_USERNAME/REPO_NAME.git
git push -u origin main
```

Replace `YOUR_USERNAME` with your GitHub username and `REPO_NAME` with the repository name you chose (e.g. `chrysalis-ioc-triage`).

## 3. Optional: Update README clone URL

After the repo is created, edit `README.md` and replace `YOUR_USERNAME/chrysalis-ioc-triage` in the clone URL with your actual username and repo name, then commit and push:

```powershell
git add README.md
git commit -m "docs: fix clone URL in README"
git push
```

## Troubleshooting

- **Authentication:** If `git push` asks for credentials, use a [Personal Access Token](https://github.com/settings/tokens) (HTTPS) or ensure SSH keys are added to GitHub (SSH).
- **Branch name:** If GitHub created the repo with default branch `master`, use `git push -u origin master` or rename to `main` on GitHub and then `git push -u origin main`.
- **Already have a remote?** If `git remote add origin` fails because `origin` exists, use `git remote set-url origin https://github.com/YOUR_USERNAME/REPO_NAME.git` then push.
