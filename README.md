# Able Gate Web

Able Gate Web is the counterpart web application of [Able Gate CLI](https://github.com/ableco/able-gate) for activating / deactivating third-party integrations for Able employees and setup environments for new products.

## Third-party integrations supported

- Abstract
- Asana
- BambooHR
- Dependabot
- GitHub
- Google Groups
- Heroku
- Invision
- Notion
- Sentry
- Slack
- Pivotal Tracker

## Development setup
**Setup db and seed data**
```
rails db:setup
```

**Put yourself as admin, so you can log into the application**
```
rake create_or_set:admin_user\["John, Nash, john@able.co"\]
```

## Environment variables

For development environments, look for the **Able Gate - Staging ENV** note in the **DevOps** vault.

## Tests

`bundle exec rspec`

> **Note**: Be sure to have your `.env` file with the API tokens.
