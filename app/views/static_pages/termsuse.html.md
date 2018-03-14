<h1><%= _('Terms of use & Privacy policy')%></h1>

<hr>

<%= raw _('The <a href="%{cdlib_url}">California Digital Library (CDL)</a> is supported by the University of California (UC). Our primary constituency is the UC research community; in addition, we provide services to the United States and international higher education sector.') % { cdlib_url: 'http://www.cdlib.org' } %>
<br>
<h4><%= _('DMPTool') %></h4>

<%= raw _("DMPTool ('the tool', 'the system') is a tool developed by the CDL and the <a href=\"%{dcc_url}\">Digital Curation Centre (DCC)</a> as a shared resource for the research community. It is hosted at CDL by the University of California Curation Center (UC3).") % { dcc_url: 'http://www.dcc.ac.uk/' } %>
<br>

<h4><%= _('Your personal details') %></h4>

<%= _('In order to help identify and administer your account with the DMPTool, we need to store your email address. We may also use it to contact you to obtain feedback on your use of the tool, or to inform you of the latest developments or releases. The information may be transferred between the CDL and DCC partner organizations but only for legitimate CDL purposes. We will not sell, rent, or trade any personal information you provide to us.') %>
<br>

<h4><%= _('Privacy policy') %></h4>

<%= raw _('The information you enter into this system can be seen by you, people you have chosen to share access with, and—solely for the purposes of maintaining the service—system administrators at the CDL. We compile anonymized, automated, and aggregated information from plans, but we will not directly access, make use of, or share your content with anyone beyond CDL and your home institution without your permission. Authorized users at your home institution may access your plans for specific purposes—for example, to track compliance with funder/institutional requirements, to calculate storage requirements, or to assess demand for data management services across disciplines. For a detailed description of what information (other than the plans) we collect from visitors to this website and how it is used and managed, please see the CDL Privacy Policy and Baseline Supporting Practices listed at <a href="%{policies_url}">%{policies_url}</a>') % {policies_url: 'http://www.cdlib.org/about/policies.html' } %>
<br>

<h4><%= _('Freedom of Information') %></h4>

<%= _('The CDL holds your plans on your behalf, but they are your property and responsibility. Any FOIA applicants will be referred back to your home institution.') %>
<br>

<h4><%= _('Passwords') %></h4>

<%= _('Your password is stored in encrypted form and cannot be retrieved. If forgotten it has to be reset.') %>
<br>

<h4><%= _('Google Analytics opt-out') %></h4>

<%= raw _('As noted in the CDL privacy policy, this website uses Google Analytics to capture and analyze usage statistics. You may choose to opt-out of having your website activity tracked by Google Analytics. To do so, visit the <a href="%{opt_out_url}">Google Analytics opt-out page</a> and install the add-on for your browser.') % { opt_out_url: 'https://tools.google.com/dlpage/gaoptout' }%>
<br>

<h4><%= _('Third party APIs') %></h4>

<%= _('Certain features on this website utilize third party services and APIs such as InCommon/Shibboleth or third party hosting of common JavaScript libraries or web fonts. Information used by an external service is governed by the privacy policy of that service. CDL does not control how information may be used by these services.') %>
<br>

<h4><%= _('Revisions') %></h4>

<%= _('This statement was last revised on October 5, 2017 and may be revised at any time. Use of the tool indicates that you understand and agree to these terms and conditions.') %>
