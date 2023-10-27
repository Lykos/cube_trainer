const githubBaseUrl = 'https://github.com/Lykos/cube_trainer'

export const METADATA = {
  maintainer: {
    name: 'Bernhard F. Brodowsky',
    // TODO: Create and use a @cubetrainer.com address for this.
    email: 'bernhard.brodowsky+cubetrainer@gmail.com',
    securityBugEmail: 'bernhard.brodowsky+cubetrainer-security@gmail.com',
  },
  newIssueLinks: {
    choose: `${githubBaseUrl}/issues/new/choose`,
    bug: `${githubBaseUrl}/issues/new?template=bug_report.md&label=bug`,
    featureRequest: `${githubBaseUrl}/issues/new?template=feature_request.md&label=enhancement`,
    securityBug: `${githubBaseUrl}/security/advisories/new`,
  },
  googleAnalyticsId: 'G-SP2ETHT13T',
  consentCookieKey: 'cookie-consent',
  signInStoredUrlStorageKey: 'after-login-redirect',  
};
