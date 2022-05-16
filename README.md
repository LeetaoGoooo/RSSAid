<h1 align=center>RSSAid</h1>

<p align=center>
<a href="https://developer.apple.com/swift"><img src="https://img.shields.io/badge/flutter-1.22.4-fe562e?style=flat-square"></a>
<a href="https://developer.apple.com/ios"><img src="https://img.shields.io/badge/SdkVersion-21%2B-blue?style=flat-square"></a>
<img src="https://img.shields.io/badge/license-MIT-lightgrey.svg?style=flat-square">
</p>

> RSSAid is a complementary app for [RSSHub](https://github.com/DIYgod/RSSHub) built with Flutter, similar to [RSSHub Radar](https://github.com/DIYgod/RSSHub-Radar), which helps you quickly discover and subscribe to RSS feeds from websites, and supports common parameters of RSSHub (for filtering, getting full text, etc.)
> [ChineseVersion](README_CN.md)

[Telegram group](https://t.me/rssaid_group) | [Telegram channel](https://t.me/rssaid)

<p float='left'>
<img src="screenshots/en-home.png" width="375">
<img src="screenshots/en-settings.png" width="375">
</p>

## Install

[<img src="https://fdroid.gitlab.io/artwork/badge/get-it-on.png"
     alt="Get it on F-Droid"
     height="80">](https://f-droid.org/packages/com.gmail.cn.leetao94.rssaid/)

The latest build for Android can be found in [the releases](https://github.com/lt94/RSSAid/releases).

Join our [Telegram channel](https://t.me/rssaid_group) to keep updated.

## Build

If you wish to build the application from source, please refer to the [official documentation by Flutter](https://flutter.cn/docs/deployment/android).

## Features

- [x] Detect RSSHub sources from URL (Supports almost all rules as RSSHub Radar)
- [x] Supports mobile-only URLs (auto URL expansion for shortlinks and mobile subdomains)
- [x] Import URLs from clipboard
- [x] Quick subscription
- [x] Customizable general parameters
- [x] Customizable RSSHub server
- [x] Auto-update RSSHub Radar rules
- [x] Supports Weibo
- [x] Supports customized rules
- [x] Save history
- [x] RSS+ rules
- [x] Available on FDroid
- [x] English version


## Join beta program

Join our [Telegram group](https://t.me/rssaid_group) for latest information.

## Rules

RSSAid use the same [rules](https://github.com/DIYgod/RSSHub/blob/master/assets/radar-rules.js) as [RSSHub Radar](https://github.com/DIYgod/RSSHub-Radar) and both supports auto-update.

If you wish to submit new rules for RSSHub Radar and RSSAid, see [how](https://docs.rsshub.app/joinus/#ti-jiao-xin-de-rsshub-radar-gui-ze).

> Note that rules using `document` in `target` is not applicable to RSSAid. RSSAid is NOT a browser extension, it simply gets and parses URL.

> Some pages have different URLs for mobile and PC, but rules on RSSHub Radar only supports PC-style URLs. RSSAid will try to convert mobile-specific URLs, but if you find a URL that is valid on RSSHub Radar but not on RSSAid, try using the URL for PC, and report the issue on Telegram.

## Sponsor

RSSAid is a open-source project under MIT license. It's completely free to use it.

If you like our project, you can donate to our project.

### Periodic sponsorship

Periodic sponsorship have additional benefits: your issues on GitHub will be responded faster, your name will appear in our GitHub repository.

*   [Donate using Afdian](https://afdian.net/@leetao)

*   Mail to leetao@email.cn for sponsorship-related support.

### One-time sponsorship

You can donate with Alipay or WeChat.

*   [Alipay](http://ww1.sinaimg.cn/large/006wYWbGly1fm10itkjb6j30aj0a9t8w.jpg)

*   [WeChat Pay](http://ww1.sinaimg.cn/large/006wYWbGly1fm10jihygsj309r09tglw.jpg)

## Author

RSSAid is made by Leetao and licensed under **MIT license**.
