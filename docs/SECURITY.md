# Security and Responsible Publication

Raj Cloud Consulting publishes only generic, reusable and sanitised material.

## Never publish

- Company, client or employer names
- Tenant, subscription or object identifiers
- Internal IP addresses, DNS names or resource names
- Usernames, email addresses or employee identifiers
- Passwords, secrets, access tokens or certificates
- Firewall rules that reveal internal architecture
- Proprietary policies, configurations or documentation
- Security controls that could expose a client environment

## Required checks

Every script must be reviewed manually before release. Automated searching helps but does not replace human review.

Recommended searches:

```text
tenant
subscription
client_secret
password
token
certificate
10.
172.
192.168.
.onmicrosoft.com
.internal
.local
```

Use generic placeholders such as:

```powershell
$TenantId = '<TENANT-ID>'
$SubscriptionId = '<SUBSCRIPTION-ID>'
$ResourceGroupName = '<RESOURCE-GROUP>'
```

## Testing

Scripts should be tested in a lab or disposable environment. Public documentation must explain prerequisites, expected changes, rollback considerations and limitations.
