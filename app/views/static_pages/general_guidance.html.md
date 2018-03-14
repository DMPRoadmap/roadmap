<h1><%= _('Data management general guidance') %></h1>
<hr>

<h3><%= _('Table of Contents') %></h3>

[<%= _('Introduction') %>](#introduction)    
[<%= _('Types of Data') %>](#types-of-data)      
[<%= _('File Formats') %>](#file-formats)    
[<%= _('Organizing Files') %>](#organizing-files)    
[<%= _('Metadata: Data Documentation') %>](#metadata-data-documentation)     
[<%= _('Persistent Identifiers') %>](#persistent-identifiers)   
[<%= _('Security and Storage') %>](#security-and-storage)   
[<%= _('Sharing and Archiving') %>](#sharing-and-archiving)   
[<%= _('Citing Data') %>](#citing-data)   
[<%= _('Copyright and Privacy') %>](#copyright-and-privacy)   

<hr>

<h3 id="introduction"><%= _('Introduction') %></h3>  
<br>
<h4><%= _('What is a data management plan?') %></h4>
<%= _('A data management plan is a formal document that outlines what you will do with your data during and after a research project. Most researchers collect data with some form of plan in mind, but it\\'s often inadequately documented and incompletely thought out. Many data management issues can be handled easily or avoided entirely by planning ahead. With the right process and framework it doesn\\'t take too long and can pay off enormously in the long run.') %>

<h4><%= _('Who requires a plan?') %></h4>
<%= raw _('In February of 2013, the White House Office of Science and Technology Policy (OSTP) issued a %{memorandum_url} directing Federal agencies that provide significant research funding to develop a plan to expand public access to research. Among other requriments, the plans must:<ul><li>"Ensure that all extramural researchers receiving Federal grants and contracts for scientific research and intramural researchers develop data management plans, as appropriate, describing how they will provide for long-term preservation of, and access to, scientific data in digital formats resulting from federally funded research, or explaining why long-term preservation and access cannot be justified"</li></ul>') % { memorandum_url: '<a href="https://obamawhitehouse.archives.gov/blog/2013/02/22/expanding-public-access-results-federally-funded-research">memorandum</a>' } %>
   
<%= _('The National Science Foundation (NSF) requires a 2-page plan as part of the funding proposal process. Most or all US Federally funded grants will eventually require some form of data management plan.') %>

<h4><%= _('We can help') %></h4>
<%= _('We have been working with internal and external partners to make data management plan development less complicated. By getting to know your research and data, we can match your specific needs with data management best practices in your field to develop a data management plan that works for you. If you do this work at the beginning of your research process, you will have a far easier time following through and complying with funding agency and publisher requirements.') %>

<%= _('We recommend that those applying for funding from US Federal agencies, such as the NSF, use the DMPTool. The DMPTool provides guidance for many of the NSF Directorate and Division requirements, along with links to additional resources, services, and help.') %>

<hr>

<h3 id="types-of-data"><%= _('Types of Data') %></h3>
<br>
<%= _('Research projects generate and collect countless varieties of data. To forumulate a data management plan, it\\'s useful to categorize your data in four ways: by source, format, stability, and volume.') %>

<h4><%= _('What\\'s the source of the data?') %></h4>
<%= _('Although data comes from many different sources, they can be grouped into four main categories. The category(ies) your data comes from will affect the choices that you make throughout your data management plan.') %>

<%= raw _('<strong>Observational</strong><ul><li>Captured in real-time, typically outside the lab</li><li>Usually irreplaceable and therefore the most important to safeguard</li><li>Examples: Sensor readings, telemetry, survey results, images</li></ul>') %>

<%= raw _('<strong>Experimental</strong><ul><li>Typically generated in the lab or under controlled conditions</li><li>Often reproducible, but can be expensive or time-consuming</li><li>Examples: gene sequences, chromatograms, magnetic field readings</li></ul>') %>

<%= raw _('<strong>Simulation</strong><ul><li>Machine generated from test models</li><li>Likely to be reproducible if the model and inputs are preserved</li><li>Examples: climate models, economic models</li></ul>') %>

<%= raw _('<strong>Derived / Compiled</strong><ul><li>Generated from existing datasets</li><li>Reproducible, but can be very expensive and time-consuming</li><li>Examples: text and data mining, compiled database, 3D models</li></ul>') %>

<h4><%= _('What\\'s the form of the data?') %></h4>
<%= raw _('Data can come in many forms, including:<ul><li><strong>Text</strong>: field or laboratory notes, survey responses</li><li><strong>Numeric</strong>: tables, counts, measurements</li><li><strong>Audiovisual</strong>: images, sound recordings, video</li><li><strong>Models, computer code</strong></li><li><strong>Discipline-specific</strong>: FITS in astronomy, CIF in chemistry</li><li><strong>Instrument-specific</strong>: equipment outputs</li></ul>') %>

<h4><%= _('How stable is the data?') %></h4>
<%= raw _('Data can also be fixed or changing over the course of the project (and perhaps beyond the project\\'s end). Do the data ever change? Do they grow? Is previously recorded data subject to correction? Will you need to keep track of data versions? With respect to time, the common categories of dataset are:<ul><li><strong>Fixed datasets</strong>: never change after being collected or generated</li><li><strong>Growing datasets</strong>: new data may be added, but the old data is never changed or deleted</li><li><strong>Revisable datasets</strong>: new data may be added, and old data may be changed or deleted</li></ul>') %>

<%= _('The answer to this question affects how you organize the data as well as the level of versioning you will need to undertake. Keeping track of rapidly changing datasets can be a challenge so it is imperative that you begin with a plan to carry you through the entire data management process.') %>

<h4><%= _('How much data will the project produce?') %></h4>
<%= _('For instance, image data typically requires a lot of storage space, so you\\'ll want to decide whether to retain all your images (and, if not, how you will decide which to discard) and where such large data can be housed. Be sure to know your archiving organization\\'s capacity for storage and backups.') %>

<%= raw _('To avoid being under-prepared, estimate the growth rate of your data. Some questions to consider are:<ul><li>Are you manually collecting and recording data?</li><li>Are you using observational instruments and computers to collect data?</li><li>Is your data collection highly iterative?</li><li>How much data will you accumluate every month or every 90 days?</li><li>How much data do you anticipate collecting and generating by the end of your project?</li></ul>') %>

<hr>

<h3 id="file-formats"><%= _('File Formats') %></h3>   
<br>
<%= _('The file format you choose for your data is a primary factor in someone else\\'s ability to access it in the future. Think carefully about what file format will be best to manage, share, and preserve your data. Technology continually changes and all contemporary hardware and software should be expected to become obsolete. Consider how your data will be read if the software used to produce it becomes unavailable. Although any file format you choose today may become unreadable in the future, some formats are more likely to be readable than others.') %>

<h4><%= _('Formats likely to be accessible in the future are:') %> </h4>  

- <%= _('Non-proprietary') %>
- <%= _('Open, with documented standards') %>
- <%= _('In common usage by the research community') %>
- <%= _('Using standard character encodings (i.e., ASCII, UTF-8)') %>
- <%= _('Uncompressed (space permitting)') %>

<h4><%= _('Examples of preferred format choices:') %></h4>

- <%= _('Image: JPEG, JPG-2000, PNG, TIFF') %>
- <%= _('Text: plain text (TXT), HTML, XML, PDF/A') %>
- <%= _('Audio: AIFF, WAVE') %>
- <%= _('Containers: TAR, GZIP, ZIP') %>
- <%= _('Databases: prefer XML or CSV to native binary formats') %>

<%= _('If you find it necessary or convenient to work with data in a proprietary/discouraged file format, do so, but consider saving your work in a more archival format when you are finished.') %>

<%= raw _('For more information on recommended formats, see the <a href="%{recommended_formats_url}">UK Data Service guidance on recommended formats</a>.') % { recommended_formats_url: 'https://www.ukdataservice.ac.uk/manage-data/format/recommended-formats' } %>

<h4><%= _('Tabular data') %></h4>
<%= raw _('Tabular data warrants special mention because it is so common across disciplines, mostly as Excel spreadsheets. If you do your analysis in Excel, you should use the "Save As..." command to export your work to .csv format when you are done. Your spreadsheets will be easier to understand and to export if you follow best practices when you set them up, such as:<ul><li>Don\\'t put more than one table on a worksheet</li><li>Include a header row with understandable title for each column</li><li>Create charts on new sheets- don\\'t embed them in the worksheet with the data</li></ul>') %>

<h4><%= _('Other risks to accessibility') %></h4>

- <%= _('Encrypted data may be effectively lost if it was encrypted with a key that has been lost (e.g., a forgotten password). For this reason, encrypted data representations are strongly discouraged.') %>
- <%= _('Data that is legally encumbered may also be considered lost. So may data bound by ambiguous or unknown access and archiving rights, because the cost of clarifying the rights situation is often prohibitive. See data rights and licensing for guidance.') %>

<hr>

<h3 id="organizing-files"><%= _('Organizing Files') %></h3>
<br>
<h4><%= _('Basic Directory and File Naming Conventions') %></h4>
<%= raw _('These are rough guidelines to follow to help manage your data files in case you don\\'t already have your own internal conventions. When organizing files, the top-level directory/folder should include:<ul><li>Project title</li><li>Unique identifier (Guidance on persistent external identifiers is available below)</li><li>Date (yyyy or yyyy.mm.dd)</li></ul>') %>

<%= _('The sub-directory structure should have clear, documented naming conventions. Separate files or directories could apply, for example, to each run of an experiment, each version of a dataset, and/or each person in the group.') %>

- <%= _('Reserve the 3-letter file extension for the file format, such as .txt, .pdf, or .csv.') %>
- <%= _('Identify the activity or project in the file name.') %>
- <%= _('Identify separate versions of files and datasets using file or directory naming conventions. It can quickly become difficult to identify the "correct" version of a file.') %>
- <%= _('Record all changes to a file no matter how small. Discard obsolete versions after making backups.') %>

<h4><%= _('File Renaming') %></h4>
<%= _('Tools to help you:') %>

- [Bulk Rename Utility](http://www.bulkrenameutility.co.uk/Main_Intro.php) <%= _('(Windows; free)') %>
- [Renamer](https://renamer.com/) <%= _('(Mac; free trial)') %>
- [PSRenamer](http://www.powersurgepub.com/products/psrenamer/index.html) <%= _('(Linux, Mac, Windows; free)') %>

<hr>

<h3 id="metadata-data-documentation"><%= _('Metadata: Data Documentation') %></h3>
<br>
<h4><%= _('Why document data?') %></h4>   
<%= _('Clear and detailed documentation is essential for data to be understood, interpreted, and used. Data documentation describes the content, formats, and internal relationships of your data in detail and will enable other researchers to find, use, and properly cite your data.') %>

<%= _('Begin to document your data at the very beginning of your research project and continue throughout the project. Doing so will make the process much easier. If you have to construct the documentation at the end of the project, the process will be painful and important details will have been lost or forgotten. Don\\'t wait to document your data!') %>

<h4><%= _('What to document?') %></h4>

<%= raw _('<strong>Research Project Documentation</strong><ul><li>Rationale and context for data collection</li><li>Data collection methods</li><li>Structure and organization of data files</li><li>Data sources used (see citing data)</li><li>Data validation and quality assurance</li><li>Transformations of data from the raw data through analysis</li><li>Information on confidentiality, access and use conditions</li></ul>') %>

<%= raw _('<strong>Dataset documentation</strong><ul><li>Variable names and descriptions</li><li>Explanation of codes and classification schemes used</li><li>Algorithms used to transform data (may include computer code)</li><li>File format and software (including version) used</li></ul>') %>

<h4><%= _('How will you document your data?') %></h4>
<%= raw _('Data documentation is commonly called metadata – "data about data". Researchers can document their data according to various metadata standards. Some metadata standards are designed for the purpose of documenting the contents of files, others for documenting the technical characteristics of files, and yet others for expressing relationships between files within a set of data. If you want to be able to share or publish your data, the <a href="%{datacite_standards_url}">DataCite metadata standard</a> is of particular signficiance.') % { datacite_standards_url: 'https://schema.datacite.org/' } %>

<%= _('Below are some general aspects of your data that you should document, regardless of your discipline. At minimum, store this documentation in a "readme.txt" file, or the equivalent, with the data itself.') %>

**<%= _('General Overview') %>**

- <%= raw _('<strong>Title</strong>: Name of the dataset or research project that produced it') %>
- <%= raw _('<strong>Creator</strong>: Names and addresses of the organizations or people who created the data; preferred format for personal names is surname first (e.g., Smith, Jane)') %>
- <%= raw _('<strong>Identifier</strong>: Unique number used to identify the data, even if it is just an internal project reference number') %>
- <%= raw _('<strong>Date</strong>: Key dates associated with the data, including: project start and end date; release date; time period covered by the data; and other dates associated with the data lifespan, such as maintenance cycle, update schedule; preferred format is yyyy-mm-dd, or yyyy.mm.dd-yyyy.mm.dd for a range') %>
- <%= raw _('<strong>Method</strong>: How the data were generated, listing equipment and software used (including model and version numbers), formulae, algorithms, experimental protocols, and other things one might include in a lab notebook') %>
- <%= raw _('<strong>Processing</strong>: How the data have been altered or processed (e.g., normalized)') %>
- <%= raw _('<strong>Source</strong>: Citations to data derived from other sources, including details of where the source data is held and how it was accessed') %>   
- <%= raw _('<strong>Funder</strong>: Organizations or agencies who funded the research') %>

**<%= _('Content Description') %>**

- <%= raw _('<strong>Subject</strong>: Keywords or phrases describing the subject or content of the data') %>
- <%= raw _('<strong>Place</strong>: All applicable physical locations') %>
- <%= raw _('<strong>Language</strong>: All languages used in the dataset') %>
- <%= raw _('<strong>Variable list</strong>: All variables in the data files, where applicable') %>
- <%= raw _('<strong>Code list</strong>: Explanation of codes or abbreviations used in either the file names or the variables in the data files (e.g. "999 indicates a missing value in the data")') %>

**<%= _('Technical Description') %>**

- <%= raw _('<strong>File inventory</strong>: All files associated with the project, including extensions (e.g. "NWPalaceTR.WRL", "stone.mov")') %>
- <%= raw _('<strong>File formats</strong>: Formats of the data, e.g., FITS, SPSS, HTML, JPEG, etc.') %>
- <%= raw _('<strong>File structure</strong>: Organization of the data file(s) and layout of the variables, where applicable') %>
- <%= raw _('<strong>Version</strong>: Unique date/time stamp and identifier for each version') %>
- <%= raw _('<strong>Checksum</strong>: A digest value computed for each file that can be used to detect changes; if a recomputed digest differs from the stored digest, the file must have changed') %>
- <%= raw _('<strong>Necessary software</strong>: Names of any special-purpose software packages required to create, view, analyze, or otherwise use the data') %>

**<%= _('Access') %>**

- <%= raw _('<strong>Rights</strong>: Any known intellectual property rights, statutory rights, licenses, or restrictions on use of the data') %>
- <%= raw _('<strong>Access information</strong>: Where and how your data can be accessed by other researchers') %>

<hr>

<h3 id="persistent-identifiers"><%= _('Persistent Identifiers') %></h3>
<br>
<%= raw _('If you want to be able to share or cite your dataset, you\\'ll want to assign a public persistent unique identifier to it. There are a variety of public identifier schemes, but common properties of good schemes are that they are:<ul><li>Actionable (you can "click" on them in a web browser)</li><li>Globally unique across the internet</li><li>Persistent for at least the life of your data</li></ul>') %>

<%= _('Here are some identifier schemes:') %>

- <%= raw _('<a href="%{ark_url}">ARK (Archival Resource Key)</a> – a URL with extra features allowing you to ask for descriptive and archival metadata and to recognize certain kinds of relationships between identifiers. ARKs are used by memory organizations such as libraries, archives, and museums. They are resolved at "%{nt2_url}". Resolution depends on HTTP redirection and can be managed through an API or a user interface.') % { ark_url: 'https://confluence.ucop.edu/display/Curation/ARK', nt2_url: 'http://www.nt2.net' } %>
- <%= raw _('<a href="%{doi_url}">DOI (Digital Object Identifier)</a> – an identifier that becomes actionable when embedded in a URL. DOIs are very popular in academic journal publishing. They are resolved at "%{doi_resolver_url}". Resolution depends on HTTP redirection and the Handle identifier protocol, and can be managed through an API or a user interface.') % { doi_url: 'http://www.doi.org/', doi_resolver_url: 'http://dx.doi.org' } %>
- <%= raw _('<a href="%{handle_url}">Handle</a> – an identifier that becomes actionable when embedded in a URL. Handles are resolved at "%{handle_url}". Resolution depends on HTTP redirection and the Handle protocol, and can be managed through an API or a user interface.') % { handle_url: 'http://www.handle.net/' } %>
- <%= raw _('<a href="%{inchi_url}">InChI (IUPAC International Chemical Identifier)</a> – a non-actionable identifier for chemical substances that can be used in printed and electronic data sources, thus enabling easier linking of diverse data compilations.') % { inchi_url: 'https://iupac.org/who-we-are/divisions/division-details/inchi/' } %>
- <%= raw _('<a href="%{lsid_url}">LSID (Life Sciences Identifier)</a> – a kind of URN that identifies a biologically significant resources, including species names, concepts, occurrences, and genes or proteins, or data objects that encode information about them. Like other URNs, it becomes actionable when embedded in a URL.') % { lsid_url: 'https://en.wikipedia.org/wiki/LSID' } %>
- <%= raw _('<a href="%{ncbi_url}">NCBI (National Center for Biotechnology Information) ACCESSION</a> – a non-actionable number in use by NCBI.') % { ncbi_url: 'https://www.ncbi.nlm.nih.gov/Sequin/acc.html' } %>
- <%= raw _('<a href="%{purl_url}">PURL (Persistent Uniform Resource Locator)</a> – a URL that is always redirected through a hostname (often purl.org). Resolution depends on HTTP redirection and can be managed through an API or a user interface.') % { purl_url: 'https://archive.org/services/purl/' } %>
- <%= raw _('<strong>URL (Uniform Resource Locator)</strong> – the typical "address" of web content. It is a kind of URI (Uniform Resource Identifier) that begins with "http://" and consists of a string of characters used to identify or name a resource on the Internet. Such identification enables interaction with representations of the resource over a network, typically the World Wide Web, using the HTTP protocol. Well-managed URL redirection can make URLs as persistent as any identifier. Resolution depends on HTTP redirection and can be managed through an API or a user interface.') %>
- <%= raw _('<strong>URN (Uniform Resource Name)</strong> – an identifier that becomes actionable when embedded in a URL. Resolution depends on HTTP redirection and the DDDS protocol, and can be managed through an API or a user interface. A browser plug-in can save you from typing a hostname in front of it.') %>

<hr>

<h3 id="security-and-storage"><%= _('Security and Storage') %></h3>
<br>
<h4><%= _('Data Security') %></h4>
<%= raw _('Data security is the protection of data from unauthorized access, use, change, disclosure, and destruction. Make sure your data is safe in regards to:<ul><li>Network security<ul><li>Keep confidential data off the Internet</li><li>In extreme cases, put sensitive materials on computers not connected to the internet</li></ul></li><li>Physical security<ul><li>Restrict access to buildings and rooms where computers or media are kept</li><li>Only let trusted individuals troubleshoot computer problems</li></ul></li><li>Computer systems and files<ul><li>Keep virus protection up to date</li><li>Don\\'t send confidential data via e-mail or FTP (or, if you must, use encryption)</li><li>Set passwords on files and computers</li><li>React with skepticism to phone calls and emails that claim to be from your institution\\'s IT department</li></ul></li></ul>') %>

<h4><%= _('Encryption and Compression') %></h4>
<%= raw _('Unencrypted data will be more easily read by you and others in the future, but you may need to encrypt sensitive data.<ul><li>Use mainstream encryption tools (e.g., PGP)</li><li>Don\\'t rely on third-party encryption alone</li><li>Keep passwords and keys on paper (2 copies)</li></ul>') %>

<%= raw _('Uncompressed data will be also be easier to read in the future, but you may need to compress files to conserve disk space.<ul><li>Use a mainstream compression tool (e.g., ZIP, GZIP, TAR)</li><li>Limit compression to the 3rd backup copy</li></ul>') %>

<h4><%= _('Backups and storage') %></h4>
<%= raw _('Making regular backups is an integral part of data management. You can backup data to your personal computer, external hard drives, or departmental or university servers. Software that makes backups for you automatically can simplify this process considerably. The UK Data Archive provides additional <a href="%{storage_guidelines_url}">guidelines on data storage, backup, and security</a>.') % { storage_guidelines_url: 'https://www.ukdataservice.ac.uk/manage-data/store' } %>

**<%= _('Backup Your Data') %>**

- <%= _('Good practice is to have three copies in at least two locations (e.g. original + external/local backup + external/remote backup)') %>
- <%= _('Geographically distribute your local and remote copies to reduce risk of calamity at the same location (power outage, flood, fire, etc.)') %>

**<%= _('Test your backup system') %>**

<%= _('To be sure that your backup system is working, periodically retrieve your data files and confirm that you can read them. You should do this when you initially set up the system and on a regular schedule thereafter.') %>

<h4><%= _('Other data preservation considerations') %></h4>
**<%= _('Who is responsible for managing and controlling the data?') %>**   
<%= _('Who controls the data (e.g., the PI, a student, your lab, your university, your funder)? Before you spend a lot of time figuring out how to store the data, to share it, to name it, etc. you should make sure you have the authority to do so.') %>

**<%= _('For what or whom are the data intended?') %>**   
<%= _('Who is your intended audience for the data? How do you expect they will use the data? The answer to these questions will help inform structuring and distributing the data.') %>

**<%= _('How long should the data be retained?') %>**   
<%= _('Is there any requirement that the data be retained? If so, for how long? 3-5 years, 10-20 years, permanently? Not all data need to be retained, and some data required to be retained need not be retained indefinitely. Have a good understanding of your obligation for the data\\'s retention.') %>

<%= _('Beyond any externally imposed requirments, think about the long-term usefulness of the data. If the data is from an experiment that you anticipate will be repeatable more quickly, inexpensively, and accurately as technology progresses, you may want to store it for a relatively brief period. If the data consists of observations made outside the laborartory that can never be repeated, you may wish to store it indefinitely.') %>

<hr>

<h3 id="sharing-and-archiving"><%= _('Sharing and Archiving') %></h3>
<br>
<h4><%= raw _('Why share your data?') %></h4>
<%= raw _('<ul><li>Required by publishers (e.g., Cell, Nature, Science)</li><li>Required by government funding agencies (e.g., NIH, NSF)</li><li>Allows data to be used to answer new questions</li><li>Makes research more open</li><li>Makes your papers more useful and citable by other researchers</li></ul>') %>

<h4><%= _('Considerations when preparing to share data') %></h4>

- <%= raw _('<strong>File Formats for Long Term Access</strong>: The file format in which you keep your data is a primary factor in one\\'s ability to use your data in the future. Plan for both hardware and software obsolescence. See file formats and organization for details on long-term storage formats.') %>
- <%= raw _('<strong>Don\\'t Forget the Documentation</strong>: Document your research and data so others can interpret the data. Begin to document your data at the very beginning of your research project and continue throughout the project. See data documentation and metadata for details.') %>
- <%= raw _('<strong>Ownership and Privacy</strong>: Make sure that you have considered the implications of sharing data in terms of copyright, IP ownership, and subject confidentiality. See copyright and confidentiality for details.') %>

<h4><%= raw _('Ways to share your data') %></h4>
<%= raw _('<ul><li>Email to individual requesters</li><li>Post online via a project or personal website</li><li>Submit as supplemental material to be hosted on a journal publisher\\'s website</li><li>Deposit in an open repository or archive</li><li>Deposit in an open repository and publish a "data paper" describing the data</li></ul>') %>

<%= raw _('While the first three options above are valid ways to share data, a repository is much better able to provide long-term access. Data deposited in a repository can be supplemented with a "data paper"—a relatively new type of publication that describes a dataset, but does not analyze it or draw any conclusions—published in a journal such as <a href="%{nature_url}">Nature Scientific Data</a> or <a href="%{geoscience_url}">Geoscience Data Journal</a>.') % { nature_url: 'https://www.nature.com/sdata/', geoscience_url: 'http://rmets.onlinelibrary.wiley.com/hub/journal/10.1002/(ISSN)2049-6060/' } %>

<h4><%= _('Finding a data repository') %></h4> 
<%= raw _('You should select a repository or archive for your data based on the long-term security offered and the ease of discovery and access by colleagues in your field. There are two common types of repository to look for:<ul><li><strong>Discipline specific</strong>: accepts data in a particluar field or of a particluar type (e.g., GenBank accepts nucleotide sequence data)</li><li><strong>Institutional</strong>: accepts data of any type produced within the institution that maintains it (e.g., the University of California\\'s <a href="%{dash_url}">Dash</a>)</li></ul>') % { dash_url: 'https://dash.ucop.edu/stash' } %>

<%= raw _('A searchable and browsable list of repositories can be found at these websites:<ul><li><a href="%{re3data_url}">re3data.org</a>: a REgistry of REsearch data REpositories</li><li><a href="%{open_access_url}">Data Repositories</a> in the Open Access Directory: a list of repositories hosted by Simmons College</li><li><a href="%{fairshare_url}">FAIRSharing</a>: a directory of life sciences databases and reporting standards, now expanded to include all disciplines</li></ul>') % { re3data_url: 'https://www.re3data.org/', open_access_url: 'http://oad.simmons.edu/oadwiki/Data_repositories', fairshare_url: 'https://fairsharing.org/' } %>

<hr>

<h3 id="citing-data"><%= _('Citing Data') %></h3>
<br>
<%= raw _('Citing data is important in order to:<ul><li>Give the data producer appropriate credit</li><li>Allow easier access to the data for repurposing or reuse</li><li>Enable readers to verify your results</li></ul>') %>

<h4><%= _('Citation Elements') %></h4>
<%= raw _('A dataset should be cited formally in an article\\'s reference list, not just informally in the text. Many data repositories and publishers provide explicit instructions for citing their contents. If no citation information is provided, you can still construct a citation following generally agreed-upon guidelines from sources such as the <a href="%{force11_citation_url}">Force 11 Joint Declaration of Data Citation Principles</a> and the current <a href="%{datacite_standards_url}">DataCite Metadata Schema</a>.') % {force11_citation_url: 'https://www.force11.org/datacitationprinciples', datacite_standards_url: 'https://schema.datacite.org/' } %>

**<%= _('Core elements') %>**   
<%= raw _('There are 5 core elements usually included in a dataset citation, with additional elements added as appropriate.<ul><li><strong>Creator(s)</strong> – may be individuals or organizations</li><li><strong>Title</strong></li><li><strong>Publication year</strong> when the dataset was released (may be different from the Access date)</li><li><strong>Publisher</strong> – the data center, archive, or repository</li><li><strong>Identifier</strong> – a unique public identifier (e.g., an ARK or DOI)</li></ul>') %>

<%= raw _('Creator names in non-Roman scripts should be transliterated using the <a href="%{romanization_url}">ALA-LC Romanization Tables</a>.') % { romanization_url: 'http://www.loc.gov/catdir/cpso/roman.html' } %>

**<%= _('Common additional elements') %>**   
<%= raw _('Although the core elements are sufficient in the simplest case – citation to the entirety of a static dataset – additional elements may be needed if you wish to cite a dynamic dataset or a subset of a larger dataset.<ul><li><strong>Version</strong> of the dataset analyzed in the citing paper</li><li><strong>Access date</strong> when the data was accessed for analysis in the citing paper</li><li><strong>Subset</strong> of the dataset analyzed (e.g., a range of dates or record numbers, a list of variables)</li><li><strong>Verifier</strong> that the dataset or subset accessed by a reader is identical to the one analyzed by the author (e.g., a Checksum)</li><li><strong>Location</strong> of the dataset on the internet, needed if the identifier is not "actionable" (convertable to a web address)</li></ul>') %>

**<%= _('Example citations') %>**   
<%= raw _('<ul><li>Kumar, Sujai (2012): 20 Nematode Proteomes. figshare. https://doi.org/10.6084/m9.figshare.96035.v2 (Accessed 2016-09-06).</li><li>Morran LT, Parrish II RC, Gelarden IA, Lively CM (2012) Data from: Temporal dynamics of outcrossing and host mortality rates in host-pathogen experimental coevolution. Dryad Digital Repository. https://doi.org/10.5061/dryad.c3gh6</li><li>Donna Strahan. &quot;08-B-1 from Jordan/Petra Great Temple/Upper Temenos/Trench 94/Locus 41&quot;. (2009) In Petra Great Temple Excavations. Martha Sharp Joukowsky (Ed.) Releases: 2009-10-26. Open Context. https://opencontext.org/subjects/30C3F340-5D14-497A-B9D0-7A0DA2C019F1 ARK (Archive): http://n2t.net/ark:/28722/k2125xk7p</li><li>OECD (2008), Social Expenditures aggregates, OECD Social Expenditure Statistics (database). https://doi.org/10.1787/000530172303 (Accessed on 2008-12-02).</li><li>Denhard, Michael (2009): dphase_mpeps: MicroPEPS LAF-Ensemble run by DWD for the MAP D-PHASE project. World Data Center for Climate. https://doi.org/10.1594/WDCC/dphase_mpeps</li><li>Manoug, J L (1882): Useful data on the rise of the Nile. Alexandria : Printing-Office V Penasson. http://n2t.net/ark:/13960/t44q88124</li></ul>') %>

<hr>

<h3 id="copyright-and-privacy"><%= _('Copyright and Privacy') %></h3>
<br>
<h4><%= _('Sharing data that you produced/collected yourself') %></h4>

- <%= raw _('<strong>Much data is not copyrightable in the United States</strong> because facts are not copyrightable. However, a presentation of data (such as a chart or table) may be.') %>
- <%= raw _('<strong>Data can be licensed.</strong> Some data providers apply licenses that limit how the data can be used to protect the privacy of study participants or to guide downstream uses of the data (e.g., requiring attribution or forbidding for-profit use).') %>
- <%= raw _('If you want to promote sharing and unlimited use of your data, you can make your data available under a <a href="%{creative_commons_url}">Creative Commons CC0 Declaration</a> to make your wishes explicit.') % { creative_commons_url: 'https://creativecommons.org/choose/zero/' } %>

<h4><%= _('Sharing data that you have collected from other sources') %></h4>

- <%= _('You may or may not have the rights to do so, depending upon whether that data were accessed under a license with terms of use.') %>
- <%= _('Most databases to which the UC Libraries subscribe are licensed and prohibit redistribution of data outside of UC.') %>

<%= _('If you are uncertain as to your rights to disseminate data, UC researchers can consult with your campus Office of General Council. Note: Laws about data vary outside the U.S.') %>

<%= raw _('For a general discussion about publishing your data, applicable to many disciplines, see the <a href="%{icpsr_url}">ICPSR Guide to Social Science Data Preparation and Archiving</a>.') % { icpsr_url: 'https://www.icpsr.umich.edu/files/ICPSR/access/dataprep.pdf' } %>

<h4><%= _('Confidentiality and Ethical Concerns') %></h4>
<%= _('It is vital to maintain the confidentiality of research subjects both as an ethical matter and to ensure continuing participation in research. Researchers need to understand and manage tensions between confidentiality requirements and the potential benefits of archiving and publishing the data.') %>

- <%= raw _('<strong>Evaluate the anonymity of your data.</strong> Consider to what extent your data contains direct or indirect identifiers that could be combined with other public information to identify research participants.') %>
- <%= raw _('<strong>Obtain a confidentiality review.</strong> A benefit of depositing your data with <a href="%{icpsr_url}">ICPSR</a> is that their staff offers a Disclosure review service to check your data for confidential information.') %>
- <%= raw _('<strong>Comply with UC regulations.</strong> Researchers concerned about confidentiality issues with their data should consult the <a href="%{uc_policy_url}">UC policy for Protection of Human Subjects in Research</a>.') % { uc_policy_url: 'http://policy.ucop.edu/doc/2500499/ProtectnHumanSubj' } %>
- <%= raw _('<strong>Comply with regulations for health research</strong> set forth in the <a href="%{hippa_url}">Health Insurance Portability and Accountability Act (HIPPA)</a>.') % { icpsr_url: 'https://www.icpsr.umich.edu/icpsrweb/', hippa_url: 'https://privacyruleandresearch.nih.gov/' } %>
 
<%= raw _('To ethically share confidential data, you may be able to:<ul><li><strong>Gain informed consent</strong> for data sharing (e.g. deposit in a repository or archive)</li><li><strong>Anonymize</strong> the data by removing identifying information. Be aware, however, that any dataset that contains enough information to be useful will always present some risk.</li><li><strong>Restrict the use of your data.</strong> ICPSR provides a sample <a href="%{icpsr_user_url}">Restricted Data Use Contract</a> and <a href="%{icpsr_restricted_url}">Restricted-Use Data Management Guidance</a>.') % { icpsr_user_url: 'https://www.icpsr.umich.edu/files/DSDR/04701-User_agreement.pdf', icpsr_restricted_url: 'https://www.icpsr.umich.edu/icpsrweb/content/ICPSR/access/restricted/index.html' } %>
