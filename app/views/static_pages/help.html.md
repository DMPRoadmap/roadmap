<h1><%= _('Quick start guide') %></h1>
<hr>

<h3><%= _('Contents') %></h3>

[<%= _('Who can use the tool?') %>](#who-can-use-the-tool)   
[<%= _('How do I log in or create an account?') %>](#how-do-i-log-in-or-create-an-account)   
[<%= _('Overview of My dashboard') %>](#overview-of-my-dashboard)   
[<%= _('How do I create a data management plan?') %>](#how-do-i-create-a-data-management-plan)   
[<%= _('How do I get help from someone at my institution?') %>](#how-do-i-get-help-from-someone-at-my-institution)   
<hr>

<h3 id="who-can-use-the-tool"><%= _('Who can use the tool?') %></h3>

<%= raw _('DMPTool is free for anyone to create data management plans. As a user, you can:<ul><li>Create your own plans.</li><li>Co-author a plan with collaborators.</li><li> If you are a researcher from one of the <a href="%{participating_url}">participating institutions</a>, you can log in using your institutional credentials. You may then be presented with institution-specific guidance and have the option to get feedback from local data experts.</li></ul>') % { participating_url: public_orgs_path } %>
<hr>

<h3 id="how-do-i-log-in-or-create-an-account"><%= _('How do I log in or create an account?') %></h3>

<%= _('Click on Sign in at the top-right of the home page. You can also click the white “Get started” button.') %>

<%= raw _('If your institution/organization is affiliated with DMPTool:<ul><li>Click the first button to sign in with “Your institution.”</li><li>Select your institution from the list and click “Go.”</li><li>Researchers at some institutions will be presented with the institution\\'s authentication page. Log in as you usually do for your institution\\'s web services.</li><li>If your institution has not configured single sign-on, you need to create an account with DMPTool (last bullet).</li><li>If you have already created an account with DMPTool, click the second button to sign in with the email address and password you previously chose. Once logged in, use Edit profile in the top-right menu bar to manage your password and other information.</li><li>If your institution is not affiliated with DMPTool (or has not configured single sign-on), you need to create an account with an email address and password.</li></ul>') %>

<img src="https://github.com/CDLUC3/dmptool/blob/master/docs/quickstartguide/UCR-signin-ai.png?raw=true" alt="UCR sign in" style="width: 40%; margin-left: 45px;" />

<hr>
  
<h3 id="overview-of-my-dashboard"><%= _('Overview of My dashboard') %></h3>

<%= _('When you log in you will be directed to “My dashboard.” From here you can create, edit, share, download, copy, or remove any of your plans. You will also see plans that have been shared with you by others.') %>

<%= raw _('If others at your institution/organization have chose to share their plans internally, you will see a second table of organizational plans. This allows you to download a PDF and view their plans as samples or to discover new research data. Additional samples are available in the list of <a href="%{public_plans_url}">public plans</a>.') % { public_plans_url: public_plans_path } %>

<img src="https://github.com/CDLUC3/dmptool/blob/master/docs/quickstartguide/my-dashboard-ai.png?raw=true" alt="My dashboard" style="width: 80%; margin-left: 45px;" />
<hr> 

<h3 id="how-do-i-create-a-data-management-plan"><%= _('How do I create a data management plan?') %></h3>
<br>
<h4><%= _('Create a plan') %></h4>

<%= _('To create a plan, click the “Create plan” button on My dashboard or the top menu. This will take you to a wizard that helps you select the appropriate template:') %>

<img src="https://github.com/CDLUC3/dmptool/blob/master/docs/quickstartguide/create-plan-ai.png?raw=true" alt="Create plan" style="width: 70%; margin-left: 45px;" />

<%= raw _('<ol type="1"><li>Enter a title for your research project. If applying for funding, use the project title as it appears in the proposal.</li><li>Select the primary research organization. If you are associated with a participating institution/organization, this field will be pre-populated. You have the option to clear the field and select another organization from the list. Based on your selection, you will be presented with institution-specific templates and guidance. You can also check the box that “No organization is associated with this plan.”</li><li>Select the primary funding organization. If you are required to include a data management plan as part of a grant proposal, select your funder from the list. You may be presented with a secondary dropdown menu if your funder has different requirements for specific programs (e.g., NSF, DOE). See the complete list of <a href="%{public_templates_url}">funder requirements</a> supported by DMPTool. If your funder is not in the list or you are not applying for a grant, check the box for “No funder associated with this plan;” this selection will provide you with a generic template.</li></ol>') % { public_templates_url: public_templates_path } %>

<%= _('If you are just testing the tool or taking a course on data management, check the box “Mock project for test, practice, or educational purposes.” Marking your plans as a test will be reflected in usage statistics and prevent public or organizational sharing; this allows other users to find real sample plans more easily.') %>

<%= _('Once you have made your selections, click “Create plan.”') %>

<%= _('You can also make a copy of an existing plan (from the Actions menu next to the plan on My dashboard) and update it for a new research project and/or grant proposal.') %>
<br>

<br> 
<h4><%= _('Write your plan') %></h4>

<%= raw _('The tabbed interface allows you to navigate through different functions when editing your plan.<ul><li>“Project details” includes basic administrative details. The right-hand side of the page is where you can select up to 6 organizations to view additional guidance as you write your plan. The more information you provide here, the more useful your plan will be to you and others in the future (e.g., for data reuse and proper attribution). On the Edit profile page you can create or connect your ORCID iD; this is required by some funders and a growing list of publishers (Learn more at <a href="%{orcid_url}\">orcid.org</a>).</li><li>“Plan overview” provides an overview of the questions that you will be asked. The following tab(s) present the questions to answer. There may be more than one tab if your funder or institution asks different sets of questions at different stages, e.g., at grant application and post-award. Guidance and comments are displayed in the right-hand panel beside each question. If you need more guidance or find there is too much, you can make adjustments on the “Project details” tab.</li><li>“Share” allows you to invite others to contribute to or comment on your plan. This is also where you can set your plan visibility (details below).</li><li>“Download” allows you to download your plan in various formats. You can adjust the formatting (font type, size, and margins) for PDF files, which may be helpful if working to page limits (e.g., NSF data management plans are limited to 2 pages).</li></ul>') % {orcid_url: 'https://orcid.org' } %>
<br>

<h4><%= _('Share plans') %></h4>

<%= _('Input the email address(es) of any collaborators you would like to invite to read or edit your plan. Set their permissions via the radio buttons and click to "Add collaborator." Adjust permissions or remove collaborators at any time via the drop-down options in the table.') %>

<%= raw _('The "Share" tab is also where you can set your plan visibility.<ul><li>Private: restricted to you and your collaborators.</li><li>Organizational: anyone at your organization can view your plan.</li><li>Public: anyone can view your plan in the <a href="%{public_plans_url}">public plans</a> list.</li></ul>') % { public_plans_url: public_plans_path } %>

<%= _('By default all new and test plans will be set to Private visibility. Public and Organizational visibility are intended for finished plans. You must answer at least 50% of the questions to enable these options.') %>

<img src="https://github.com/CDLUC3/dmptool/blob/master/docs/quickstartguide/share-tab-ai.png?raw=true" alt="Share tab" style="width: 80%; margin-left: 45px;" />
<hr> 

<h3 id="how-do-i-get-help-from-someone-at-my-institution"><%= _('How do I get help from someone at my institution?') %></h3>

<%= _('After logging in, you will find an email address and URL for help at the top of the page.') %>
 
<%= _('There may also be an option to request feedback on your plan (on the “Share” tab). This is available when research support staff at your institution have enabled the service. Click to “Request feedback” and your local administrators will be alerted to your request. Their comments will be visible in the “Comments” field adjacent to each question. You will receive an email notification when an administrator provides feedback.') %>

