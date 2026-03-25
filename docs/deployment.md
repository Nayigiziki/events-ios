# Deployment Guide

This project uses [deploy-workflows](https://github.com/Nayigiziki/deploy-workflows) for automated TestFlight deployment via GitHub Actions.

## How It Works

When you push a version tag (e.g., `v1.0.0`), GitHub Actions automatically:
1. Builds the app with Fastlane
2. Signs it with your App Store Connect API key
3. Uploads to TestFlight
4. Testers get notified in ~15-30 minutes

The workflow lives in `.github/workflows/release.yml` and calls a shared reusable workflow from `Nayigiziki/deploy-workflows`.

## One-Time Setup

### 1. Configure GitHub Secrets

Clone the deploy-workflows repo and run the setup script:

```bash
git clone https://github.com/Nayigiziki/deploy-workflows.git
cd deploy-workflows
./scripts/setup-secrets.sh Nayigiziki/<your-repo-name>
```

This reads credentials from `~/.deploy-secrets` and pushes them to your repo. If you don't have `~/.deploy-secrets` yet, create it:

```bash
cat > ~/.deploy-secrets << 'EOF'
APP_STORE_CONNECT_API_KEY_ID=your_key_id
APP_STORE_CONNECT_ISSUER_ID=your_issuer_id
APP_STORE_CONNECT_API_KEY_CONTENT=<base64 -i path/to/AuthKey.p8>
APPLE_TEAM_ID=your_team_id
RAILWAY_TOKEN=your_railway_token
EOF
```

### 2. Ensure Fastlane is configured

Your `ios/fastlane/Fastfile` must have a `beta` lane (included by default in this template). The shared workflow calls `bundle exec fastlane beta`.

### 3. Ensure code signing

The template uses Fastlane Match for certificate management. Run once per machine:

```bash
cd ios && bundle exec fastlane sync_signing
```

## Releasing

```bash
# Bump version and create tag
cd ios && bundle exec fastlane bump type:patch
git add -A && git commit -m "chore(release): bump version"
git tag v1.0.1
git push origin main --tags
```

Or use the template's release script if available:
```bash
./ios/scripts/deploy-testflight.sh
```

## Adding a Backend

If your project has a Railway backend, add a backend job to `.github/workflows/release.yml`:

```yaml
jobs:
  backend:
    uses: Nayigiziki/deploy-workflows/.github/workflows/deploy-railway.yml@main
    with:
      health-check-path: /api/health
    secrets: inherit

  ios:
    # ... existing ios job
```

Make sure `RAILWAY_TOKEN` is included in your `~/.deploy-secrets`.

## Secrets Reference

| Secret | Required | Description |
|--------|----------|-------------|
| `APP_STORE_CONNECT_API_KEY_ID` | Yes | API key ID from App Store Connect |
| `APP_STORE_CONNECT_ISSUER_ID` | Yes | Issuer ID from App Store Connect |
| `APP_STORE_CONNECT_API_KEY_CONTENT` | Yes | Base64-encoded .p8 key file |
| `APPLE_TEAM_ID` | Yes | Apple Developer Team ID |
| `MATCH_PASSWORD` | If using Match | Fastlane Match encryption password |
| `RAILWAY_TOKEN` | If has backend | Railway project deploy token |

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Workflow not triggering | Verify tag format is `v*` (e.g., `v1.0.0`) |
| Missing secrets error | Run `setup-secrets.sh` for your repo |
| Build fails | Check `gh run view --log` for Fastlane output |
| Code signing error | Run `fastlane sync_signing` locally first |
| Upload timeout | Workflow retries 3 times automatically |
