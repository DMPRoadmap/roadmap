<%= _('FAQ') %>
===============

**<%= _('About the DMPTool') %>**  
[<%= _('What is a data management plan (DMP)?') %>](#q-what-is-a-data-management-plan-dmp)  
[<%= _('What can I do with the DMPTool?') %>](#q-what-can-i-do-with-the-dmptool)  
[<%= _('How much does it cost to use the DMPTool?') %>](#q-how-much-does-it-cost-to-use-the-dmptool)  
[<%= _('Who can use the DMPTool?') %>](#q-who-can-use-the-dmptool)  
[<%= _('How can my institution participate in the DMPTool?') %>](#q-how-can-my-institution-participate-in-the-dmptool)  
[<%= _('What are the benefits of participating in the DMPTool?') %>](#q-what-are-the-benefits-of-participating-in-the-dmptool)  
[<%= _('Have funders endorsed the DMPTool?') %>](#q-have-funders-endorsed-the-dmptool)  
[<%= _('Who owns the data management plans created with the DMPTool?') %>](#q-who-owns-the-data-management-plans-created-with-the-dmptool)  
[<%= _('Why am I getting email notifications from the DMPTool?') %>](#q-why-am-i-getting-email-notifications-from-the-dmptool)  

**<%= _('For Researchers') %>**   
[<%= _("I'm in a hurry! Is there a quick start guide for creating a data management plan?") %>](#q-im-in-a-hurry-is-there-a-quick-start-guide-for-creating-a-data-management-plan)   
[<%= _('Where can I read more about funder requirements for data management plans?') %>](#q-where-can-i-read-more-about-funder-requirements-for-data-management-plans)      
[<%= _('Are there examples of data management plans?') %>](#q-are-there-examples-of-data-management-plans)     
[<%= _('What\\'s the difference between “sample” and “public” data management plans?') %>](#q-whats-the-difference-between-sample-and-public-data-management-plans)     
[<%= _('What are the visibility options for my data management plan?') %>](#q-what-are-the-visibility-options-for-my-data-management-plan)   
[<%= _('I created a test plan. How can I delete it (or hide it)?') %>](#q-i-created-a-test-plan-how-can-i-delete-it-or-hide-it)      
[<%= _('How long will you save my plans?') %>](#q-how-long-will-you-save-my-plans)   
[<%= _('What if I move to a new institution?') %>](#q-what-if-i-move-to-a-new-institution)   
[<%= _('Who can help me at my institution?') %>](#q-who-can-help-me-at-my-institution)   
[<%= _('I have a collaborator. How can we work on the same plan?') %>](#q-i-have-a-collaborator-how-can-we-work-on-the-same-plan)    
[<%= _('What happens when I “request feedback” on a plan?') %>](#q-what-happens-when-i-request-feedback-on-a-plan)   

**<%= _('For Administrators') %>**  
[<%= _('Where can I find help customizing the DMPTool for my institution/organization?') %>](#q-where-can-i-find-help-customizing-the-dmptool-for-my-institutionorganization)    
[<%= _('Can I see customized templates and guidance created by administrators at other organizations?') %>](#q-can-i-see-customized-templates-and-guidance-created-by-administrators-at-other-organizations)   
[<%= _('I created a test template. How can I delete it?') %>](#q-i-created-a-test-template-how-can-i-delete-it)     
[<%= _('How do I create guidance? And what are themes?') %>](#q-how-do-i-create-guidance-and-what-are-themes)  


<%= raw _("Can't find what you’re looking for? <a href=\"%{contact_us_url}\" >Contact us</a>") % { contact_us_url: contact_us_path } %>

<hr>
<h3><%= _('About the DMPTool') %></h3>

<h5 id="q-what-is-a-data-management-plan-dmp"><%= _('Q: What is a data management plan (DMP)?') %></h5>
<%= _("A: A data management plan is a formal document that outlines what you will do with your data during and after a research project. Most researchers collect data with some form of plan in mind, but it's often inadequately documented and incompletely thought out. Many data management issues can be handled easily or avoided entirely by planning ahead. With the right process and framework it doesn't take too long and can pay off enormously in the long run.") %>


<%= raw _('Read our <a href="%{general_guidance_url}">Data Management General Guidance</a> for more information about data management plans.') % { general_guidance_url: general_guidance_path } %>
<hr>

<h5 id="q-what-can-i-do-with-the-dmptool"><%= _('Q: What can I do with the DMPTool?') %></h5>  
<%= raw _('A: The DMPTool helps researchers create data management plans (DMPs). It provides guidance from specific funders who require DMPs, but the tool can be used by anyone interested in developing generic DMPs to help facilitate their research. The tool also offers resources and services available at <a href="%{participating_url}">participating institutions</a> to help fulfill data management requirements.') % { participating_url: public_orgs_path } %>


<%= raw _('Use our <a href="%{help_url}">Quick Start Guide</a> to begin creating a plan.') % { help_url: help_path } %>
<hr>

<h5 id="q-how-much-does-it-cost-to-use-the-dmptool"><%= _('Q: How much does it cost to use the DMPTool?') %></h5>  
<%= _('A: The DMPTool is FREE. Anyone can create data management plans using the DMPTool.') %>

<%=raw  _('A login is required to access the DMPTool. If you are a researcher from a <a href="%{participating_url}">participating institutions</a>, you can log in as a user from your institution. If your institution does not participate, you can create your own account.') % { participating_url: public_orgs_path } %>


<%= raw _('Use our <a href="%{help_url}">Quick Start Guide</a> to begin creating a plan.') % { help_url: help_path} %>
<hr>

<h5 id="q-who-can-use-the-dmptool"><%= _('Q: Who can use the DMPTool?') %></h5>
<%= raw _('A: Anyone can create data management plans. If you are a researcher from one of the <a href="%{participating_url}">participating institutions</a>, you can log in as a user from your institution and you will be presented with local guidance to help you complete your plan.') % {participating_url: public_orgs_path } %>

<%= _('If your institution does not participate, you can create your own account.') %>

<%= raw _('Use our <a href=\"%{help_url}\">Quick Start Guide</a> to begin creating a plan.') % { help_url: help_path } %>
<hr>

<h5 id="q-how-can-my-institution-participate-in-the-dmptool"><%= _('Q: How can my institution participate in the DMPTool?') %></h5>
<%= raw _('A: First, check this <a href="%{participating_url}">participating institutions</a> to make sure your institution is not already participating. Learn more about becoming a <a href="%{about_url}">participating institution</a>.') % { participating_url: public_orgs_path, about_url: about_us_path } %>

<%= raw _('If you are a researcher or potential user, we suggest you talk to a librarian at your institution. If you are an administrator (librarian or otherwise) and interested in joining, please <a href="%{contact_url}">contact us</a>.') % { contact_url: contact_us_path } %>
<hr>

<h5 id="q-what-are-the-benefits-of-participating-in-the-dmptool"><%= _('Q: What are the benefits of participating in the DMPTool?') %></h5>
<%= _('A: Participating institutions can incorporate information about their resources and services to aid researchers with data management. Participating institutions can also provide customized help and suggest answers to the questions asked by funding agencies. Users from particpating institutions that have configured the tool with Shibboleth can log in with their own institutional accounts.') %>

<%= raw _('For more information, see <a href="%{about_url}">About participating</a>.') % { about_url: about_us_path } %>
<hr>

<h5 id="q-have-funders-endorsed-the-dmptool"><%= _('Q: Have funders endorsed the DMPTool?') %></h5>
<%= _('A: No funders have endorsed the use of the DMPTool, although some provide links to the tool or resources within the tool in their public access plans (e.g., NEH, DOT).') %>

<%= _('Despite the lack of formal endorsements, the DMPTool templates incorporate specific data management planning requirements from a range of funders including foundations and government agencies. We are in close contact with some funders as we create templates and for all funders we monitor public notices and websites for changes.') %>
<hr>

<h5 id="q-who-owns-the-data-management-plans-created-with-the-dmptool"><%= _('Q: Who owns the data management plans created with the DMPTool?') %></h5>  
<%= raw _('A: Data management plans are the intellectual property of their creators. The California Digital Library makes no claim of copyright or ownership to the data management plans created using the DMPTool. You can, however, choose to share your plan publicly and it will appear in our library of <a href="%{public_plans_url}">public plans</a> on the DMPTool website. This will benefit other DMPTool users and promote open research.') % { public_plans_url: public_plans_path } %>

<%= raw _('See the <a href="%{help_url}">Quick Start Guide</a> for more information on setting your plan\\'s visibility.') % { help_url: help_path } %>
<hr>

<h5 id="q-why-am-i-getting-email-notifications-from-the-dmptool"><%= _('Q: Why am I getting email notifications from the DMPTool?') %></h5>
<%= _('A: There are multiple actions that generate automatic email notifications from the DMPTool. Users can turn these notifications on/off on the profile page. Navigate to "Edit profile" by clicking your name in the upper right dropdown menu, then select the "Notification preferences" tab, check/uncheck the appropriate boxes, and click the button to save your changes.') %>
<hr>

<h3><%= _('For Researchers') %><h3>

<h5 id="q-im-in-a-hurry-is-there-a-quick-start-guide-for-creating-a-data-management-plan"><%= _('Q: I\\'m in a hurry! Is there a quick start guide for creating a data management plan?') %></h5>
<%= raw _('Yes! The <a href="%{help_url}">Quick Start Guide</a> is available as a website or a PDF you can download.') % { help_url: help_path } %>
<hr>

<h5 id="q-where-can-i-read-more-about-funder-requirements-for-data-management-plans"><%= _('Q: Where can I read more about funder requirements for data management plans?') %></h5>
<%= raw _('A: The <a href="%{public_templates_url}">Funder Requirements page</a> provides direct links to funder guidelines, as well as sample plans if provided. You do not have to be logged into the DMPTool to access this page.') % { public_templates_url: public_templates_path } %>
<hr>

<h5 id="q-are-there-examples-of-data-management-plans"><%= _('Q: Are there examples of data management plans?') %></h5>
<%= raw _('A: The DMPTool hosts a collection of <a href="%{public_plans_url}">public plans</a>.
The collection contains actual plans created by DMPTool users who have opted to share their plans publicly. Please note that these plans have not been vetted for quality. Some funders provide sample plans on their websites; links to these plans are available on the <a href=\"%{public_templates_url}\">Funder Requirements page</a>.') % { public_plans_url: public_plans_path, public_templates_url: public_templates_path } %>
<hr>

<h5 id="q-whats-the-difference-between-sample-and-public-data-management-plans"><%= _('Q: What\\'s the difference between “sample” and “public” data management plans?') %></h5>
<%= raw _('A: The sample plans on the <a href="%{public_templates_url}">Funder Requirements page</a> are created by funders and offered as guidance on their websites. The <a href="%{public_plans_url}">Public Plans</a> are actual plans created by users of the DMPTool (please note that these have not been vetted for quality). Both provide helpful examples for researchers creating their own data management plans.') % { public_plans_url: public_plans_path, public_templates_url: public_templates_path } %>
<hr>

<h5 id="q-what-are-the-visibility-options-for-my-data-management-plan"><%= _('Q: What are the visibility options for my data management plan?') %></h5>
<%= raw _('A: There are three visibility options for each plan you create:<ol><li>Private. Your plan will only be visible to you and any specified plan collaborators. Basic plan details (from the project details page, but not the plan content) will be available to administrators at your institution.</li><li>Organization. If your institution/organization participates in the DMPTool, this setting allows administrators and users from your institution to see your plan.</li><li>Public. Your plan will be available on the <a href="%{public_plans_url}">Public Plans</a> page of the DMPTool website. Choose this option to allow others to see your plan without restrictions (under a CC-Zero license).</li></ol>') % { public_plans_url: public_plans_path } %>
<hr>

<h5 id="q-i-created-a-test-plan-how-can-i-delete-it-or-hide-it"><%= _('Q: I created a test plan. How can I delete it (or hide it)?') %></h5>
<%= raw _('A:<ol><li>Log into the DMPTool.</li><li>On "My Dashboard" tick the box in the "Test" column next to the title of the appropriate plan. This action will remove the plan from the public list if the visibility was set to public (it will become test/private).</li><li>To delete the plan: select "Remove" from the Actions menu next to the title of the appropriate plan. You will be asked to confirm this action.</li></ol>') %>
<hr>

<h5 id="q-how-long-will-you-save-my-plans"><%= _('Q: How long will you save my plans?') %></h5>
<%= _('A: We do not plan to delete any plans created with the DMPTool. As a plan owner, however, you can delete plans by going to “My Dashboard” and selecting “Remove” from the Actions menu next to the plan name.') %>
<hr>

<h5 id="q-what-if-i-move-to-a-new-institution"><%= _('Q: What if I move to a new institution?') %></h5>
<%= _('A: Since the DMPTool account is tied to an email address, the information will not automatically follow a user if they change institutions. However, we can connect users to their plans from previous institutions if they contact us. Users who change institutions and assume new institutional credentials must create a new DMPTool account.') %>
<hr>

<h5 id="q-who-can-help-me-at-my-institution"><%= _('Q: Who can help me at my institution?') %></h5>
<%= raw _('A: If your institution <a href="%{participating_url}">participates in the DMPTool</a>, you can log into the tool and click on the “Contact” link in the top banner. Your email will be sent directly to an expert on your campus who can follow up with you. If your institution does not participate in the DMPTool, check with a librarian to see if someone on campus can help.') % { participating_url: public_orgs_path } %>
<hr>

<h5 id="q-i-have-a-collaborator-how-can-we-work-on-the-same-plan"><%= _('Q: I have a collaborator. How can we work on the same plan?') %></h5>
<%= _('A: First you must create an account in the DMPTool and begin creating a plan. Then you can add your collaborator(s) to your plan as co-owner(s), or grant editor or read only permissions. You can do this on the “Share” tab for your plan. Enter an email address in the field to "Invite collaborators,” select the desired level of permissions, and click "Submit" to send an email invitation.') %>
<br>
<%= raw _('For more information, see the <a href="%{help_url}">Quick Start Guide</a>.') % { help_url: help_path } %>
<hr>

<h5 id="q-what-happens-when-i-request-feedback-on-a-plan"><%= _('Q: What happens when I "request feedback" on a plan?') %></h5>

<%= _('A: The request feedback functionality of the DMPTool is an optional feature that institutions may configure to help researchers create data management plans. Submitting a plan for feedback is within-institution only. If this feature is enabled, a button to "Request feedback" will be displayed on the "Share" tab when writing a plan. If a user clicks the "Request feedback" button, the DMPTool will send an email to the plan owner and the institutional administrator contact. The institutional administrator will be granted read only permissions and be able to provide comments on the plan within the tool.') %>
<br>
<%= raw _('Administrators: if you are interested in enabling this functionality for users at your institution, see the "Request feedback" section of the <a href="%{admin_help_url}">help for administrators</a> wiki.') % { admin_help_url: 'https://github.com/cdluc3/dmptool/wiki/Help-for-Administrators' } %>
<hr>

<h3><%= _('For Administrators') %></h3>

<h5 id="q-where-can-i-find-help-customizing-the-dmptool-for-my-institutionorganization"><%= _('Q: Where can I find help customizing the DMPTool for my institution/organization?') %></h5>
<%= raw _('A: There is an extensive list of <a href="%{admin_help_url}">help topics for administrators</a> customizing the DMPTool located on GitHub. You will find detailed instructions for:<ol><li>Setting up the DMPTool<ul><li>Enabling Shibboleth</li><li>Granting administrator privileges</li><li>Customizing your organizational profile</li><li>Providing feedback on plans</li><li>Usage information</li></ul><li>Quick overview of terms</li><li>Creating guidance</li><li>Customizing funder templates</li><li>Creating templates</li></ol>') % { admin_help_url: 'https://github.com/cdluc3/dmptool/wiki/Help-for-Administrators' } %>

<hr>

<h5 id="q-can-i-see-customized-templates-and-guidance-created-by-administrators-at-other-organizations"><%= _('Q: Can I see customized templates and guidance created by administrators at other organizations?') %></h5>
<%= _('A: Yes! To view guidance created by others, create a new plan in the tool. On the "Project details" tab you will see "Plan guidance configuration" on the right. Click to "See the full list" and you can select up to 6 different organizations at a time. You will see the selected guidance when you navigate to the "Write plan" tab.') %>
<br>
<%= _('To view templates created by others (if available), create a new plan in the tool and choose any organization for the second step: "Select the primary research organization." For the third create plan step, if you tick the box  "No funder associated with this plan" you will be presented with any available organizational templates. If the field remains gray and no templates with organizational names appear, then the selected organization has not created any of their own templates and you will be presented with the default DMPTool template after clicking the button to "Create plan."') %>
<hr>

<h5 id="q-i-created-a-test-template-how-can-i-delete-it"><%= _('Q: I created a test template. How can I delete it?') %></h5>
<%= raw _('A: DMPTool administrators can delete templates. This option is only available if no plans have been created using that template. If you cannot or do not want to delete a template, you can "Unpublish" the template so that it will not appear to users. See our <a href="%{admin_help_url}">help documentation</a> on how to do this.') % { admin_help_url: 'https://github.com/cdluc3/dmptool/wiki/Help-for-Administrators' } %>

<hr>

<h5 id="q-how-do-i-create-guidance-and-what-are-themes"><%= _('Q: How do I create guidance? And what are themes?') %></h5>
<%= raw _('A:  The <a href="%{admin_help_url}">help menu for administrators</a> contains detailed instructions for creating themed guidance. The basic steps include:<ol><li>Creating a guidance group (you will already have a default guidance group for your organization; it is optional to create additional groups or subgroups, for example, for a specific department)</li><li>Creating guidance by entering text, assigning one or more themes, and attaching it to a guidance group</li><li>Publishing the guidance</li></ol>') % { admin_help_url: 'https://github.com/cdluc3/dmptool/wiki/Help-for-Administrators' } %>
  
<%= _('There are 14 themes that represent the most common topics addressed in data management plans (e.g., Data format, Metadata). Themes work like tags to associate questions and guidance. Questions within a template can be tagged with one or more themes, and guidance can be written by theme to allow organizations to apply their advice over all templates at once. This also alleviates the need to update guidance each time a new template is released.') %>
<hr>

<%= raw _("Can't find the answer you’re looking for? <a href=\"%{contact_url}\">Contact us</a>") % { contact_url: contact_us_path } %>
