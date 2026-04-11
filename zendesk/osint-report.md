# OSINT Reconnaissance Report
## Target: zendesk.com

| Field        | Detail                          |
|--------------|---------------------------------|
| **Author**   | sirdharan thangaraji            |
| **Date**     | 2026-03-31                      |
| **Scope**    | Passive OSINT — zendesk.com     |
| **Method**   | Passive / Open-Source Intelligence |

---

## 1. Executive Summary

This report documents passive OSINT reconnaissance conducted against **zendesk.com**. No active exploitation was performed. The objective was to map publicly available information including domain registration data, DNS infrastructure, exposed subdomains, IP geolocation, network path, web surface metadata, and employee/corporate intelligence.

Key findings:
- Domain is protected by MarkMonitor with all EPP lock statuses enabled.
- DNS is hosted on AWS Route 53; web traffic routes through **Cloudflare** (WAF/CDN).
- Over **200 subdomains** were enumerated via passive sources.
- `robots.txt` reveals internal path structure including marketplace, brand, and partner directories.
- Email infrastructure runs on **Google Workspace**.
- LinkedIn enumeration identified Zendesk India employees in Bengaluru.
- Indian subsidiary (**Zendesk Technologies Pvt. Ltd.**) director details are publicly available via MCA records.

---

## 2. Domain Registration (WHOIS)

| Field                  | Value                                         |
|------------------------|-----------------------------------------------|
| Domain                 | zendesk.com                                   |
| Registry Domain ID     | 157863981_DOMAIN_COM-VRSN                     |
| Registrar              | MarkMonitor Inc. (IANA ID: 292)               |
| Created                | 2005-05-16                                    |
| Last Updated           | 2024-04-15                                    |
| Expiry                 | 2027-05-16                                    |
| Registrant Org         | Zendesk, Inc.                                 |
| Registrant Country     | US                                            |
| Registrant Email       | Redacted (MarkMonitor WHOIS form)             |
| DNSSEC                 | **Unsigned**                                  |
| Abuse Contact          | abusecomplaints@markmonitor.com               |

**Domain Lock Status (all enabled):**
- clientDeleteProhibited
- clientTransferProhibited
- clientUpdateProhibited
- serverDeleteProhibited
- serverTransferProhibited
- serverUpdateProhibited

> **Note:** DNSSEC is not enabled. This leaves the domain theoretically susceptible to DNS cache poisoning if not mitigated elsewhere.

---

## 3. DNS Enumeration

### 3.1 A Records (nslookup)

```
zendesk.com → 216.198.53.2
zendesk.com → 216.198.54.2
```

### 3.2 Name Servers (AWS Route 53)

| Name Server                  |
|------------------------------|
| ns-1213.awsdns-23.org        |
| ns-1858.awsdns-40.co.uk      |
| ns-444.awsdns-55.com         |
| ns-754.awsdns-30.net         |

DNS is fully managed via **Amazon Route 53**, indicating Zendesk's infrastructure is AWS-centric at the DNS layer.

### 3.3 MX Records (Email Infrastructure)

| Priority | Mail Server                  |
|----------|------------------------------|
| Mx0      | aspmx.l.google.com           |
| Mx1      | alt1.aspmx.l.google.com      |
| Mx2      | alt2.aspmx.l.google.com      |
| Mx3      | alt3.aspmx.l.google.com      |
| Mx4      | alt4.aspmx.l.google.com      |

Zendesk uses **Google Workspace** for corporate email. SPF and DMARC records are present.

---

## 4. IP Intelligence

### 4.1 IP Geolocation (216.198.54.2)

| Field        | Value                          |
|--------------|--------------------------------|
| IP Address   | 216.198.54.2                   |
| Country      | United States                  |
| Region       | California                     |
| City         | San Francisco                  |
| Organization | AS209242 — Cloudflare, LLC     |

The resolved IPs are **Cloudflare edge nodes**, meaning the true origin server IP is hidden behind Cloudflare's reverse proxy.

### 4.2 Open Ports (Shodan — 216.198.54.2)

Cloudflare enforces **"Direct IP access not allowed"**, blocking direct origin access. Port scan data reflects Cloudflare's edge, not Zendesk's backend.

Web technology fingerprinting confirms: **CDN: Cloudflare**.

---

## 5. Network Path (Traceroute)

Traceroute conducted over **TCP port 443**:

| Hop | RTT      | Address                     | Note              |
|-----|----------|-----------------------------|-------------------|
| 1   | 3.48 ms  | 192.168.1.1                 | Local gateway     |
| 2   | 5.60 ms  | blr-tdc-bngs-02 (103.57.86.19) | ISP — Bengaluru |
| 3   | 8.24 ms  | 103.57.86.1                 | ISP uplink        |
| 4   | —        | * (no response)             | Filtered hop      |
| 5   | 9.02 ms  | 216.198.54.2                | Cloudflare edge   |

Traffic terminates at Cloudflare's edge in under 10ms from Bengaluru. Origin hops beyond Cloudflare are hidden.

---

## 6. Web Surface Intelligence

### 6.1 robots.txt Analysis

`robots.txt` at `https://www.zendesk.com/robots.txt` reveals internal path structure:

**Disallowed paths (selected):**

