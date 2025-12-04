# Video Script: Self-Service Infrastructure with GitOps

**Total Duration:** ~5-6 minutes
**Recording Tool:** Screen recording with voiceover (e.g., Loom, OBS, QuickTime)

---

## Scene 1: Introduction (30 seconds)

**Screen:** Title slide or README

**Script:**
> "Today I'll show you a self-service infrastructure provisioning system that combines the power of Terraform, GitHub Actions, and AWS.
>
> The problem we're solving: Teams need cloud resources quickly, but we also need governance, security, and an audit trail. Traditional ticketing systems are slow, and giving everyone direct AWS access is risky.
>
> This solution lets users request resources through a simple portal, while maintaining full GitOps control."

---

## Scene 2: Architecture Overview (45 seconds)

**Screen:** Open `docs/architecture.svg` in browser

**Script:**
> "Here's how the workflow works:
>
> 1. **Submit Request** - Users fill out a form in our self-service portal
> 2. **Auto-Generate** - GitHub Actions creates Terraform code and opens a Pull Request
> 3. **Review** - The team reviews the PR, sees the Terraform plan, and approves
> 4. **Deploy** - On merge, Terraform applies automatically and resources are live in AWS
>
> Everything is tracked in Git. No stored AWS credentials - we use OIDC. Full audit trail. And requests move through folders: pending, in-progress, deployed, or failed."

---

## Scene 3: Portal Demo (1-2 minutes)

**Screen:** Open https://alqattandev.github.io/terraform-workflow-aws/

**Script:**
> "Let's submit a real request. This is our CloudOps Portal.
>
> At the top, you can see the 4-step workflow.
>
> First, I'll enter my GitHub token - this is needed to trigger the workflow.
>
> Now for the request:
> - Ticket ID is auto-generated
> - I'll enter my email
> - Let's request an **S3 Bucket** for a new project
> - Resource name: `demo-data-lake`
> - Environment: **Production**
> - Region: **US East**
> - I'll enable versioning for data protection
>
> And... Submit!
>
> *[Click Submit]*
>
> Great - we got a success message with our ticket ID. The PR should be created in about 10 seconds."

---

## Scene 4: Pull Request Review (1-2 minutes)

**Screen:** Open GitHub Pull Requests tab

**Script:**
> "Let's check the Pull Request.
>
> *[Click on the new PR]*
>
> Here's our auto-generated PR. Notice:
> - The title includes the ticket ID and resource details
> - The description shows all the request information in a table
> - It's labeled with `infrastructure`, `automated`, and `production`
>
> Now let's look at the **Files Changed**:
>
> *[Click Files Changed]*
>
> This is the generated Terraform code. It includes:
> - The S3 bucket with encryption enabled
> - Public access blocking for security
> - Versioning configuration
> - All the proper tags including our ticket ID
>
> And check the **Terraform Plan** in the PR comments:
>
> *[Scroll to PR comment with plan]*
>
> We can see exactly what will be created before approving. This is reviewed by the team.
>
> Let's approve and merge.
>
> *[Merge the PR]*"

---

## Scene 5: Deployment & Verification (1 minute)

**Screen:** GitHub Actions tab, then AWS Console

**Script:**
> "Once merged, the Terraform Apply workflow runs automatically.
>
> *[Show Actions tab with running workflow]*
>
> It's applying now... and done!
>
> Let's verify in AWS:
>
> *[Open AWS S3 Console]*
>
> There's our bucket - `demo-data-lake`. Let's check the properties:
> - Encryption: Enabled
> - Versioning: Enabled
> - Public access: All blocked
> - Tags include our ticket ID for tracking
>
> And back in our repo, the request has moved from `in-progress` to `deployed`."

---

## Scene 6: Summary (30 seconds)

**Screen:** Return to architecture diagram or README

**Script:**
> "That's the complete workflow:
>
> **Benefits:**
> - **Self-service** - Users get resources in minutes, not days
> - **Governance** - Every change requires PR approval
> - **Security** - OIDC auth, no stored credentials, encrypted state
> - **Audit trail** - Full history in Git
> - **Extensible** - Add new resource templates easily
>
> All powered by Terraform, GitHub Actions, and AWS - tools your team probably already uses.
>
> Check out the repo link in the description to try it yourself. Thanks for watching!"

---

## Recording Checklist

### Before Recording:
- [ ] Clean browser (no sensitive tabs/bookmarks visible)
- [ ] GitHub token ready to paste
- [ ] AWS Console logged in
- [ ] Close unnecessary applications
- [ ] Check microphone levels

### URLs to Have Ready:
1. Portal: https://alqattandev.github.io/terraform-workflow-aws/
2. Architecture: https://alqattandev.github.io/terraform-workflow-aws/architecture.svg
3. GitHub Repo: https://github.com/AlqattanDev/terraform-workflow-aws
4. Pull Requests: https://github.com/AlqattanDev/terraform-workflow-aws/pulls
5. Actions: https://github.com/AlqattanDev/terraform-workflow-aws/actions
6. AWS S3 Console: https://s3.console.aws.amazon.com/s3/buckets

### Demo Request Details:
- **Resource Type:** S3 Bucket
- **Resource Name:** `demo-data-lake`
- **Environment:** Production
- **Region:** US East (us-east-1)
- **Versioning:** Enabled

---

## Post-Recording

1. Trim dead air and mistakes
2. Add simple intro/outro if desired
3. Consider adding background music (low volume)
4. Export at 1080p minimum
5. Upload to YouTube/Loom/Vimeo
6. Add description with repo link
