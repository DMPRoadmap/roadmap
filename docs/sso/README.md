# SSO

[Participating institutions](https://dmptool.org/about_us) can enable SSO authentication for their users. The setup involves coordination between your institution's Identity and Access Management team and the DMPTool's administrators. Please refer to the sections below for details on your specific configuration.

The DMPTool requires that the following SAML attributes are released:
- `eduPersonPrincipalName` **required** (aka eppn, the user's unique identifier)
- `mail` **required** (the users email address)
- `displayName` (the user's first and last name)

Once your institution's identity provider is configured correctly. A DMPTool administrator can authorize your institution to use SSO. Once enabled, your users will be redirected to your institution's login page when they select your institution from the login screen.

If you have users already using the DMPTool will retain their accounts once SSO has been enabled:
- If the `mail` your system provides matches the email address your user used to create their account, their existing account will be auto-linked to their `eppn` and they will login automatically.
- If the email address does not match, they will be brought to an interim 'Finish creating your account' screen that will allow them to login via their email address and old password. Once they login via their password, their account will be linked. All future logins for the user can then be done via SSO.

## My institution is a member of the [InCommon Federation](https://www.incommon.org/)

This is the simplest way to enable SSO for your institution. InCommon's [Research and Scholarship category](https://incommon.org/federation/research-and-scholarship/) automatically guarantees that your identity provider releases the correct attributes.

Send us your identity provider's `entityID` so that we can enable SSO for your users.

## My institution is a member of [eduGAIN](https://technical.edugain.org/metadata)

Your institution's identity provider may need to be configured to release the attributes mentioned above for the DMPToool. The DMPTool will also need to be added as a trusted service provider. Your Identity and Access Management team can use the following information to make the necessary changes:
- [Attribute Release Policies](https://github.com/CDLUC3/dmptool/blob/main/doc/sso/dmptool_attribute_release.xml)
- [DMPTool stage/test service provider](https://github.com/CDLUC3/dmptool/blob/main/doc/sso/dmp-stage_metadata.xml)
- [DMPTool production service provider](https://github.com/CDLUC3/dmptool/blob/main/doc/sso/dmp_metadata.xml)

Once that's complete you can send us your identity provider's `entityID` so that we can enable SSO for your users.

## Testing

Once your institution's identity provider has been configured and SSO has been enabled for your institution within the DMPTool, you can use visit our [SSO Test Page](https://dmptool-stg.cdlib.org/cgi-bin/PrintShibInfo.pl) to test the SSO handshake. Select your institution from the dropdown list and click the button. This should bring you to your institution's login page if things were properly configured within the DMPTool. Once you login, you will be redirected back to a test page that should display the attributes mentioned above if things were properly configured within your identity provider.

If your name does not appear in the dropdown list, then you may not be a member of InCommon or eduGAIN. Contact us for more information.