| Path                               | Significance                            |
|------------------------------------|-----------------------------------------|
| `/company/index/thank-you/`        | Post-conversion landing page            |
| `/zendesk-adwords-template/`       | Ad campaign template path               |
| `/brand/`, `/brand`                | Brand assets directory                  |
| `/public/assets/html/`             | Public HTML assets                      |
| `/company/add-ons-agreement/`      | Legal/contract pages                    |
| `/company/reseller-add-ons-agreement/` | Reseller contract pages             |
| `/public/assets/sitemaps/`         | Additional sitemap location             |
| `/marketplace/apps`                | Marketplace app listings                |
| `/marketplace/partners`            | Partner directory                       |
| `/marketplace/themes`              | Theme marketplace                       |
| `/blog/ads-api-output/`            | Ads API output                          |
| Multiple `/blog/tags/*-zip`        | Downloadable content archives           |

**Sitemap:** `https://www.zendesk.com/generated_sitemap.xml`
- References `generated_sitemap_part1.xml` and `generated_sitemap_part2.xml`

> **Note:** The `robots.txt` effectively acts as a directory disclosure artifact, revealing paths that Zendesk does not want indexed but are nonetheless visible to anyone reading the file.

---

## 7. Subdomain Enumeration

**200+ subdomains** were passively enumerated. Notable entries:

| Category         | Subdomains                                                             |
|------------------|------------------------------------------------------------------------|
| Core             | www, support, status, developer, training, event, adm                 |
| Partner/Sales    | partnersuccess, sellersfundinghelp                                     |
| Security-adjacent| offensive-security, contrastsecurity, dune-security, gremlin-security, saltsecurity, siteprotect |
| Crypto/Fintech   | bitmart, cryptopia, phantom-wallet, safepalsupport, emurgohelpdesk    |
| Government/Edu   | nysed-op, francecompetences, eccouncil                                 |
| Testing/Dev      | testcenter, nm7uqebiup84rmec6eeb (random-looking subdomain)           |
| Major clients    | gitlab, nvidia1651665403, zillow, wpengine, fourseasons, tesco        |

Full subdomain list: `subdomain.txt` (200 entries)

> The randomized subdomain `nm7uqebiup84rmec6eeb.zendesk.com` is likely a provisioned test or dev tenant.

---

## 8. Employee Intelligence (LinkedIn OSINT)

Passive LinkedIn enumeration identified the following Zendesk India personnel:

| Name               | Role                        | Location            |
|--------------------|-----------------------------|---------------------|
| Koushik Jain       | Solutions (Zendesk India)   | Bengaluru           |
| Kavitha Dinesh     | Senior Workplace (1K+ followers) | Bengaluru      |
| Niharika S N       | Services Consultant         | Bengaluru           |
| Vishal Srivastava  | Senior Business Systems     | Greater Bengaluru   |

> These identities could be targeted in spear-phishing or social engineering scenarios. This data was gathered from public LinkedIn profiles without authentication.

---

## 9. Corporate Intelligence — Indian Subsidiary

**Entity:** Zendesk Technologies Private Limited

| Field              | Value                                                        |
|--------------------|--------------------------------------------------------------|
| Incorporation Date | 19 May 2016                                                  |
| Entity Type        | Foreign Company (India subsidiary)                           |
| Industry           | Computer Related Services; Marketing Management Consulting   |
| Auth Capital       | ₹20.0 Lakh                                                   |
| Paid-up Capital    | ₹5.0 Lakh                                                    |
| Revenue            | ₹50–75 Crore                                                 |
| Registered Address | Salarpuria Sigma, Bengaluru (Karnataka)                      |

**Directors:**

| Name                   | DIN      | Tenure    |
|------------------------|----------|-----------|
| Rajendra Singh Rathore | 02365241 | 10 years  |
| Julie Ann Swinney      | 10334694 | 3 years   |

> Director DIN numbers are public MCA records and can be used to cross-reference other company affiliations via India's Ministry of Corporate Affairs portal.

---

## 10. Summary of Findings

| Category                | Finding                                                           | Risk Level |
|-------------------------|-------------------------------------------------------------------|------------|
| DNSSEC not enabled      | Domain vulnerable to DNS spoofing if no edge-level mitigation    | Low–Medium |
| Cloudflare WAF/CDN      | Origin IP is hidden; direct access blocked                        | Mitigated  |
| robots.txt disclosure   | Internal path structure exposed                                   | Informational |
| 200+ subdomains         | Large attack surface; some tenants may be misconfigured           | Medium     |
| Google Workspace email  | Target for BEC/phishing if SPF/DMARC not strictly enforced       | Medium     |
| Employee enumeration    | LinkedIn profiles accessible; social engineering risk             | Medium     |
| Director PII (India)    | Publicly available DIN and tenure via MCA                        | Informational |
| AWS Route 53 DNS        | DNS infrastructure identified; no immediate risk                  | Informational |

---

## 11. Tools Used

| Tool         | Purpose                              |
|--------------|--------------------------------------|
| `whois`      | Domain registration data             |
| `nslookup`   | DNS resolution                       |
| `traceroute` | Network path mapping (TCP 443)       |
| `ping`       | Subdomain liveness check             |
| ipinfo.io    | IP geolocation                       |
| Shodan       | Port scan / web technology detection |
| robots.txt   | Web surface crawl metadata           |
| LinkedIn     | Employee / personnel OSINT           |
| MCA Portal   | Indian corporate registry lookup     |
| Subfinder    | Passive subdomain enumeration        |

---

## 12. Recommendations

1. **Enable DNSSEC** on zendesk.com to prevent DNS cache poisoning attacks.
2. **Audit subdomain inventory** — decommission unused or randomized tenants.
3. **Review robots.txt** — evaluate whether disallowed paths expose sensitive structural information that could aid an attacker.
4. **Enforce DMARC in `p=reject` mode** to prevent email spoofing.
5. **Employee awareness training** — LinkedIn-visible personnel are prime social engineering targets; ensure phishing awareness programs are in place.

---

*This report is for educational/authorized security assessment purposes only.*
