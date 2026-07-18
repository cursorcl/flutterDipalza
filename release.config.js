module.exports = {
  branches: ['main'],
  plugins: [
    '@semantic-release/commit-analyzer',
    '@semantic-release/release-notes-generator',
    '@semantic-release/changelog',
    ['@semantic-release/exec', {
      prepareCmd: 'bash scripts/bump_pubspec_version.sh ${nextRelease.version}',
      publishCmd: 'flutter build apk --release && cp build/app/outputs/flutter-apk/app-release.apk build/app/outputs/flutter-apk/dipalza-release-${nextRelease.version}.apk'
    }],
    ['@semantic-release/git', {
      assets: ['pubspec.yaml', 'CHANGELOG.md'],
      message: 'chore(release): ${nextRelease.version} [skip ci]\n\n${nextRelease.notes}'
    }],
    ['@semantic-release/github', {
      assets: [{ path: 'build/app/outputs/flutter-apk/dipalza-release-*.apk' }]
    }]
  ]
};
