# SSO

[Participating institutions](https://dmptool.org/about_us) can enable SSO authentication for their users. The setup involves coordination between your institution's Identity and Access Management team and the DMPTool's administrators. Please refer to the sections below for details on your specific configuration.

We have limited development resources and can only support integrations with institutions that are members of the [InCommon Federation](https://www.incommon.org/) or [eduGAIN](https://technical.edugain.org/metadata)

The DMPTool requires that the following SAML attributes are released:
- `eduPersonPrincipalName` **required** (aka eppn, the user's unique identifier. The value should be universally unique, the most common value is the email)
- `mail` **required** (the users email address)
- `displayName` (the user's first and last name)
- or send `givenname` and `sn`as seperate fields

Once your institution's Identity Provider is configured correctly, a DMPTool administrator can enable your institution to use SSO within the DMPTool. Once enabled, your users will select your institution from the DMPTool login screen then be redirected to your institution's login page to authenticate.

If you have users already using the DMPTool will retain their accounts once SSO has been enabled:
- If the `mail` your system provides matches the email address your user used to create their account, their existing account will be auto-linked to their `eppn` and they will login automatically.
- If the email address does not match, they will be brought to an interim 'Finish creating your account' screen that will allow them to login via their email address and old password. Once they login via their password, their account will be linked. All future logins for the user can then be done via SSO.

## DMPTool Service Provider Metadata

The DMPTool has two separate instances. One for production and one for staging/testing new features and functionality.

- [DMPTool stage/test SP metadata](https://mdq.incommon.org/entities/https%3A%2F%2Fdmp-stage.cdlib.org)
- [DMPTool production SP metadata](https://mdq.incommon.org/entities/https%3A%2F%2Fdmp.cdlib.org)

Note that if your identity provider does not allow you to import an entire metadata scheme (like the ones listed above) and instead asks you to specify a specific 'AssertionConsumerService' then you should use: `https://dmptool.org/Shibboleth.sso/SAML2/POST`

## My institution is a member of the [Research & Scholarship (R&S) category](https://refeds.org/research-and-scholarship)
The Research and Scholarship Entity Category (R&S) is a simple way for Identity Providers to release minimal required attributes to Service Providers serving the Research and Scholarship Community.  Being a member automatically guarantees that your identity provider releases the correct attributes to the DMPTool.

Send us your identity provider's `entityID` so that we can enable SSO for your users.

## My institution is a NOT a member of R&S

If your instution is a member of the InCommon Federation but NOT within the Research & Scholarship category, your institution's identity provider may need to be configured to release the attributes mentioned above for the DMPToool.  Your Identity and Access Management team can use the following information to make the necessary changes:
- [Attribute Release Policy](https://github.com/CDLUC3/dmptool/blob/main/docs/sso/dmptool_attribute_release.xml)
- [Attribute Map](https://github.com/CDLUC3/dmptool/blob/main/docs/sso/dmptool_attribute_map.xml)

Once that's complete you can send us your identity provider's `entityID` so that we can enable SSO for your users.

## Testing

Once your institution's identity provider has been configured and SSO has been enabled for your institution within the DMPTool, you can visit our [SSO Test Page](https://dmptool.org/cgi-bin/PrintShibInfo.pl) to test the SSO handshake. Select your institution from the dropdown list and click the "Continue" button. This should bring you to your institution's login page if things were properly configured within the DMPTool. Once you login, you will be redirected back to a validation page that will display the attributes mentioned above.  If all has been properly configured within your identity provider, a Success message will be displayed.

## Troubleshooting

### I was able to successfully log in to my SSO but I receive a 500 error from the DMPTool.

This indicates that there was a communication issue between your institution's login page and the DMPTool. The most common cause is that your institution's SSO did not send the DMPTool a unique identifier (aka an eppn) or did not provide your email. The DMPTool requires these 2 attributes in order to correctly identify your account.

Please visit our [SSO Test Page](https://dmptool.org/cgi-bin/PrintShibInfo.pl), select your institution from the list (InCommon and eduGAIN institutions only), login to your institution's SSO page, and then send us a screenshot of the page you are redirected to. It should include an eppn, email address. Then contact us and provide the screenshot to help us diagnose the problem.

If the [SSO Test Page](https://dmptool.org/cgi-bin/PrintShibInfo.pl) shows a blank eppn or email address, you will need to contact your internal IT team that manages your SSO. They will need to update the system to release that information to the DMPTool.

### I clicked on the button to sign in with my institutional credentials and received an 'opensaml::FatalProfileException' error

This message was received from your institution's SSO which did not recognize the DMPTool as a trusted service provider. You will need to contact your IT department that supports your SSO to have them add the DMPTool as a trusted service. Include a link to this page when you contact them.

### I clicked on the button to sign in with my institutional credentials and received an 'Unknown or unusable identitiy provider' error

We use an 'entityID' to determine where the URL of your SSO system. You would receive this message if we have the wrong entityID for your institution. You can find your institution's entityID from the [InCommon](https://www.incommon.org/community-organizations/) or [eduGAIN](https://technical.edugain.org/entities) directories.
