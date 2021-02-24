# SSO

[Participating institutions](https://dmptool.org/about_us) can enable SSO authentication for their users. The setup involves coordination between your institution's Identity and Access Management team and the DMPTool's administrators. Please refer to the sections below for details on your specific configuration.

The DMPTool requires that the following SAML attributes are released:
- `eduPersonPrincipalName` **required** (aka eppn, the user's unique identifier. The value should be universally unique, the most common value is the email)
- `mail` **required** (the users email address)
- `displayName` (the user's first and last name)

Once your institution's Identity Provider is configured correctly, a DMPTool administrator can enable your institution to use SSO within the DMPTool. Once enabled, your users will select your institution from the DMPTool login screen then be redirected to your institution's login page to authenticate.

If you have users already using the DMPTool will retain their accounts once SSO has been enabled:
- If the `mail` your system provides matches the email address your user used to create their account, their existing account will be auto-linked to their `eppn` and they will login automatically.
- If the email address does not match, they will be brought to an interim 'Finish creating your account' screen that will allow them to login via their email address and old password. Once they login via their password, their account will be linked. All future logins for the user can then be done via SSO.

## My institution is a member of the [InCommon Federation](https://www.incommon.org/) or [eduGAIN](https://technical.edugain.org/metadata)

Send us your identity provider's `entityID` so that we can enable SSO for your users.

## My institution is a member of the [Research & Scholarship (R&S) category](https://refeds.org/research-and-scholarship)
The Research and Scholarship Entity Category (R&S) is a simple way for Identity Providers to release minimal required attributes to Service Providers serving the Research and Scholarship Community.  Being a member automatically guarantees that your identity provider releases the correct attributes to the DMPTool.  

## My institution is a NOT a member of R&S

If your instution is a member of the InCommon Federation but NOT within the Research & Scholarship category, your institution's identity provider may need to be configured to release the attributes mentioned above for the DMPToool.  Your Identity and Access Management team can use the following information to make the necessary changes:
- [Attribute Release Policies](https://github.com/CDLUC3/dmptool/blob/main/docs/sso/dmptool_attribute_release.xml)

DMPTool Service Provider Metadata
- [DMPTool stage/test service provider](https://github.com/CDLUC3/dmptool/blob/main/docs/sso/dmp-stage_metadata.xml)
- [DMPTool production service provider](https://github.com/CDLUC3/dmptool/blob/main/docs/sso/dmp_metadata.xml)

Once that's complete you can send us your identity provider's `entityID` so that we can enable SSO for your users.

## Testing

Once your institution's identity provider has been configured and SSO has been enabled for your institution within the DMPTool, you can visit our [SSO Test Page](https://dmptool-stg.cdlib.org/cgi-bin/PrintShibInfo.pl) to test the SSO handshake. Select your institution from the dropdown list and click the "Continue" button. This should bring you to your institution's login page if things were properly configured within the DMPTool. Once you login, you will be redirected back to a validation page that will display the attributes mentioned above.  If all has been properly configured within your identity provider, a Success message will be displayed.

If your insitution does not appear in the dropdown list, then you may not be a member of InCommon or eduGAIN. Contact us for more information.
