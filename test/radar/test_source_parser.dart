import 'dart:convert';

import 'package:rssaid/radar/rsshub.dart';
import 'package:rssaid/radar/rule_type/page_info.dart';
import 'package:rssaid/radar/source_parser.dart';
import 'package:test/test.dart';

void main() {
  group('SourceParser', () {
    test('getPosition returns correct Position for valid URL', () {
      var parser = SourceParser(
          target: "/github/branches/:user/:repo",
          url: 'https://github.com/DIYgod/RSSHub-Radar');
    });
  });

  group("RssHub", () {
    test("Translating Github addresses", () {
      final RssHub rssHub = RssHub();
      Map<String, dynamic> githubRules = {
        "github.com": {
          "_name": "GitHub",
          ".": [
            {
              "title": "User Activities",
              "docs": "https://docs.rsshub.app/routes/programming",
              "source": [
                "/:user"
              ],
              "target": "/github/activity/:user"
            },
            {
              "title": "Github Advisory Database RSS",
              "docs": "https://docs.rsshub.app/routes/programming",
              "source": [
                "/advisories",
                "/"
              ],
              "target": "/github/advisor/data/:type?/:category?"
            },
            {
              "title": "Repo Branches",
              "docs": "https://docs.rsshub.app/routes/programming",
              "source": [
                "/:user/:repo/branches",
                "/:user/:repo"
              ],
              "target": "/github/branches/:user/:repo"
            },
            {
              "title": "Issue / Pull Request comments",
              "docs": "https://docs.rsshub.app/routes/programming",
              "source": [
                "/:user/:repo/:type",
                "/:user/:repo/:type/:number"
              ],
              "target": "/github/comments/:user/:repo/:number?"
            },
            {
              "title": "Repo Contributors",
              "docs": "https://docs.rsshub.app/routes/programming",
              "source": [
                "/:user/:repo/graphs/contributors",
                "/:user/:repo"
              ],
              "target": "/github/contributors/:user/:repo"
            },
            {
              "title": "Repo Discussions",
              "docs": "https://docs.rsshub.app/routes/programming",
              "source": [
                "/:user/:repo/discussions",
                "/:user/:repo/discussions/:id",
                "/:user/:repo"
              ],
              "target": "/github/discussion/:user/:repo"
            },
            {
              "title": "File Commits",
              "docs": "https://docs.rsshub.app/routes/other",
              "source": [
                "/:user/:repo/blob/:branch/*filepath"
              ],
              "target": "/github/file/:user/:repo/:branch/:filepath"
            },
            {
              "title": "User Followers",
              "docs": "https://docs.rsshub.app/routes/programming",
              "source": [
                "/:user"
              ],
              "target": "/github/user/followers/:user"
            },
            {
              "title": "Repo Issues",
              "docs": "https://docs.rsshub.app/routes/programming",
              "source": [
                "/:user/:repo/issues",
                "/:user/:repo/issues/:id",
                "/:user/:repo"
              ],
              "target": "/github/issue/:user/:repo"
            },
            {
              "title": "Notifications",
              "docs": "https://docs.rsshub.app/routes/programming",
              "source": [
                "/notifications"
              ],
              "target": "/github/notifications"
            },
            {
              "title": "Repo Pull Requests",
              "docs": "https://docs.rsshub.app/routes/programming",
              "source": [
                "/:user/:repo/pulls",
                "/:user/:repo/pulls/:id",
                "/:user/:repo"
              ],
              "target": "/github/pull/:user/:repo"
            },
            {
              "title": "Repo Pulse",
              "docs": "https://docs.rsshub.app/routes/programming",
              "source": [
                "/:user/:repo/pulse",
                "/:user/:repo/pulse/:period"
              ],
              "target": "/github/pulse/:user/:repo/:period?"
            },
            {
              "title": "User Repo",
              "docs": "https://docs.rsshub.app/routes/programming",
              "source": [
                "/:user"
              ],
              "target": "/github/repos/:user"
            },
            {
              "title": "Repo Stars",
              "docs": "https://docs.rsshub.app/routes/programming",
              "source": [
                "/:user/:repo/stargazers",
                "/:user/:repo"
              ],
              "target": "/github/stars/:user/:repo"
            },
            {
              "title": "User Starred Repositories",
              "docs": "https://docs.rsshub.app/routes/programming",
              "source": [
                "/:user"
              ],
              "target": "/github/starred_repos/:user"
            },
            {
              "title": "Topics",
              "docs": "https://docs.rsshub.app/routes/programming",
              "source": [
                "/topics"
              ],
              "target": "/github/topics/:name/:qs?"
            },
            {
              "title": "Trending",
              "docs": "https://docs.rsshub.app/routes/programming",
              "source": [
                "/trending"
              ],
              "target": "/github/trending/:since"
            },
            {
              "title": "Wiki History",
              "docs": "https://docs.rsshub.app/routes/programming",
              "source": [
                "/:user/:repo/wiki/:page/_history",
                "/:user/:repo/wiki/:page",
                "/:user/:repo/wiki/_history",
                "/:user/:repo/wiki"
              ],
              "target": "/github/wiki/:user/:repo/:page"
            }
          ],
          "gist": [
            {
              "title": "Gist Commits",
              "docs": "https://docs.rsshub.app/routes/programming",
              "source": [
                "/:owner/:gistId/revisions",
                "/:owner/:gistId/stargazers",
                "/:owner/:gistId/forks",
                "/:owner/:gistId"
              ],
              "target": "/github/gist/:gistId"
            }
          ]
        }
      };
      PageInfo pageInfo = new PageInfo(
          url: "https://github.com/FlareSolverr/FlareSolverr/pull/1301",
          rules: jsonEncode(githubRules));
      var radars =  rssHub.getPageRSSHub(pageInfo);
      radars.forEach((radar) => print(radar.path));
    });
  });
}
