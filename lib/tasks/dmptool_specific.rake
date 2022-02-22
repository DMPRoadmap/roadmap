# frozen_string_literal: true

# DMPTool specific Rake tasks
namespace :dmptool_specific do
  # We sent the maDMP PRs over to DMPRoadmap after they had been live in DMPTool for some time
  # This script moves the re3data URLs which we original stored in the :identifiers table
  # over to the repositories.uri column
  desc 'Moves the re3data ids from :identifiers to :repositories.uri'
  task transfer_re3data_ids: :environment do
    re3scheme = IdentifierScheme.find_by(name: 'rethreedata')
    if re3scheme.present?
      Identifier.by_scheme_name(re3scheme, 'Repository').each do |identifier|
        repository = identifier.identifiable
        repository.update(uri: identifier.value) if repository.present? && identifier.value.present?
        identifier.destroy
      end
    end
  end

  desc 'Update Feedback confirmation email defaults'
  task update_feedback_confirmation: :environment do
    new_subject = 'DMP feedback request'
    old_subject = '%<application_name>s: Your plan has been submitted for feedback'

    new_body = '<p>Dear %<user_name>s,</p>' \
               '<p>"%<plan_name>s" has been sent to your %<application_name>s account administrator for feedback.</p>'\
               '<p>Please email %<organisation_email>s with any questions about this process.</p>'
    old_body = '<p>Hello %<user_name>s.</p>'\
      "<p>Your plan \"%<plan_name>s\" has been submitted for feedback from an
      administrator at your organisation. "\
      "If you have questions pertaining to this action, please contact us
      at %<organisation_email>s.</p>"

    Org.all.each do |org|
      org.feedback_email_subject = new_subject if org.feedback_email_subject == old_subject
      org.feedback_email_msg = new_body if org.feedback_email_msg == old_body
      org.save
    end
  end

  desc 'Adds the UCNRS RAMS IdentifierScheme for Plans'
  task init_rams: :environment do
    rams = IdentifierScheme.find_or_initialize_by(name: 'rams')
    rams.for_plans = true
    rams.for_identification = true
    rams.description = 'UCNRS RAMS System'
    rams.identifier_prefix = 'https://rams.ucnrs.org/manager/reserves/100501/applications/'
    rams.active = true
    rams.save
  end

  # rubocop:disable Layout/LineLength
  desc 'Initialize the Template and Org email subject and body'
  task init_template_and_org_emails: :environment do
    p 'Initializing empty Template emails'
    Template.published.where(email_body: nil).each do |template|
      template.update(
        email_subject: format(_('A new data management plan (DMP) for the %<org_name>s was started for you.'),
                              org_name: template.org.name),
        email_body: format(
          _('An administrator from the %<org_name>s has started a new data management plan (DMP) for you. If you have any questions or need help, please contact them at %<org_admin_email>s.'), org_name: template.org.name, org_admin_email: "<a href=\"mailto:#{template.org.contact_email}\">#{template.org.contact_email}</a>"
        )
      )
    end

    p 'Initializing empty Org emails'
    Org.where(managed: true, api_create_plan_email_body: nil).each do |org|
      org.update(
        api_create_plan_email_subject: format(
          _('A new data management plan (DMP) for the %<org_name>s was started for you.'), org_name: org.name
        ),
        api_create_plan_email_body: format(
          _('A new data management plan (DMP) has been started for you by the %<external_system_name>s. If you have any questions or need help, please contact the administrator for the %<org_name>s at %<org_admin_email>s.'), org_name: org.name, org_admin_email: "<a href=\"mailto:#{org.contact_email}\">#{org.contact_email}</a>", external_system_name: '%<external_system_name>s'
        )
      )
    end
  end
  # rubocop:enable Layout/LineLength

  desc 'Seed the Language for all Plans'
  task init_plan_language: :environment do
    p 'Initializing plans.language_id'
    dflt = Language.default

    if dflt.present?
      Language.where.not(id: dflt.id).each do |lang|
        orgs = Org.where(language_id: lang.id)
        if orgs.any?
          p "Searching for plans affiliated with and Org whose language is - #{lang.name}"
          plans = Plan.where(language_id: nil).where('title <> CONVERT(title USING ASCII)')
          plans = plans.where(org_id: orgs.map(&:id)).or(plans.where(funder_id: orgs.map(&:id)))

          if plans.any?
            p "Updated #{plans.length} plans to - #{lang.name}"
            plans.update_all(language_id: lang.id)
            pp(plans.map { |plan| "id: #{plan.id} - title: '#{plan.title}'" })
          end
        else
          p "No Orgs found for - #{lang.name}"
        end
      end

      p "Updating all remaining plans to the default language - #{dflt.name}"
      Plan.where(language_id: nil).update_all(language_id: dflt.id)
    else
      p 'Unable to process records because there is no default Language!'
    end
  end

  desc 'Temp task'
  task temp: :environment do
    hash = [{loser: 6240, winner: 6233},
    {loser: 6226, winner: 6227},
    {loser: 2258, winner: 6175},
    {loser: 3133, winner: 6156},
    {loser: 6102, winner: 6101},
    {loser: 6098, winner: 6100},
    {loser: 6099, winner: 6100},
    {loser: 2965, winner: 6086},
    {loser: 3053, winner: 6072},
    {loser: 5434, winner: 6072},
    {loser: 3458, winner: 6014},
    {loser: 1839, winner: 5941},
    {loser: 3318, winner: 5883},
    {loser: 2812, winner: 5820},
    {loser: 5793, winner: 5795},
    {loser: 5786, winner: 5778},
    {loser: 5783, winner: 5777},
    {loser: 5784, winner: 5770},
    {loser: 4517, winner: 5760},
    {loser: 2833, winner: 5758},
    {loser: 2967, winner: 5758},
    {loser: 1956, winner: 5753},
    {loser: 4974, winner: 5710},
    {loser: 5698, winner: 5699},
    {loser: 4216, winner: 5694},
    {loser: 5596, winner: 5630},
    {loser: 2503, winner: 5625},
    {loser: 2981, winner: 5612},
    {loser: 4929, winner: 5612},
    {loser: 5641, winner: 5608},
    {loser: 5606, winner: 5588},
    {loser: 2910, winner: 5559},
    {loser: 5546, winner: 5547},
    {loser: 5515, winner: 5515},
    {loser: 5845, winner: 5459},
    {loser: 4050, winner: 5447},
    {loser: 3092, winner: 5435},
    {loser: 5396, winner: 5394},
    {loser: 4839, winner: 5357},
    {loser: 5311, winner: 5310},
    {loser: 6035, winner: 5279},
    {loser: 3093, winner: 5251},
    {loser: 3649, winner: 5249},
    {loser: 3951, winner: 5210},
    {loser: 5025, winner: 5183},
    {loser: 4079, winner: 5150},
    {loser: 3083, winner: 5142},
    {loser: 5130, winner: 5129},
    {loser: 5180, winner: 5112},
    {loser: 6027, winner: 5109},
    {loser: 5382, winner: 5085},
    {loser: 5021, winner: 5024},
    {loser: 3745, winner: 5019},
    {loser: 6183, winner: 5009},
    {loser: 5038, winner: 4981},
    {loser: 5040, winner: 4981},
    {loser: 5037, winner: 4981},
    {loser: 5010, winner: 4981},
    {loser: 4999, winner: 4981},
    {loser: 5048, winner: 4981},
    {loser: 5895, winner: 4980},
    {loser: 5415, winner: 4958},
    {loser: 5624, winner: 4880},
    {loser: 4858, winner: 4859},
    {loser: 2713, winner: 4846},
    {loser: 4764, winner: 4765},
    {loser: 5510, winner: 4737},
    {loser: 2641, winner: 4734},
    {loser: 4642, winner: 4643},
    {loser: 5227, winner: 4635},
    {loser: 4596, winner: 4612},
    {loser: 4601, winner: 4600},
    {loser: 4579, winner: 4582},
    {loser: 5907, winner: 4569},
    {loser: 2859, winner: 4532},
    {loser: 4650, winner: 4497},
    {loser: 4541, winner: 4497},
    {loser: 2865, winner: 4497},
    {loser: 4377, winner: 4497},
    {loser: 4671, winner: 4497},
    {loser: 4983, winner: 4497},
    {loser: 2510, winner: 4497},
    {loser: 4924, winner: 4497},
    {loser: 2308, winner: 4458},
    {loser: 2307, winner: 4458},
    {loser: 4429, winner: 4428},
    {loser: 4971, winner: 4411},
    {loser: 4708, winner: 4411},
    {loser: 4405, winner: 4404},
    {loser: 4406, winner: 4404},
    {loser: 4398, winner: 4404},
    {loser: 4403, winner: 4404},
    {loser: 4431, winner: 4404},
    {loser: 4111, winner: 4394},
    {loser: 5383, winner: 4381},
    {loser: 2783, winner: 4376},
    {loser: 4118, winner: 4357},
    {loser: 5338, winner: 4297},
    {loser: 3859, winner: 4241},
    {loser: 1454, winner: 4215},
    {loser: 5607, winner: 4115},
    {loser: 5369, winner: 4093},
    {loser: 6172, winner: 4087},
    {loser: 5061, winner: 4054},
    {loser: 5052, winner: 4054},
    {loser: 5092, winner: 4054},
    {loser: 3977, winner: 3992},
    {loser: 3991, winner: 3992},
    {loser: 3988, winner: 3992},
    {loser: 5518, winner: 3973},
    {loser: 3965, winner: 3966},
    {loser: 3931, winner: 3932},
    {loser: 5722, winner: 3890},
    {loser: 2407, winner: 3887},
    {loser: 3870, winner: 3869},
    {loser: 3776, winner: 3792},
    {loser: 4171, winner: 3789},
    {loser: 2037, winner: 3766},
    {loser: 3758, winner: 3759},
    {loser: 5200, winner: 3740},
    {loser: 4663, winner: 3738},
    {loser: 4467, winner: 3736},
    {loser: 3427, winner: 3722},
    {loser: 3702, winner: 3703},
    {loser: 5047, winner: 3700},
    {loser: 3682, winner: 3683},
    {loser: 3673, winner: 3680},
    {loser: 4845, winner: 3660},
    {loser: 5275, winner: 3646},
    {loser: 2784, winner: 3609},
    {loser: 3605, winner: 3607},
    {loser: 3570, winner: 3571},
    {loser: 3588, winner: 3559},
    {loser: 1516, winner: 3508},
    {loser: 2377, winner: 3506},
    {loser: 3228, winner: 3495},
    {loser: 2792, winner: 3451},
    {loser: 3431, winner: 3429},
    {loser: 2421, winner: 3408},
    {loser: 2379, winner: 3408},
    {loser: 5330, winner: 3380},
    {loser: 3372, winner: 3373},
    {loser: 3345, winner: 3346},
    {loser: 5254, winner: 3312},
    {loser: 3301, winner: 3302},
    {loser: 3086, winner: 3297},
    {loser: 3985, winner: 3296},
    {loser: 2014, winner: 3296},
    {loser: 4311, winner: 3278},
    {loser: 5202, winner: 3276},
    {loser: 3235, winner: 3236},
    {loser: 3215, winner: 3216},
    {loser: 3209, winner: 3211},
    {loser: 3181, winner: 3183},
    {loser: 3161, winner: 3162},
    {loser: 5847, winner: 3114},
    {loser: 3039, winner: 3040},
    {loser: 4352, winner: 3031},
    {loser: 4220, winner: 3025},
    {loser: 4823, winner: 2988},
    {loser: 3043, winner: 2987},
    {loser: 5242, winner: 2964},
    {loser: 4212, winner: 2902},
    {loser: 5307, winner: 2902},
    {loser: 3015, winner: 2900},
    {loser: 2681, winner: 2896},
    {loser: 2889, winner: 2888},
    {loser: 2874, winner: 2875},
    {loser: 2801, winner: 2873},
    {loser: 2562, winner: 2867},
    {loser: 3080, winner: 2867},
    {loser: 6187, winner: 2848},
    {loser: 3218, winner: 2822},
    {loser: 2800, winner: 2809},
    {loser: 3097, winner: 2809},
    {loser: 2806, winner: 2807},
    {loser: 2753, winner: 2754},
    {loser: 3376, winner: 2712},
    {loser: 2601, winner: 2651},
    {loser: 3817, winner: 2630},
    {loser: 3037, winner: 2630},
    {loser: 3107, winner: 2576},
    {loser: 3853, winner: 2523},
    {loser: 2515, winner: 2516},
    {loser: 2478, winner: 2477},
    {loser: 2314, winner: 2469},
    {loser: 4289, winner: 2452},
    {loser: 5789, winner: 2452},
    {loser: 2664, winner: 2452},
    {loser: 4333, winner: 2447},
    {loser: 6127, winner: 2447},
    {loser: 3386, winner: 2447},
    {loser: 4840, winner: 2417},
    {loser: 2724, winner: 2393},
    {loser: 5700, winner: 2393},
    {loser: 5229, winner: 2393},
    {loser: 2672, winner: 2387},
    {loser: 3629, winner: 2386},
    {loser: 3128, winner: 2371},
    {loser: 5119, winner: 2362},
    {loser: 5939, winner: 2362},
    {loser: 3405, winner: 2288},
    {loser: 5105, winner: 2280},
    {loser: 4487, winner: 2260},
    {loser: 6175, winner: 2257},
    {loser: 4125, winner: 2257},
    {loser: 3638, winner: 2254},
    {loser: 4603, winner: 2254},
    {loser: 4033, winner: 2199},
    {loser: 2177, winner: 2176},
    {loser: 2160, winner: 2161},
    {loser: 5422, winner: 2156},
    {loser: 2151, winner: 2152},
    {loser: 2167, winner: 2104},
    {loser: 2088, winner: 2089},
    {loser: 4538, winner: 2084},
    {loser: 2035, winner: 2036},
    {loser: 4739, winner: 1993},
    {loser: 1987, winner: 1986},
    {loser: 1971, winner: 1970},
    {loser: 1898, winner: 1897},
    {loser: 1899, winner: 1897},
    {loser: 4520, winner: 1889},
    {loser: 4699, winner: 1889},
    {loser: 4702, winner: 1889},
    {loser: 5194, winner: 1889},
    {loser: 3642, winner: 1889},
    {loser: 6049, winner: 1877},
    {loser: 6048, winner: 1877},
    {loser: 1866, winner: 1865},
    {loser: 5719, winner: 1863},
    {loser: 1806, winner: 1805},
    {loser: 4504, winner: 1789},
    {loser: 1773, winner: 1772},
    {loser: 5190, winner: 1769},
    {loser: 2934, winner: 1769},
    {loser: 3901, winner: 1769},
    {loser: 4700, winner: 1739},
    {loser: 4677, winner: 1739},
    {loser: 1960, winner: 1736},
    {loser: 2465, winner: 1730},
    {loser: 2466, winner: 1730},
    {loser: 3691, winner: 1728},
    {loser: 2993, winner: 1724},
    {loser: 4479, winner: 1710},
    {loser: 3549, winner: 1698},
    {loser: 3456, winner: 1698},
    {loser: 3470, winner: 1698},
    {loser: 1802, winner: 1694},
    {loser: 2929, winner: 1672},
    {loser: 5475, winner: 1670},
    {loser: 1811, winner: 1665},
    {loser: 2614, winner: 1662},
    {loser: 1870, winner: 1657},
    {loser: 3811, winner: 1657},
    {loser: 2540, winner: 1613},
    {loser: 4587, winner: 1613},
    {loser: 3597, winner: 1613},
    {loser: 3574, winner: 1613},
    {loser: 5566, winner: 1612},
    {loser: 5565, winner: 1612},
    {loser: 3403, winner: 1595},
    {loser: 2003, winner: 1502},
    {loser: 4832, winner: 1453},
    {loser: 4638, winner: 1451},
    {loser: 4101, winner: 1408},
    {loser: 2533, winner: 1399},
    {loser: 4174, winner: 1397},
    {loser: 2148, winner: 1352},
    {loser: 4165, winner: 1326},
    {loser: 5241, winner: 1308},
    {loser: 4034, winner: 1282},
    {loser: 3425, winner: 1277},
    {loser: 3535, winner: 1268},
    {loser: 5418, winner: 1259},
    {loser: 3784, winner: 1239},
    {loser: 2599, winner: 1226},
    {loser: 4149, winner: 1226},
    {loser: 5917, winner: 1226},
    {loser: 4267, winner: 1214},
    {loser: 5586, winner: 1200},
    {loser: 3367, winner: 1180},
    {loser: 2244, winner: 1180},
    {loser: 2877, winner: 1133},
    {loser: 2203, winner: 1119},
    {loser: 2197, winner: 1119},
    {loser: 3174, winner: 1119},
    {loser: 3175, winner: 1119},
    {loser: 3935, winner: 1107},
    {loser: 5016, winner: 1107},
    {loser: 1758, winner: 1107},
    {loser: 3258, winner: 1107},
    {loser: 4738, winner: 1095},
    {loser: 3078, winner: 1054},
    {loser: 2741, winner: 1028},
    {loser: 3222, winner: 1026},
    {loser: 4909, winner: 990},
    {loser: 5742, winner: 986},
    {loser: 3145, winner: 985},
    {loser: 4531, winner: 955},
    {loser: 2740, winner: 934},
    {loser: 2858, winner: 914},
    {loser: 5824, winner: 847},
    {loser: 4443, winner: 826},
    {loser: 3928, winner: 826},
    {loser: 5528, winner: 826},
    {loser: 4803, winner: 826},
    {loser: 5529, winner: 826},
    {loser: 4159, winner: 816},
    {loser: 4861, winner: 816},
    {loser: 4187, winner: 816},
    {loser: 4043, winner: 810},
    {loser: 4996, winner: 794},
    {loser: 3398, winner: 793},
    {loser: 4208, winner: 782},
    {loser: 4262, winner: 772},
    {loser: 5696, winner: 772},
    {loser: 5960, winner: 765},
    {loser: 5788, winner: 742},
    {loser: 5252, winner: 742},
    {loser: 3483, winner: 729},
    {loser: 5711, winner: 705},
    {loser: 2128, winner: 672},
    {loser: 5483, winner: 659},
    {loser: 5087, winner: 630},
    {loser: 5802, winner: 625},
    {loser: 3947, winner: 598},
    {loser: 4473, winner: 570},
    {loser: 2732, winner: 555},
    {loser: 5874, winner: 538},
    {loser: 4557, winner: 494},
    {loser: 4330, winner: 494},
    {loser: 2231, winner: 467},
    {loser: 4748, winner: 457},
    {loser: 5078, winner: 433},
    {loser: 3617, winner: 430},
    {loser: 3347, winner: 401},
    {loser: 2735, winner: 400},
    {loser: 2120, winner: 390},
    {loser: 3622, winner: 366},
    {loser: 5947, winner: 356},
    {loser: 4191, winner: 321},
    {loser: 4296, winner: 321},
    {loser: 4854, winner: 320},
    {loser: 2817, winner: 309},
    {loser: 3272, winner: 297},
    {loser: 4362, winner: 297},
    {loser: 5397, winner: 297},
    {loser: 5395, winner: 297},
    {loser: 1939, winner: 293},
    {loser: 2018, winner: 286},
    {loser: 4665, winner: 286},
    {loser: 6211, winner: 286},
    {loser: 1950, winner: 286},
    {loser: 2146, winner: 286},
    {loser: 3664, winner: 265},
    {loser: 2765, winner: 262},
    {loser: 3210, winner: 253},
    {loser: 3809, winner: 251},
    {loser: 5197, winner: 251},
    {loser: 2022, winner: 251},
    {loser: 5486, winner: 251},
    {loser: 3129, winner: 251},
    {loser: 2904, winner: 245},
    {loser: 4772, winner: 245},
    {loser: 5140, winner: 245},
    {loser: 3879, winner: 245},
    {loser: 4970, winner: 245},
    {loser: 1790, winner: 245},
    {loser: 4097, winner: 245},
    {loser: 2464, winner: 245},
    {loser: 2283, winner: 245},
    {loser: 4006, winner: 236},
    {loser: 2415, winner: 231},
    {loser: 2411, winner: 231},
    {loser: 2322, winner: 231},
    {loser: 2397, winner: 231},
    {loser: 3621, winner: 228},
    {loser: 4425, winner: 210},
    {loser: 5248, winner: 210},
    {loser: 4424, winner: 210},
    {loser: 4763, winner: 210},
    {loser: 4617, winner: 208},
    {loser: 5851, winner: 207},
    {loser: 2216, winner: 205},
    {loser: 3858, winner: 205},
    {loser: 5497, winner: 192},
    {loser: 3000, winner: 190},
    {loser: 1779, winner: 170},
    {loser: 4457, winner: 167},
    {loser: 3721, winner: 143},
    {loser: 4372, winner: 141},
    {loser: 5685, winner: 140},
    {loser: 4236, winner: 139},
    {loser: 1994, winner: 126},
    {loser: 5127, winner: 126},
    {loser: 6232, winner: 123},
    {loser: 3172, winner: 123},
    {loser: 3223, winner: 123},
    {loser: 4084, winner: 120},
    {loser: 2356, winner: 119},
    {loser: 2537, winner: 119},
    {loser: 2538, winner: 119},
    {loser: 5720, winner: 119},
    {loser: 1979, winner: 119},
    {loser: 2776, winner: 106},
    {loser: 4778, winner: 96},
    {loser: 5544, winner: 83},
    {loser: 2925, winner: 74},
    {loser: 177, winner: 72},
    {loser: 4585, winner: 42},
    {loser: 6129, winner: 14},
    {loser: 6128, winner: 14},
    {loser: 4918, winner: 11},
    {loser: 4848, winner: 8},
    {loser: 5763, winner: 8},
    {loser: 2728, winner: 7},
    {loser: 6265, winner: 6},
    {loser: 5648, winner: 3}]

    changes = []
    hash.each do |item|
      changes << { loser: Org.find_by(id: item[:loser]), winner: Org.find_by(id: item[:winner]) }
    end
    changes.sort_by { |hash| hash[:loser].name }

    changes.each do |item|
      p "Loser: #{item[:loser].id} - #{item[:loser].name} --> Winner: #{item[:winner].id} - #{item[:winner].name}"
    end
  end
end
