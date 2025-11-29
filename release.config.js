module.exports = {
  branches: [
    "main",
    {
      name: "beta",
      prerelease: true
    },
    {
      name: "alpha",
      prerelease: true
    }
  ],
  repositoryUrl: "https://github.com/freddiedfre/mail-client-installer",
  plugins: [
    ["@semantic-release/changelog", {
      "changelogFile": "CHANGELOG.md"
    }],
    ["@semantic-release/github", {
      "assets": [
        { "path": "CHANGELOG.md", "label": "Changelog" }
      ]
    }],
    ["@semantic-release/git", {
      "assets": ["CHANGELOG.md", "package.json", "VERSION"],
      "message": "chore(release): ${nextRelease.version} [skip ci]\n\n${nextRelease.notes}"
    }]
  ]
};
