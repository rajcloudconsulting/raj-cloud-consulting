# Script Publishing Checklist

Complete this checklist before publishing any script.

## Sanitisation

- [ ] Company and client names removed
- [ ] Tenant, subscription and object IDs removed
- [ ] Internal IP addresses and hostnames removed
- [ ] Email addresses and usernames removed
- [ ] Credentials, tokens, secrets and certificates removed
- [ ] Production resource names replaced with placeholders
- [ ] Comments and sample output checked for sensitive data

## Quality

- [ ] Script has a clear synopsis and description
- [ ] Parameters are documented
- [ ] Error handling is included
- [ ] Destructive actions support preview or confirmation
- [ ] Prerequisites are documented
- [ ] Tested in a non-production environment
- [ ] Expected output is documented
- [ ] Rollback or recovery guidance is provided where relevant

## Commercial release

- [ ] Product name and version assigned
- [ ] Licence terms included
- [ ] Support boundaries defined
- [ ] Refund policy defined
- [ ] Download package scanned
- [ ] Product page does not overstate capabilities
