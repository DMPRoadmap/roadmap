# frozen_string_literal: true

module Api

  module V1

    class LanguagePresenter

      class << self

        LANGUAGE_MAP = {
          aa: "aar", ab: "abk", af: "afr", ak: "aka", am: "amh", ar: "ara", an: "arg",
          as: "asm", av: "ava", ae: "ave", ay: "aym", az: "aze",

          ba: "bak", bm: "bam", be: "bel", bn: "ben", bh: "bih", bi: "bis", bo: "tib",
          bs: "bos", br: "bre", bg: "bul",

          ca: "cat", cs: "cze", ch: "cha", ce: "che", cu: "chu", cv: "chv", co: "cos",
          cr: "cre", cy: "wel",

          da: "dan", de: "deu", dv: "div", dz: "dzo",

          el: "gre", en: "eng", eo: "epo", es: "spa", et: "est", eu: "baq", ee: "ewe",

          fo: "fao", fa: "per", fj: "fij", fi: "fin", fr: "fre", fy: "fry", ff: "ful",

          gd: "gla", ga: "gle", gl: "glg", gv: "glv", gn: "grn", gu: "guj",

          ht: "hat", ha: "hau", he: "heb", hz: "her", hi: "hin", ho: "hmo", hr: "hrv",
          hu: "hun", hy: "arm",

          ig: "ibo", io: "ido", ii: "iii", iu: "iku", ie: "ile", ia: "ina", id: "ind",
          ik: "ipk", is: "ice", it: "ita",

          jv: "jav", ja: "jpn",

          kl: "kal", kn: "kan", ks: "kas", kr: "kau", kk: "kaz", km: "khm", ki: "kik",
          ky: "kir", kv: "kom", kg: "kon", ko: "kor", kj: "kua", ku: "kur", ka: "geo",
          kw: "cor",

          lo: "lao", la: "lat", lv: "lav", li: "lim", ln: "lin", lt: "lit", lb: "ltz",
          lu: "lub", lg: "lug",

          mk: "mac", mh: "mah", ml: "mal", mi: "mao", mr: "mar", ms: "may", mg: "mlg",
          mt: "mlt", mn: "mon", my: "bur",

          na: "nau", nv: "nav", nr: "nbl", nd: "nde", ng: "ndo", ne: "nep", nl: "dut",
          nn: "nno", nb: "nob", no: "nor", ny: "nya",

          oc: "oci", oj: "oji", or: "ori", om: "orm", os: "oss",

          pa: "pan", pi: "pli", pl: "pol", pt: "por", ps: "pus",

          qu: "que",

          rm: "roh", ro: "rum", rn: "run", ru: "rus", rw: "kin",

          sg: "sag", sa: "san", si: "sin", sk: "slo", sl: "slv", se: "sme", sm: "smo",
          sn: "sna", sd: "snd", so: "som", st: "sot", sq: "alb", sc: "srd", sr: "srp",
          ss: "ssw", su: "sun", sw: "swa", sv: "swe",

          ty: "tah", ta: "tam", tt: "tat", te: "tel", tg: "tgk", tl: "tgl", th: "tha",
          ti: "tir", to: "ton", tn: "tsn", ts: "tso", tk: "tuk", tr: "tur", tw: "twi",

          ug: "uig", uk: "ukr", ur: "urd", uz: "uzb",

          ve: "ven", vi: "vie", vo: "vol",

          wa: "wln", wo: "wol",

          xh: "xho",

          yi: "yid", yo: "yor",

          za: "zha", zh: "chi", zu: "zul"
        }.freeze

        # Convert the incoming 2 (e.g. en - ISO 639-1) or 2+region (e.g. en-UK)
        # into the 3 character code (e.g. eng - ISO 639-2)
        def three_char_code(lang:)
          two_char_code = lang.to_s.split("-").first
          LANGUAGE_MAP[two_char_code.to_sym]
        end

      end

    end

  end

end
