-- SPDX-License-Identifier: GPL-3.0-or-later
-- LSSP 共享拼音数据（3x5b1 / 3x5b2 共用）
-- TONE_DATA 键名与 SECOND_CODE_DATA 中的 d 引用均为裸后缀，
-- 由 _lssp_factory 根据变体在生成时添加 lssp_three_b1_ / lssp_three_b2_ 前缀。

return {
  SECOND_CODE_DATA = {
    bzy = {
      {
        { d = "baanang", t = { "ba ban\n", "bang" } },
        { d = "baieiao", t = { "bai bei\n", "bao" } },
        { d = "bo",      t = "bo" },
        { d = "beneng",  t = { "ben\n", "beng" } },
        { d = "zvan",    t = "züan" }
      },
      {
        { d = "bianiang", t = { "bian\n", "biang" } },
        { d = "biiao",    t = { "bi biao" } },
        false,
        { d = "bieining", t = { "bie bin\n", "bing" } },
        { d = "zv",       t = "zü" }
      },
      {
        { d = "ziianiang", t = { "zian\n", "ziang" } },
        { d = "ziiiao",    t = { "zii ziao" } },
        { d = "buziu",     t = { "bu ziu" } },
        { d = "ziieining", t = { "zie zin\n", "zing" } },
        { d = "zivevn",    t = { "züe zün" } }
      }
    },
    pcy = {
      {
        { d = "paanang", t = { "pa pan\n", "pang" } },
        { d = "paieiao", t = { "pai pei\n", "pao" } },
        { d = "poou",    t = { "po pou" } },
        { d = "peneng",  t = { "pen\n", "peng" } },
        { d = "cvan",    t = "cüan" }
      },
      {
        { d = "pian",  t = "pian" },
        { d = "piiao", t = { "pi piao" } },
        false,
        { d = "pieining", t = { "pie pin\n", "ping" } },
        { d = "cv",       t = "cü" }
      },
      {
        { d = "ciianiang", t = { "cian\n", "ciang" } },
        { d = "ciiiao",    t = { "cii ciao" } },
        { d = "puciu",     t = { "pu ciu" } },
        { d = "ciieining", t = { "cie cin\n", "cing" } },
        { d = "civevn",    t = { "cüe cün" } }
      }
    },
    msy = {
      {
        { d = "maanang", t = { "ma man\n", "mang" } },
        { d = "maieiao", t = { "mai mei\n", "mao" } },
        { d = "moou",    t = { "mo mou" } },
        { d = "meeneng", t = { "me men\n", "meng" } },
        { d = "svan",    t = "süan" }
      },
      {
        { d = "mian",     t = "mian" },
        { d = "miiao",    t = { "mi miao" } },
        { d = "miu",      t = "miu" },
        { d = "mieining", t = { "mie min\n", "ming" } },
        { d = "sv",       t = "sü" }
      },
      {
        { d = "siianiang", t = { "sian\n", "siang" } },
        { d = "siiiao",    t = { "sii siao" } },
        { d = "musiu",     t = { "mu siu" } },
        { d = "siieining", t = { "sie sin\n", "sing" } },
        { d = "sivevn",    t = { "süe sün" } }
      }
    },
    rf = {
      {
        { d = "ranang",  t = { "ran rang" } },
        { d = "rao",     t = "rao" },
        { d = "riouong", t = { "ri rou\n", "rong" } },
        { d = "reeneng", t = { "re ren\n", "reng" } },
        false
      },
      {
        { d = "faanang", t = { "fa fan\n", "fang" } },
        { d = "feiiao",  t = { "fei fiao" } },
        { d = "foou",    t = { "fo fou" } },
        { d = "feneng",  t = { "fen\n", "feng" } },
        { d = "fu",      t = "fu" }
      },
      {
        { d = "ruauan", t = { "rua\n", "ruan" } },
        { d = "rui",    t = "rui" },
        { d = "ruou",   t = { "ruo ru" } },
        { d = "run",    t = "run" },
        false
      }
    },
    d = {
      {
        { d = "daanang", t = { "da dan\n", "dang" } },
        { d = "daieiao", t = { "dai dei\n", "dao" } },
        { d = "douong",  t = { "dou\n", "dong" } },
        { d = "deeneng", t = { "de den\n", "deng" } },
        false
      },
      {
        { d = "diaian", t = { "dia dian" } },
        { d = "diiao",  t = { "di diao" } },
        { d = "diu",    t = "diu" },
        { d = "dieing", t = { "die ding" } },
        false
      },
      {
        { d = "duan", t = "duan" },
        { d = "dui",  t = "dui" },
        { d = "duou", t = { "duo du" } },
        { d = "dun",  t = "dun" },
        false
      }
    },
    t = {
      {
        { d = "taanang", t = { "ta tan\n", "tang" } },
        { d = "taieiao", t = { "tai tei\n", "tao" } },
        { d = "touong",  t = { "tou\n", "tong" } },
        { d = "teeng",   t = { "te teng" } },
        false
      },
      {
        { d = "tian",  t = "tian" },
        { d = "tiiao", t = { "ti tiao" } },
        false,
        { d = "tieing", t = { "tie ting" } },
        false
      },
      {
        { d = "tuan", t = "tuan" },
        { d = "tui",  t = "tui" },
        { d = "tuou", t = { "tuo tu" } },
        { d = "tun",  t = "tun" },
        false
      }
    },
    n = {
      {
        { d = "naanang", t = { "na nan\n", "nang" } },
        { d = "naieiao", t = { "nai nei\n", "nao" } },
        { d = "nouong",  t = { "nou\n", "nong" } },
        { d = "neeneng", t = { "ne nen\n", "neng" } },
        false
      },
      {
        { d = "niaianiang", t = { "nian\n", "niang" } },
        { d = "niiao",      t = { "ni niao" } },
        { d = "niu",        t = "niu" },
        { d = "nieining",   t = { "nie nin\n", "ning" } },
        { d = "nv",         t = "nü" }
      },
      {
        { d = "nuan", t = "nuan" },
        false,
        { d = "nuou", t = { "nuo nu" } },
        { d = "nun",  t = "nun" },
        { d = "nve",  t = "nüe" }
      }
    },
    l = {
      {
        { d = "laanang", t = { "la lan\n", "lang" } },
        { d = "laieiao", t = { "lai lei\n", "lao" } },
        { d = "loouong", t = { "lo lou\n", "long" } },
        { d = "leeneng", t = { "le leng" } },
        false
      },
      {
        { d = "liaianiang", t = { "lia lian\n", "liang" } },
        { d = "liiao",      t = { "li liao" } },
        { d = "liu",        t = "liu" },
        { d = "lieining",   t = { "lie lin\n", "ling" } },
        { d = "lv",         t = "lü" }
      },
      {
        { d = "luan", t = "luan" },
        false,
        { d = "luou", t = { "luo lu" } },
        { d = "lun",  t = "lun" },
        { d = "lve",  t = "lüe" }
      }
    },
    gj = {
      {
        { d = "gaanang", t = { "ga gan\n", "gang" } },
        { d = "gaieiao", t = { "gai gei\n", "gao" } },
        { d = "gouong",  t = { "gou\n", "gong" } },
        { d = "geeneng", t = { "ge gen\n", "geng" } },
        { d = "jvan",    t = "juan" }
      },
      {
        { d = "jiaianiang", t = { "jia jian\n", "jiang" } },
        { d = "jiiao",      t = { "ji jiao" } },
        { d = "jiuiong",    t = { "jiu\n", "jiong" } },
        { d = "jieining",   t = { "jie jin\n", "jing" } },
        { d = "jv",         t = "ju" }
      },
      {
        { d = "guauanuang", t = { "gua guan\n", "guang" } },
        { d = "guaiui",     t = { "guai gui" } },
        { d = "guou",       t = { "guo gu" } },
        { d = "gun",        t = "gun" },
        { d = "jvevn",      t = { "jue jun" } }
      }
    },
    kq = {
      {
        { d = "kaanang", t = { "ka kan\n", "kang" } },
        { d = "kaieiao", t = { "kai kei\n", "kao" } },
        { d = "kouong",  t = { "kou\n", "kong" } },
        { d = "keeneng", t = { "ke ken\n", "keng" } },
        { d = "qvan",    t = "quan" }
      },
      {
        { d = "qiaianiang", t = { "qia qian\n", "qiang" } },
        { d = "qiiao",      t = { "qi qiao" } },
        { d = "qiuiong",    t = { "qiu\n", "qiong" } },
        { d = "qieining",   t = { "qie qin\n", "qing" } },
        { d = "qv",         t = "qu" }
      },
      {
        { d = "kuauanuang", t = { "kua kuan\n", "kuang" } },
        { d = "kuaiui",     t = { "kuai kui" } },
        { d = "kuou",       t = { "kuo ku" } },
        { d = "kun",        t = "kun" },
        { d = "qvevn",      t = { "que qun" } }
      }
    },
    hx = {
      {
        { d = "haanang", t = { "ha han\n", "hang" } },
        { d = "haieiao", t = { "hai hei\n", "hao" } },
        { d = "houong",  t = { "hou\n", "hong" } },
        { d = "heeneng", t = { "he hen\n", "heng" } },
        { d = "xvan",    t = "xuan" }
      },
      {
        { d = "xiaianiang", t = { "xia xian\n", "xiang" } },
        { d = "xiiao",      t = { "xi xiao" } },
        { d = "xiuiong",    t = { "xiu\n", "xiong" } },
        { d = "xieining",   t = { "xie xin\n", "xing" } },
        { d = "xv",         t = "xu" }
      },
      {
        { d = "huauanuang", t = { "hua huan\n", "huang" } },
        { d = "huaiui",     t = { "huai hui" } },
        { d = "huou",       t = { "huo hu" } },
        { d = "hun",        t = "hun" },
        { d = "xvevn",      t = { "xue xun" } }
      }
    },
    wy = {
      {
        { d = "aanang", t = { "a an\n", "ang" } },
        { d = "aieiao", t = { "ai ê\n", "ao" } },
        { d = "oou",    t = { "o ou" } },
        { d = "eeneng", t = { "e en\n", "eng" } },
        { d = "eryvan", t = { "er yuan" } }
      },
      {
        { d = "yaanang", t = { "ya yan\n", "yang" } },
        { d = "yiao",    t = { "yi yao" } },
        { d = "yoouong", t = { "yo you\n", "yong" } },
        { d = "yeining", t = { "ye yin\n", "ying" } },
        { d = "yv",      t = "yu" }
      },
      {
        { d = "waanang", t = { "wa wan\n", "wang" } },
        { d = "waiei",   t = { "wai wei" } },
        { d = "wou",     t = { "wo wu" } },
        { d = "weneng",  t = { "wen\n", "weng" } },
        { d = "yvevn",   t = { "yue yun" } }
      }
    },
    zhz = {
      {
        { d = "zhaanang", t = { "zha zhan\n", "zhang" } },
        { d = "zhaieiao", t = { "zhai zhei\n", "zhao" } },
        { d = "zhiouong", t = { "zhi zhou\n", "zhong" } },
        { d = "zheeneng", t = { "zhe zhen\n", "zheng" } },
        { d = "zuan",     t = "zuan" }
      },
      {
        { d = "zaanang", t = { "za zan\n", "zang" } },
        { d = "zaieiao", t = { "zai zei\n", "zao" } },
        { d = "ziouong", t = { "zi zou\n", "zong" } },
        { d = "zeeneng", t = { "ze zen\n", "zeng" } },
        { d = "zuouiu",  t = { "zuo zui\n", "zu" } }
      },
      {
        { d = "zhuauanuang", t = { "zhua|uan\n", "zhuang" } },
        { d = "zhuaiui",     t = { "zhuai\n", "zhui" } },
        { d = "zhuou",       t = { "zhuo\n", "zhu" } },
        { d = "zhun",        t = "zhun" },
        { d = "zun",         t = "zun" }
      }
    },
    chc = {
      {
        { d = "chaanang", t = { "cha chan\n", "chang" } },
        { d = "chaiao",   t = { "chai chao" } },
        { d = "chiouong", t = { "chi chou\n", "chong" } },
        { d = "cheeneng", t = { "che chen\n", "cheng" } },
        { d = "cuan",     t = "cuan" }
      },
      {
        { d = "caanang", t = { "ca can\n", "cang" } },
        { d = "caiao",   t = { "cai cao" } },
        { d = "ciouong", t = { "ci cou\n", "cong" } },
        { d = "ceeneng", t = { "ce cen\n", "ceng" } },
        { d = "cuouiu",  t = { "cuo cui\n", "cu" } }
      },
      {
        { d = "chuauanuang", t = { "chua|uan\n", "chuang" } },
        { d = "chuaiui",     t = { "chuai\n", "chui" } },
        { d = "chuou",       t = { "chuo\n", "chu" } },
        { d = "chun",        t = "chun" },
        { d = "cun",         t = "cun" }
      }
    },
    shs = {
      {
        { d = "shaanang", t = { "sha shan\n", "shang" } },
        { d = "shaieiao", t = { "shai shei\n", "shao" } },
        { d = "shiou",    t = { "shi shou" } },
        { d = "sheeneng", t = { "she shen\n", "sheng" } },
        { d = "suan",     t = "suan" }
      },
      {
        { d = "saanang", t = { "sa san\n", "sang" } },
        { d = "saiao",   t = { "sai sao" } },
        { d = "siouong", t = { "si sou\n", "song" } },
        { d = "seeneng", t = { "se sen\n", "seng" } },
        { d = "suouiu",  t = { "suo sui\n", "su" } }
      },
      {
        { d = "shuauanuang", t = { "shua|uan\n", "shuang" } },
        { d = "shuaiui",     t = { "shuai\n", "shui" } },
        { d = "shuou",       t = { "shuo\n", "shu" } },
        { d = "shun",        t = "shun" },
        { d = "sun",         t = "sun" }
      }
    }
  },
  TONE_DATA = {
    ["aanang"] = {
      { "ā",   "á",   "ǎ",   "à",   "a" },
      { "ān",  false, "ǎn",  "àn",  "an" },
      { "āng", "áng", false, "àng", "ang" }
    },
    ["aieiao"] = {
      { "āi", "ái", "ǎi", "ài", "ai" },
      { "ēi", "éi", "ěi", "èi", "ei" },
      { "āo", "áo", "ǎo", "ào", "ao" }
    },
    ["baanang"] = {
      { "bā",   "bá",   "bǎ",   "bà",   "ba" },
      { "bān",  "bán",  "bǎn",  "bàn",  "ban" },
      { "bāng", "báng", "bǎng", "bàng", "bang" }
    },
    ["baieiao"] = {
      { "bāi", "bái", "bǎi", "bài", "bai" },
      { "bēi", "béi", "běi", "bèi", "bei" },
      { "bāo", "báo", "bǎo", "bào", "bao" }
    },
    ["beneng"] = {
      { false,  false,  false,  false,  false },
      { "bēn",  "bén",  "běn",  "bèn",  "ben" },
      { "bēng", "béng", "běng", "bèng", "beng" }
    },
    ["bianiang"] = {
      { false,  false,   false,  false,  false },
      { "biān", "bián",  "biǎn", "biàn", "bian" },
      { false,  "biáng", false,  false,  "biang" }
    },
    ["bieining"] = {
      { "biē",  "bié",  "biě",  "biè",  "bie" },
      { "bīn",  "bín",  "bǐn",  "bìn",  "bin" },
      { "bīng", "bíng", "bǐng", "bìng", "bing" }
    },
    ["biiao"] = {
      { false,  false,  false,  false,  false },
      { "bī",   "bí",   "bǐ",   "bì",   "bi" },
      { "biāo", "biáo", "biǎo", "biào", "biao" }
    },
    ["bo"] = {
      { "bō",  "bó",  "bǒ",  "bò",  "bo" },
      { false, false, false, false, false },
      { false, false, false, false, false }
    },
    ["buziu"] = {
      { false, false, false, false, false },
      { "ziū", "ziú", "ziǔ", "ziù", "ziu" },
      { "bū",  "bú",  "bǔ",  "bù",  "bu" }
    },
    ["caanang"] = {
      { "cā",   "cá",   "cǎ",   "cà",   "ca" },
      { "cān",  "cán",  "cǎn",  "càn",  "can" },
      { "cāng", "cáng", "cǎng", "càng", "cang" }
    },
    ["caiao"] = {
      { "cāi", "cái", "cǎi", "cài", "cai" },
      { false, false, false, false, false },
      { "cāo", "cáo", "cǎo", "cào", "cao" }
    },
    ["ceeneng"] = {
      { "cē",   "cé",   "cě",   "cè",   "ce" },
      { "cēn",  "cén",  "cěn",  "cèn",  "cen" },
      { "cēng", "céng", "cěng", "cèng", "ceng" }
    },
    ["chaanang"] = {
      { "chā",   "chá",   "chǎ",   "chà",   "cha" },
      { "chān",  "chán",  "chǎn",  "chàn",  "chan" },
      { "chāng", "cháng", "chǎng", "chàng", "chang" }
    },
    ["chaiao"] = {
      { "chāi", "chái", "chǎi", "chài", "chai" },
      { false,  false,  false,  false,  false },
      { "chāo", "cháo", "chǎo", "chào", "chao" }
    },
    ["cheeneng"] = {
      { "chē",   "ché",   "chě",   "chè",   "che" },
      { "chēn",  "chén",  "chěn",  "chèn",  "chen" },
      { "chēng", "chéng", "chěng", "chèng", "cheng" }
    },
    ["chiouong"] = {
      { "chī",   "chí",   "chǐ",   "chì",   "chi" },
      { "chōu",  "chóu",  "chǒu",  "chòu",  "chou" },
      { "chōng", "chóng", "chǒng", "chòng", "chong" }
    },
    ["chuaiui"] = {
      { "chuāi", "chuái", "chuǎi", "chuài", "chuai" },
      { "chuī",  "chuí",  "chuǐ",  "chuì",  "chui" },
      { false,   false,   false,   false,   false }
    },
    ["chuauanuang"] = {
      { "chuā",   "chuá",   "chuǎ",   "chuà",   "chua" },
      { "chuān",  "chuán",  "chuǎn",  "chuàn",  "chuan" },
      { "chuāng", "chuáng", "chuǎng", "chuàng", "chuang" }
    },
    ["chun"] = {
      { false,  false,  false,  false,  false },
      { "chūn", "chún", "chǔn", "chùn", "chun" },
      { false,  false,  false,  false,  false }
    },
    ["chuou"] = {
      { "chuō", "chuó", "chuǒ", "chuò", "chuo" },
      { false,  false,  false,  false,  false },
      { "chū",  "chú",  "chǔ",  "chù",  "chu" }
    },
    ["ciouong"] = {
      { "cī",   "cí",   "cǐ",   "cì",   "ci" },
      { "cōu",  "cóu",  "cǒu",  "còu",  "cou" },
      { "cōng", "cóng", "cǒng", "còng", "cong" }
    },
    ["cuan"] = {
      { false,  false,  false,  false,  false },
      { "cuān", "cuán", "cuǎn", "cuàn", "cuan" },
      { false,  false,  false,  false,  false }
    },
    ["cun"] = {
      { false, false, false, false, false },
      { "cūn", "cún", "cǔn", "cùn", "cun" },
      { false, false, false, false, false }
    },
    ["cuouiu"] = {
      { "cuō", "cuó", "cuǒ", "cuò", "cuo" },
      { "cuī", "cuí", "cuǐ", "cuì", "cui" },
      { "cū",  "cú",  "cǔ",  "cù",  "cu" }
    },
    ["ciianiang"] = {
      { "ciā",   "ciá",   "ciǎ",   "cià",   "cia" },
      { "ciān",  "cián",  "ciǎn",  "ciàn",  "cian" },
      { "ciāng", "ciáng", "ciǎng", "ciàng", "ciang" }
    },
    ["ciieining"] = {
      { "ciē",  "cié",  "ciě",  "ciè",  "cie" },
      { "cīn",  "cín",  "cǐn",  "cìn",  "cin" },
      { "cīng", "cíng", "cǐng", "cìng", "cing" }
    },
    ["ciiiao"] = {
      { false,  false,  false,  false,  false },
      { "ciī",  "cií",  "ciǐ",  "ciì",  "cii" },
      { "ciāo", "ciáo", "ciǎo", "ciào", "ciao" }
    },
    ["civevn"] = {
      { "cüē", "cüé", "cüě", "cüè", "cüe" },
      { "cǖn", "cǘn", "cǚn", "cǜn", "cün" },
      { false, false, false, false, false }
    },
    ["cv"] = {
      { false, false, false, false, false },
      { false, false, false, false, false },
      { "cǖ",  "cǘ",  "cǚ",  "cǜ",  "cü" }
    },
    ["cvan"] = {
      { false,  false,  false,  false,  false },
      { "cüān", "cüán", "cüǎn", "cüàn", "cüan" },
      { false,  false,  false,  false,  false }
    },
    ["daanang"] = {
      { "dā",   "dá",   "dǎ",   "dà",   "da" },
      { "dān",  "dán",  "dǎn",  "dàn",  "dan" },
      { "dāng", "dáng", "dǎng", "dàng", "dang" }
    },
    ["daieiao"] = {
      { "dāi", "dái", "dǎi", "dài", "dai" },
      { "dēi", "déi", "děi", "dèi", "dei" },
      { "dāo", "dáo", "dǎo", "dào", "dao" }
    },
    ["deeneng"] = {
      { "dē",   "dé",   "dě",   "dè",   "de" },
      { "dēn",  "dén",  "děn",  "dèn",  "den" },
      { "dēng", "déng", "děng", "dèng", "deng" }
    },
    ["default_aanang"] = {
      { "ā",   "á",   "ǎ",   "à",   "a" },
      { "ān",  "án",  "ǎn",  "àn",  "an" },
      { "āng", "áng", "ǎng", "àng", "ang" }
    },
    ["default_aieiao"] = {
      { "āi", "ái", "ǎi", "ài", "ai" },
      { "ê̄", "ế", "ê̌", "ề", "ê" },
      { "āo", "áo", "ǎo", "ào", "ao" }
    },
    ["default_eeneng"] = {
      { "ē",   "é",   "ě",   "è",   "e" },
      { "ēn",  "én",  "ěn",  "èn",  "en" },
      { "ēng", "éng", "ěng", "èng", "eng" }
    },
    ["default_ervan"] = {
      { "ēr",  "ér",  "ěr",  "èr",  "er" },
      { "üān", "üán", "üǎn", "üàn", "üan" },
      { false, false, false, false, false }
    },
    ["default_iaianiang"] = {
      { "iā",   "iá",   "iǎ",   "ià",   "ia" },
      { "iān",  "ián",  "iǎn",  "iàn",  "ian" },
      { "iāng", "iáng", "iǎng", "iàng", "iang" }
    },
    ["default_iaiiiao"] = {
      { "iāi", "iái", "iǎi", "iài", "iai" },
      { "ī",   "í",   "ǐ",   "ì",   "i" },
      { "iāo", "iáo", "iǎo", "iào", "iao" }
    },
    ["default_ieining"] = {
      { "iē",  "ié",  "iě",  "iè",  "ie" },
      { "īn",  "ín",  "ǐn",  "ìn",  "in" },
      { "īng", "íng", "ǐng", "ìng", "ing" }
    },
    ["default_ioiuiong"] = {
      { "iō",   "ió",   "iǒ",   "iò",   "io" },
      { "iū",   "iú",   "iǔ",   "iù",   "iu" },
      { "iōng", "ióng", "iǒng", "iòng", "iong" }
    },
    ["default_oouong"] = {
      { "ō",   "ó",   "ǒ",   "ò",   "o" },
      { "ōu",  "óu",  "ǒu",  "òu",  "ou" },
      { "ōng", "óng", "ǒng", "òng", "ong" }
    },
    ["default_uaiui"] = {
      { "uāi", "uái", "uǎi", "uài", "uai" },
      { "uī",  "uí",  "uǐ",  "uì",  "ui" },
      { false, false, false, false, false }
    },
    ["default_uauanuang"] = {
      { "uā",   "uá",   "uǎ",   "uà",   "ua" },
      { "uān",  "uán",  "uǎn",  "uàn",  "uan" },
      { "uāng", "uáng", "uǎng", "uàng", "uang" }
    },
    ["default_unueng"] = {
      { false,  false,  false,  false,  false },
      { "ūn",   "ún",   "ǔn",   "ùn",   "un" },
      { "uēng", "uéng", "uěng", "uèng", "ueng" }
    },
    ["default_uou"] = {
      { "uō",  "uó",  "uǒ",  "uò",  "uo" },
      { false, false, false, false, false },
      { "ū",   "ú",   "ǔ",   "ù",   "u" }
    },
    ["default_v"] = {
      { false, false, false, false, false },
      { false, false, false, false, false },
      { "ǖ",   "ǘ",   "ǚ",   "ǜ",   "ü" }
    },
    ["default_vevn"] = {
      { "üē",  "üé",  "üě",  "üè",  "üe" },
      { "ǖn",  "ǘn",  "ǚn",  "ǜn",  "ün" },
      { false, false, false, false, false }
    },
    ["diaian"] = {
      { "diā",  "diá",  "diǎ",  "dià",  "dia" },
      { "diān", "dián", "diǎn", "diàn", "dian" },
      { false,  false,  false,  false,  false }
    },
    ["dieing"] = {
      { "diē",  "dié",  "diě",  "diè",  "die" },
      { false,  false,  false,  false,  false },
      { "dīng", "díng", "dǐng", "dìng", "ding" }
    },
    ["diiao"] = {
      { false,  false,  false,  false,  false },
      { "dī",   "dí",   "dǐ",   "dì",   "di" },
      { "diāo", "diáo", "diǎo", "diào", "diao" }
    },
    ["diu"] = {
      { false, false, false, false, false },
      { "diū", "diú", "diǔ", "diù", "diu" },
      { false, false, false, false, false }
    },
    ["douong"] = {
      { false,  false,  false,  false,  false },
      { "dōu",  "dóu",  "dǒu",  "dòu",  "dou" },
      { "dōng", "dóng", "dǒng", "dòng", "dong" }
    },
    ["duan"] = {
      { false,  false,  false,  false,  false },
      { "duān", "duán", "duǎn", "duàn", "duan" },
      { false,  false,  false,  false,  false }
    },
    ["dui"] = {
      { false, false, false, false, false },
      { "duī", "duí", "duǐ", "duì", "dui" },
      { false, false, false, false, false }
    },
    ["dun"] = {
      { false, false, false, false, false },
      { "dūn", "dún", "dǔn", "dùn", "dun" },
      { false, false, false, false, false }
    },
    ["duou"] = {
      { "duō", "duó", "duǒ", "duò", "duo" },
      { false, false, false, false, false },
      { "dū",  "dú",  "dǔ",  "dù",  "du" }
    },
    ["eeneng"] = {
      { "ē",   "é",   "ě",   "è",   "e" },
      { "ēn",  false, false, "èn",  "en" },
      { "ēng", false, false, false, "eng" }
    },
    ["eryvan"] = {
      { false,  "ér",   "ěr",   "èr",   "er" },
      { "yuān", "yuán", "yuǎn", "yuàn", "yuan" },
      { false,  false,  false,  false,  false }
    },
    ["faanang"] = {
      { "fā",   "fá",   "fǎ",   "fà",   "fa" },
      { "fān",  "fán",  "fǎn",  "fàn",  "fan" },
      { "fāng", "fáng", "fǎng", "fàng", "fang" }
    },
    ["feiiao"] = {
      { false, false, false, false,  false },
      { "fēi", "féi", "fěi", "fèi",  "fei" },
      { false, false, false, "fiào", "fiao" }
    },
    ["feneng"] = {
      { false,  false,  false,  false,  false },
      { "fēn",  "fén",  "fěn",  "fèn",  "fen" },
      { "fēng", "féng", "fěng", "fèng", "feng" }
    },
    ["foou"] = {
      { "fō",  "fó",  "fǒ",  "fò",  "fo" },
      { "fōu", "fóu", "fǒu", "fòu", "fou" },
      { false, false, false, false, false }
    },
    ["fu"] = {
      { false, false, false, false, false },
      { false, false, false, false, false },
      { "fū",  "fú",  "fǔ",  "fù",  "fu" }
    },
    ["gaanang"] = {
      { "gā",   "gá",   "gǎ",   "gà",   "ga" },
      { "gān",  "gán",  "gǎn",  "gàn",  "gan" },
      { "gāng", "gáng", "gǎng", "gàng", "gang" }
    },
    ["gaieiao"] = {
      { "gāi", "gái", "gǎi", "gài", "gai" },
      { "gēi", "géi", "gěi", "gèi", "gei" },
      { "gāo", "gáo", "gǎo", "gào", "gao" }
    },
    ["geeneng"] = {
      { "gē",   "gé",   "gě",   "gè",   "ge" },
      { "gēn",  "gén",  "gěn",  "gèn",  "gen" },
      { "gēng", "géng", "gěng", "gèng", "geng" }
    },
    ["gouong"] = {
      { false,  false,  false,  false,  false },
      { "gōu",  "góu",  "gǒu",  "gòu",  "gou" },
      { "gōng", "góng", "gǒng", "gòng", "gong" }
    },
    ["guaiui"] = {
      { "guāi", "guái", "guǎi", "guài", "guai" },
      { "guī",  "guí",  "guǐ",  "guì",  "gui" },
      { false,  false,  false,  false,  false }
    },
    ["guauanuang"] = {
      { "guā",   "guá",   "guǎ",   "guà",   "gua" },
      { "guān",  "guán",  "guǎn",  "guàn",  "guan" },
      { "guāng", "guáng", "guǎng", "guàng", "guang" }
    },
    ["gun"] = {
      { false, false, false, false, false },
      { "gūn", "gún", "gǔn", "gùn", "gun" },
      { false, false, false, false, false }
    },
    ["guou"] = {
      { "guō", "guó", "guǒ", "guò", "guo" },
      { false, false, false, false, false },
      { "gū",  "gú",  "gǔ",  "gù",  "gu" }
    },
    ["haanang"] = {
      { "hā",   "há",   "hǎ",   "hà",   "ha" },
      { "hān",  "hán",  "hǎn",  "hàn",  "han" },
      { "hāng", "háng", "hǎng", "hàng", "hang" }
    },
    ["haieiao"] = {
      { "hāi", "hái", "hǎi", "hài", "hai" },
      { "hēi", "héi", "hěi", "hèi", "hei" },
      { "hāo", "háo", "hǎo", "hào", "hao" }
    },
    ["heeneng"] = {
      { "hē",   "hé",   "hě",   "hè",   "he" },
      { "hēn",  "hén",  "hěn",  "hèn",  "hen" },
      { "hēng", "héng", "hěng", "hèng", "heng" }
    },
    ["houong"] = {
      { false,  false,  false,  false,  false },
      { "hōu",  "hóu",  "hǒu",  "hòu",  "hou" },
      { "hōng", "hóng", "hǒng", "hòng", "hong" }
    },
    ["huaiui"] = {
      { "huāi", "huái", "huǎi", "huài", "huai" },
      { "huī",  "huí",  "huǐ",  "huì",  "hui" },
      { false,  false,  false,  false,  false }
    },
    ["huauanuang"] = {
      { "huā",   "huá",   "huǎ",   "huà",   "hua" },
      { "huān",  "huán",  "huǎn",  "huàn",  "huan" },
      { "huāng", "huáng", "huǎng", "huàng", "huang" }
    },
    ["hun"] = {
      { false, false, false, false, false },
      { "hūn", "hún", "hǔn", "hùn", "hun" },
      { false, false, false, false, false }
    },
    ["huou"] = {
      { "huō", "huó", "huǒ", "huò", "huo" },
      { false, false, false, false, false },
      { "hū",  "hú",  "hǔ",  "hù",  "hu" }
    },
    ["jiaianiang"] = {
      { "jiā",   "jiá",   "jiǎ",   "jià",   "jia" },
      { "jiān",  "jián",  "jiǎn",  "jiàn",  "jian" },
      { "jiāng", "jiáng", "jiǎng", "jiàng", "jiang" }
    },
    ["jieining"] = {
      { "jiē",  "jié",  "jiě",  "jiè",  "jie" },
      { "jīn",  "jín",  "jǐn",  "jìn",  "jin" },
      { "jīng", "jíng", "jǐng", "jìng", "jing" }
    },
    ["jiiao"] = {
      { false,  false,  false,  false,  false },
      { "jī",   "jí",   "jǐ",   "jì",   "ji" },
      { "jiāo", "jiáo", "jiǎo", "jiào", "jiao" }
    },
    ["jiuiong"] = {
      { false,   false,   false,   false,   false },
      { "jiū",   "jiú",   "jiǔ",   "jiù",   "jiu" },
      { "jiōng", "jióng", "jiǒng", "jiòng", "jiong" }
    },
    ["jv"] = {
      { false, false, false, false, false },
      { false, false, false, false, false },
      { "jū",  "jú",  "jǔ",  "jù",  "ju" }
    },
    ["jvan"] = {
      { false,  false,  false,  false,  false },
      { "juān", "juán", "juǎn", "juàn", "juan" },
      { false,  false,  false,  false,  false }
    },
    ["jvevn"] = {
      { "juē", "jué", "juě", "juè", "jue" },
      { "jūn", "jún", "jǔn", "jùn", "jun" },
      { false, false, false, false, false }
    },
    ["kaanang"] = {
      { "kā",   "ká",   "kǎ",   "kà",   "ka" },
      { "kān",  "kán",  "kǎn",  "kàn",  "kan" },
      { "kāng", "káng", "kǎng", "kàng", "kang" }
    },
    ["kaieiao"] = {
      { "kāi", "kái", "kǎi", "kài", "kai" },
      { "kēi", "kéi", "kěi", "kèi", "kei" },
      { "kāo", "káo", "kǎo", "kào", "kao" }
    },
    ["keeneng"] = {
      { "kē",   "ké",   "kě",   "kè",   "ke" },
      { "kēn",  "kén",  "kěn",  "kèn",  "ken" },
      { "kēng", "kéng", "kěng", "kèng", "keng" }
    },
    ["kouong"] = {
      { false,  false,  false,  false,  false },
      { "kōu",  "kóu",  "kǒu",  "kòu",  "kou" },
      { "kōng", "kóng", "kǒng", "kòng", "kong" }
    },
    ["kuaiui"] = {
      { "kuāi", "kuái", "kuǎi", "kuài", "kuai" },
      { "kuī",  "kuí",  "kuǐ",  "kuì",  "kui" },
      { false,  false,  false,  false,  false }
    },
    ["kuauanuang"] = {
      { "kuā",   "kuá",   "kuǎ",   "kuà",   "kua" },
      { "kuān",  "kuán",  "kuǎn",  "kuàn",  "kuan" },
      { "kuāng", "kuáng", "kuǎng", "kuàng", "kuang" }
    },
    ["kun"] = {
      { false, false, false, false, false },
      { "kūn", "kún", "kǔn", "kùn", "kun" },
      { false, false, false, false, false }
    },
    ["kuou"] = {
      { "kuō", "kuó", "kuǒ", "kuò", "kuo" },
      { false, false, false, false, false },
      { "kū",  "kú",  "kǔ",  "kù",  "ku" }
    },
    ["laanang"] = {
      { "lā",   "lá",   "lǎ",   "là",   "la" },
      { "lān",  "lán",  "lǎn",  "làn",  "lan" },
      { "lāng", "láng", "lǎng", "làng", "lang" }
    },
    ["laieiao"] = {
      { "lāi", "lái", "lǎi", "lài", "lai" },
      { "lēi", "léi", "lěi", "lèi", "lei" },
      { "lāo", "láo", "lǎo", "lào", "lao" }
    },
    ["leeneng"] = {
      { "lē",   "lé",   "lě",   "lè",   "le" },
      { "lēn",  "lén",  "lěn",  "lèn",  "len" },
      { "lēng", "léng", "lěng", "lèng", "leng" }
    },
    ["liaianiang"] = {
      { "liā",   "liá",   "liǎ",   "lià",   "lia" },
      { "liān",  "lián",  "liǎn",  "liàn",  "lian" },
      { "liāng", "liáng", "liǎng", "liàng", "liang" }
    },
    ["lieining"] = {
      { "liē",  "lié",  "liě",  "liè",  "lie" },
      { "līn",  "lín",  "lǐn",  "lìn",  "lin" },
      { "līng", "líng", "lǐng", "lìng", "ling" }
    },
    ["liiao"] = {
      { false,  false,  false,  false,  false },
      { "lī",   "lí",   "lǐ",   "lì",   "li" },
      { "liāo", "liáo", "liǎo", "liào", "liao" }
    },
    ["liu"] = {
      { false, false, false, false, false },
      { "liū", "liú", "liǔ", "liù", "liu" },
      { false, false, false, false, false }
    },
    ["loouong"] = {
      { "lō",   "ló",   "lǒ",   "lò",   "lo" },
      { "lōu",  "lóu",  "lǒu",  "lòu",  "lou" },
      { "lōng", "lóng", "lǒng", "lòng", "long" }
    },
    ["luan"] = {
      { false,  false,  false,  false,  false },
      { "luān", "luán", "luǎn", "luàn", "luan" },
      { false,  false,  false,  false,  false }
    },
    ["lun"] = {
      { false, false, false, false, false },
      { "lūn", "lún", "lǔn", "lùn", "lun" },
      { false, false, false, false, false }
    },
    ["luou"] = {
      { "luō", "luó", "luǒ", "luò", "luo" },
      { false, false, false, false, false },
      { "lū",  "lú",  "lǔ",  "lù",  "lu" }
    },
    ["lv"] = {
      { false, false, false, false, false },
      { false, false, false, false, false },
      { "lǖ",  "lǘ",  "lǚ",  "lǜ",  "lü" }
    },
    ["lve"] = {
      { "lüē", "lüé", "lüě", "lüè", "lüe" },
      { false, false, false, false, false },
      { false, false, false, false, false }
    },
    ["maanang"] = {
      { "mā",   "má",   "mǎ",   "mà",   "ma" },
      { "mān",  "mán",  "mǎn",  "màn",  "man" },
      { "māng", "máng", "mǎng", "màng", "mang" }
    },
    ["maieiao"] = {
      { "māi", "mái", "mǎi", "mài", "mai" },
      { "mēi", "méi", "měi", "mèi", "mei" },
      { "māo", "máo", "mǎo", "mào", "mao" }
    },
    ["meeneng"] = {
      { "mē",   "mé",   "mě",   "mè",   "me" },
      { "mēn",  "mén",  "měn",  "mèn",  "men" },
      { "mēng", "méng", "měng", "mèng", "meng" }
    },
    ["mian"] = {
      { false,  false,  false,  false,  false },
      { "miān", "mián", "miǎn", "miàn", "mian" },
      { false,  false,  false,  false,  false }
    },
    ["mieining"] = {
      { "miē",  "mié",  "miě",  "miè",  "mie" },
      { "mīn",  "mín",  "mǐn",  "mìn",  "min" },
      { "mīng", "míng", "mǐng", "mìng", "ming" }
    },
    ["miiao"] = {
      { false,  false,  false,  false,  false },
      { "mī",   "mí",   "mǐ",   "mì",   "mi" },
      { "miāo", "miáo", "miǎo", "miào", "miao" }
    },
    ["miu"] = {
      { false, false, false, false, false },
      { "miū", "miú", "miǔ", "miù", "miu" },
      { false, false, false, false, false }
    },
    ["moou"] = {
      { "mō",  "mó",  "mǒ",  "mò",  "mo" },
      { "mōu", "móu", "mǒu", "mòu", "mou" },
      { false, false, false, false, false }
    },
    ["musiu"] = {
      { false, false, false, false, false },
      { "siū", "siú", "siǔ", "siù", "siu" },
      { "mū",  "mú",  "mǔ",  "mù",  "mu" }
    },
    ["naanang"] = {
      { "nā",   "ná",   "nǎ",   "nà",   "na" },
      { "nān",  "nán",  "nǎn",  "nàn",  "nan" },
      { "nāng", "náng", "nǎng", "nàng", "nang" }
    },
    ["naieiao"] = {
      { "nāi", "nái", "nǎi", "nài", "nai" },
      { "nēi", "néi", "něi", "nèi", "nei" },
      { "nāo", "náo", "nǎo", "nào", "nao" }
    },
    ["neeneng"] = {
      { "nē",   "né",   "ně",   "nè",   "ne" },
      { "nēn",  "nén",  "něn",  "nèn",  "nen" },
      { "nēng", "néng", "něng", "nèng", "neng" }
    },
    ["niaianiang"] = {
      { "niā",   "niá",   "niǎ",   "nià",   "nia" },
      { "niān",  "nián",  "niǎn",  "niàn",  "nian" },
      { "niāng", "niáng", "niǎng", "niàng", "niang" }
    },
    ["nieining"] = {
      { "niē",  "nié",  "niě",  "niè",  "nie" },
      { "nīn",  "nín",  "nǐn",  "nìn",  "nin" },
      { "nīng", "níng", "nǐng", "nìng", "ning" }
    },
    ["niiao"] = {
      { false,  false,  false,  false,  false },
      { "nī",   "ní",   "nǐ",   "nì",   "ni" },
      { "niāo", "niáo", "niǎo", "niào", "niao" }
    },
    ["niu"] = {
      { false, false, false, false, false },
      { "niū", "niú", "niǔ", "niù", "niu" },
      { false, false, false, false, false }
    },
    ["nouong"] = {
      { "nōu",  "nóu",  "nǒu",  "nòu",  "nou" },
      { false,  false,  false,  false,  false },
      { "nōng", "nóng", "nǒng", "nòng", "nong" }
    },
    ["nuan"] = {
      { false,  false,  false,  false,  false },
      { "nuān", "nuán", "nuǎn", "nuàn", "nuan" },
      { false,  false,  false,  false,  false }
    },
    ["nun"] = {
      { false, false, false, false, false },
      { "nūn", "nún", "nǔn", "nùn", "nun" },
      { false, false, false, false, false }
    },
    ["nuou"] = {
      { "nuō", "nuó", "nuǒ", "nuò", "nuo" },
      { false, false, false, false, false },
      { "nū",  "nú",  "nǔ",  "nù",  "nu" }
    },
    ["nv"] = {
      { false, false, false, false, false },
      { false, false, false, false, false },
      { "nǖ",  "nǘ",  "nǚ",  "nǜ",  "nü" }
    },
    ["nve"] = {
      { "nüē", "nüé", "nüě", "nüè", "nüe" },
      { false, false, false, false, false },
      { false, false, false, false, false }
    },
    ["oou"] = {
      { "ō",   "ó",   "ǒ",   "ò",   "o" },
      { "ōu",  "óu",  "ǒu",  "òu",  "ou" },
      { false, false, false, false, false }
    },
    ["paanang"] = {
      { "pā",   "pá",   "pǎ",   "pà",   "pa" },
      { "pān",  "pán",  "pǎn",  "pàn",  "pan" },
      { "pāng", "páng", "pǎng", "pàng", "pang" }
    },
    ["paieiao"] = {
      { "pāi", "pái", "pǎi", "pài", "pai" },
      { "pēi", "péi", "pěi", "pèi", "pei" },
      { "pāo", "páo", "pǎo", "pào", "pao" }
    },
    ["peneng"] = {
      { false,  false,  false,  false,  false },
      { "pēn",  "pén",  "pěn",  "pèn",  "pen" },
      { "pēng", "péng", "pěng", "pèng", "peng" }
    },
    ["pian"] = {
      { false,  false,  false,  false,  false },
      { "piān", "pián", "piǎn", "piàn", "pian" },
      { false,  false,  false,  false,  false }
    },
    ["pieining"] = {
      { "piē",  "pié",  "piě",  "piè",  "pie" },
      { "pīn",  "pín",  "pǐn",  "pìn",  "pin" },
      { "pīng", "píng", "pǐng", "pìng", "ping" }
    },
    ["piiao"] = {
      { false,  false,  false,  false,  false },
      { "pī",   "pí",   "pǐ",   "pì",   "pi" },
      { "piāo", "piáo", "piǎo", "piào", "piao" }
    },
    ["poou"] = {
      { "pō",  "pó",  "pǒ",  "pò",  "po" },
      { "pōu", "póu", "pǒu", "pòu", "pou" },
      { false, false, false, false, false }
    },
    ["puciu"] = {
      { false, false, false, false, false },
      { "ciū", "ciú", "ciǔ", "ciù", "ciu" },
      { "pū",  "pú",  "pǔ",  "pù",  "pu" }
    },
    ["qiaianiang"] = {
      { "qiā",   "qiá",   "qiǎ",   "qià",   "qia" },
      { "qiān",  "qián",  "qiǎn",  "qiàn",  "qian" },
      { "qiāng", "qiáng", "qiǎng", "qiàng", "qiang" }
    },
    ["qieining"] = {
      { "qiē",  "qié",  "qiě",  "qiè",  "qie" },
      { "qīn",  "qín",  "qǐn",  "qìn",  "qin" },
      { "qīng", "qíng", "qǐng", "qìng", "qing" }
    },
    ["qiiao"] = {
      { false,  false,  false,  false,  false },
      { "qī",   "qí",   "qǐ",   "qì",   "qi" },
      { "qiāo", "qiáo", "qiǎo", "qiào", "qiao" }
    },
    ["qiuiong"] = {
      { false,   false,   false,   false,   false },
      { "qiū",   "qiú",   "qiǔ",   "qiù",   "qiu" },
      { "qiōng", "qióng", "qiǒng", "qiòng", "qiong" }
    },
    ["qv"] = {
      { false, false, false, false, false },
      { false, false, false, false, false },
      { "qū",  "qú",  "qǔ",  "qù",  "qu" }
    },
    ["qvan"] = {
      { false,  false,  false,  false,  false },
      { "quān", "quán", "quǎn", "quàn", "quan" },
      { false,  false,  false,  false,  false }
    },
    ["qvevn"] = {
      { "quē", "qué", "quě", "què", "que" },
      { "qūn", "qún", "qǔn", "qùn", "qun" },
      { false, false, false, false, false }
    },
    ["ranang"] = {
      { false,  false,  false,  false,  false },
      { "rān",  "rán",  "rǎn",  "ràn",  "ran" },
      { "rāng", "ráng", "rǎng", "ràng", "rang" }
    },
    ["rao"] = {
      { false, false, false, false, false },
      { false, false, false, false, false },
      { "rāo", "ráo", "rǎo", "rào", "rao" }
    },
    ["reeneng"] = {
      { "rē",   "ré",   "rě",   "rè",   "re" },
      { "rēn",  "rén",  "rěn",  "rèn",  "ren" },
      { "rēng", "réng", "rěng", "rèng", "reng" }
    },
    ["riouong"] = {
      { "rī",   "rí",   "rǐ",   "rì",   "ri" },
      { "rōu",  "róu",  "rǒu",  "ròu",  "rou" },
      { "rōng", "róng", "rǒng", "ròng", "rong" }
    },
    ["ruauan"] = {
      { "ruā",  "ruá",  "ruǎ",  "ruà",  "rua" },
      { "ruān", "ruán", "ruǎn", "ruàn", "ruan" },
      { false,  false,  false,  false,  false }
    },
    ["rui"] = {
      { false, false, false, false, false },
      { "ruī", "ruí", "ruǐ", "ruì", "rui" },
      { false, false, false, false, false }
    },
    ["run"] = {
      { false, false, false, false, false },
      { "rūn", "rún", "rǔn", "rùn", "run" },
      { false, false, false, false, false }
    },
    ["ruou"] = {
      { "ruō", "ruó", "ruǒ", "ruò", "ruo" },
      { false, false, false, false, false },
      { "rū",  "rú",  "rǔ",  "rù",  "ru" }
    },
    ["saanang"] = {
      { "sā",   "sá",   "sǎ",   "sà",   "sa" },
      { "sān",  "sán",  "sǎn",  "sàn",  "san" },
      { "sāng", "sáng", "sǎng", "sàng", "sang" }
    },
    ["saiao"] = {
      { "sāi", "sái", "sǎi", "sài", "sai" },
      { false, false, false, false, false },
      { "sāo", "sáo", "sǎo", "sào", "sao" }
    },
    ["seeneng"] = {
      { "sē",   "sé",   "sě",   "sè",   "se" },
      { "sēn",  "sén",  "sěn",  "sèn",  "sen" },
      { "sēng", "séng", "sěng", "sèng", "seng" }
    },
    ["shaanang"] = {
      { "shā",   "shá",   "shǎ",   "shà",   "sha" },
      { "shān",  "shán",  "shǎn",  "shàn",  "shan" },
      { "shāng", "sháng", "shǎng", "shàng", "shang" }
    },
    ["shaieiao"] = {
      { "shāi", "shái", "shǎi", "shài", "shai" },
      { "shēi", "shéi", "shěi", "shèi", "shei" },
      { "shāo", "sháo", "shǎo", "shào", "shao" }
    },
    ["sheeneng"] = {
      { "shē",   "shé",   "shě",   "shè",   "she" },
      { "shēn",  "shén",  "shěn",  "shèn",  "shen" },
      { "shēng", "shéng", "shěng", "shèng", "sheng" }
    },
    ["shiou"] = {
      { "shī",  "shí",  "shǐ",  "shì",  "shi" },
      { "shōu", "shóu", "shǒu", "shòu", "shou" },
      { false,  false,  false,  false,  false }
    },
    ["shuaiui"] = {
      { "shuāi", "shuái", "shuǎi", "shuài", "shuai" },
      { "shuī",  "shuí",  "shuǐ",  "shuì",  "shui" },
      { false,   false,   false,   false,   false }
    },
    ["shuauanuang"] = {
      { "shuā",   "shuá",   "shuǎ",   "shuà",   "shua" },
      { "shuān",  "shuán",  "shuǎn",  "shuàn",  "shuan" },
      { "shuāng", "shuáng", "shuǎng", "shuàng", "shuang" }
    },
    ["shun"] = {
      { false,  false,  false,  false,  false },
      { "shūn", "shún", "shǔn", "shùn", "shun" },
      { false,  false,  false,  false,  false }
    },
    ["shuou"] = {
      { "shuō", "shuó", "shuǒ", "shuò", "shuo" },
      { false,  false,  false,  false,  false },
      { "shū",  "shú",  "shǔ",  "shù",  "shu" }
    },
    ["siouong"] = {
      { "sī",   "sí",   "sǐ",   "sì",   "si" },
      { "sōu",  "sóu",  "sǒu",  "sòu",  "sou" },
      { "sōng", "sóng", "sǒng", "sòng", "song" }
    },
    ["suan"] = {
      { false,  false,  false,  false,  false },
      { "suān", "suán", "suǎn", "suàn", "suan" },
      { false,  false,  false,  false,  false }
    },
    ["sun"] = {
      { false, false, false, false, false },
      { "sūn", "sún", "sǔn", "sùn", "sun" },
      { false, false, false, false, false }
    },
    ["suouiu"] = {
      { "suō", "suó", "suǒ", "suò", "suo" },
      { "suī", "suí", "suǐ", "suì", "sui" },
      { "sū",  "sú",  "sǔ",  "sù",  "su" }
    },
    ["siianiang"] = {
      { "siā",   "siá",   "siǎ",   "sià",   "sia" },
      { "siān",  "sián",  "siǎn",  "siàn",  "sian" },
      { "siāng", "siáng", "siǎng", "siàng", "siang" }
    },
    ["siieining"] = {
      { "siē",  "sié",  "siě",  "siè",  "sie" },
      { "sīn",  "sín",  "sǐn",  "sìn",  "sin" },
      { "sīng", "síng", "sǐng", "sìng", "sing" }
    },
    ["siiiao"] = {
      { false,  false,  false,  false,  false },
      { "siī",  "sií",  "siǐ",  "siì",  "sii" },
      { "siāo", "siáo", "siǎo", "siào", "siao" }
    },
    ["sivevn"] = {
      { "süē", "süé", "süě", "süè", "süe" },
      { "sǖn", "sǘn", "sǚn", "sǜn", "sün" },
      { false, false, false, false, false }
    },
    ["sv"] = {
      { false, false, false, false, false },
      { false, false, false, false, false },
      { "sǖ",  "sǘ",  "sǚ",  "sǜ",  "sü" }
    },
    ["svan"] = {
      { false,  false,  false,  false,  false },
      { "süān", "süán", "süǎn", "süàn", "süan" },
      { false,  false,  false,  false,  false }
    },
    ["taanang"] = {
      { "tā",   "tá",   "tǎ",   "tà",   "ta" },
      { "tān",  "tán",  "tǎn",  "tàn",  "tan" },
      { "tāng", "táng", "tǎng", "tàng", "tang" }
    },
    ["taieiao"] = {
      { "tāi", "tái", "tǎi", "tài", "tai" },
      { "tēi", "téi", "těi", "tèi", "tei" },
      { "tāo", "táo", "tǎo", "tào", "tao" }
    },
    ["teeng"] = {
      { "tē",   "té",   "tě",   "tè",   "te" },
      { false,  false,  false,  false,  false },
      { "tēng", "téng", "těng", "tèng", "teng" }
    },
    ["tian"] = {
      { false,  false,  false,  false,  false },
      { "tiān", "tián", "tiǎn", "tiàn", "tian" },
      { false,  false,  false,  false,  false }
    },
    ["tieing"] = {
      { "tiē",  "tié",  "tiě",  "tiè",  "tie" },
      { false,  false,  false,  false,  false },
      { "tīng", "tíng", "tǐng", "tìng", "ting" }
    },
    ["tiiao"] = {
      { false,  false,  false,  false,  false },
      { "tī",   "tí",   "tǐ",   "tì",   "ti" },
      { "tiāo", "tiáo", "tiǎo", "tiào", "tiao" }
    },
    ["touong"] = {
      { false,  false,  false,  false,  false },
      { "tōu",  "tóu",  "tǒu",  "tòu",  "tou" },
      { "tōng", "tóng", "tǒng", "tòng", "tong" }
    },
    ["tuan"] = {
      { false,  false,  false,  false,  false },
      { "tuān", "tuán", "tuǎn", "tuàn", "tuan" },
      { false,  false,  false,  false,  false }
    },
    ["tui"] = {
      { false, false, false, false, false },
      { "tuī", "tuí", "tuǐ", "tuì", "tui" },
      { false, false, false, false, false }
    },
    ["tun"] = {
      { false, false, false, false, false },
      { "tūn", "tún", "tǔn", "tùn", "tun" },
      { false, false, false, false, false }
    },
    ["tuou"] = {
      { "tuō", "tuó", "tuǒ", "tuò", "tuo" },
      { false, false, false, false, false },
      { "tū",  "tú",  "tǔ",  "tù",  "tu" }
    },
    ["waanang"] = {
      { "wā",   "wá",   "wǎ",   "wà",   "wa" },
      { "wān",  "wán",  "wǎn",  "wàn",  "wan" },
      { "wāng", "wáng", "wǎng", "wàng", "wang" }
    },
    ["waiei"] = {
      { "wāi", "wái", "wǎi", "wài", "wai" },
      { "wēi", "wéi", "wěi", "wèi", "wei" },
      { false, false, false, false, false }
    },
    ["weneng"] = {
      { false,  false,  false,  false,  false },
      { "wēn",  "wén",  "wěn",  "wèn",  "wen" },
      { "wēng", "wéng", "wěng", "wèng", "weng" }
    },
    ["wou"] = {
      { "wō",  "wó",  "wǒ",  "wò",  "wo" },
      { false, false, false, false, false },
      { "wū",  "wú",  "wǔ",  "wù",  "wu" }
    },
    ["xiaianiang"] = {
      { "xiā",   "xiá",   "xiǎ",   "xià",   "xia" },
      { "xiān",  "xián",  "xiǎn",  "xiàn",  "xian" },
      { "xiāng", "xiáng", "xiǎng", "xiàng", "xiang" }
    },
    ["xieining"] = {
      { "xiē",  "xié",  "xiě",  "xiè",  "xie" },
      { "xīn",  "xín",  "xǐn",  "xìn",  "xin" },
      { "xīng", "xíng", "xǐng", "xìng", "xing" }
    },
    ["xiiao"] = {
      { false,  false,  false,  false,  false },
      { "xī",   "xí",   "xǐ",   "xì",   "xi" },
      { "xiāo", "xiáo", "xiǎo", "xiào", "xiao" }
    },
    ["xiuiong"] = {
      { false,   false,   false,   false,   false },
      { "xiū",   "xiú",   "xiǔ",   "xiù",   "xiu" },
      { "xiōng", "xióng", "xiǒng", "xiòng", "xiong" }
    },
    ["xv"] = {
      { false, false, false, false, false },
      { false, false, false, false, false },
      { "xū",  "xú",  "xǔ",  "xù",  "xu" }
    },
    ["xvan"] = {
      { false,  false,  false,  false,  false },
      { "xuān", "xuán", "xuǎn", "xuàn", "xuan" },
      { false,  false,  false,  false,  false }
    },
    ["xvevn"] = {
      { "xuē", "xué", "xuě", "xuè", "xue" },
      { "xūn", "xún", "xǔn", "xùn", "xun" },
      { false, false, false, false, false }
    },
    ["yaanang"] = {
      { "yā",   "yá",   "yǎ",   "yà",   "ya" },
      { "yān",  "yán",  "yǎn",  "yàn",  "yan" },
      { "yāng", "yáng", "yǎng", "yàng", "yang" }
    },
    ["yeining"] = {
      { "yē",   "yé",   "yě",   "yè",   "ye" },
      { "yīn",  "yín",  "yǐn",  "yìn",  "yin" },
      { "yīng", "yíng", "yǐng", "yìng", "ying" }
    },
    ["yiao"] = {
      { false, false, false, false, false },
      { "yī",  "yí",  "yǐ",  "yì",  "yi" },
      { "yāo", "yáo", "yǎo", "yào", "yao" }
    },
    ["yoouong"] = {
      { "yō",   "yó",   "yǒ",   "yò",   "yo" },
      { "yōu",  "yóu",  "yǒu",  "yòu",  "you" },
      { "yōng", "yóng", "yǒng", "yòng", "yong" }
    },
    ["yv"] = {
      { false, false, false, false, false },
      { false, false, false, false, false },
      { "yū",  "yú",  "yǔ",  "yù",  "yu" }
    },
    ["yvevn"] = {
      { "yuē", "yué", "yuě", "yuè", "yue" },
      { "yūn", "yún", "yǔn", "yùn", "yun" },
      { false, false, false, false, false }
    },
    ["zaanang"] = {
      { "zā",   "zá",   "zǎ",   "zà",   "za" },
      { "zān",  "zán",  "zǎn",  "zàn",  "zan" },
      { "zāng", "záng", "zǎng", "zàng", "zang" }
    },
    ["zaieiao"] = {
      { "zāi", "zái", "zǎi", "zài", "zai" },
      { "zēi", "zéi", "zěi", "zèi", "zei" },
      { "zāo", "záo", "zǎo", "zào", "zao" }
    },
    ["zeeneng"] = {
      { "zē",   "zé",   "zě",   "zè",   "ze" },
      { "zēn",  "zén",  "zěn",  "zèn",  "zen" },
      { "zēng", "zéng", "zěng", "zèng", "zeng" }
    },
    ["zhaanang"] = {
      { "zhā",   "zhá",   "zhǎ",   "zhà",   "zha" },
      { "zhān",  "zhán",  "zhǎn",  "zhàn",  "zhan" },
      { "zhāng", "zháng", "zhǎng", "zhàng", "zhang" }
    },
    ["zhaieiao"] = {
      { "zhāi", "zhái", "zhǎi", "zhài", "zhai" },
      { "zhēi", "zhéi", "zhěi", "zhèi", "zhei" },
      { "zhāo", "zháo", "zhǎo", "zhào", "zhao" }
    },
    ["zheeneng"] = {
      { "zhē",   "zhé",   "zhě",   "zhè",   "zhe" },
      { "zhēn",  "zhén",  "zhěn",  "zhèn",  "zhen" },
      { "zhēng", "zhéng", "zhěng", "zhèng", "zheng" }
    },
    ["zhiouong"] = {
      { "zhī",   "zhí",   "zhǐ",   "zhì",   "zhi" },
      { "zhōu",  "zhóu",  "zhǒu",  "zhòu",  "zhou" },
      { "zhōng", "zhóng", "zhǒng", "zhòng", "zhong" }
    },
    ["zhuaiui"] = {
      { "zhuāi", "zhuái", "zhuǎi", "zhuài", "zhuai" },
      { "zhuī",  "zhuí",  "zhuǐ",  "zhuì",  "zhui" },
      { false,   false,   false,   false,   false }
    },
    ["zhuauanuang"] = {
      { "zhuā",   "zhuá",   "zhuǎ",   "zhuà",   "zhua" },
      { "zhuān",  "zhuán",  "zhuǎn",  "zhuàn",  "zhuan" },
      { "zhuāng", "zhuáng", "zhuǎng", "zhuàng", "zhuang" }
    },
    ["zhun"] = {
      { false,  false,  false,  false,  false },
      { "zhūn", "zhún", "zhǔn", "zhùn", "zhun" },
      { false,  false,  false,  false,  false }
    },
    ["zhuou"] = {
      { "zhuō", "zhuó", "zhuǒ", "zhuò", "zhuo" },
      { false,  false,  false,  false,  false },
      { "zhū",  "zhú",  "zhǔ",  "zhù",  "zhu" }
    },
    ["ziouong"] = {
      { "zī",   "zí",   "zǐ",   "zì",   "zi" },
      { "zōu",  "zóu",  "zǒu",  "zòu",  "zou" },
      { "zōng", "zóng", "zǒng", "zòng", "zong" }
    },
    ["zuan"] = {
      { false,  false,  false,  false,  false },
      { "zuān", "zuán", "zuǎn", "zuàn", "zuan" },
      { false,  false,  false,  false,  false }
    },
    ["zun"] = {
      { false, false, false, false, false },
      { "zūn", "zún", "zǔn", "zùn", "zun" },
      { false, false, false, false, false }
    },
    ["zuouiu"] = {
      { "zuō", "zuó", "zuǒ", "zuò", "zuo" },
      { "zuī", "zuí", "zuǐ", "zuì", "zui" },
      { "zū",  "zú",  "zǔ",  "zù",  "zu" }
    },
    ["ziianiang"] = {
      { "ziā",   "ziá",   "ziǎ",   "zià",   "zia" },
      { "ziān",  "zián",  "ziǎn",  "ziàn",  "zian" },
      { "ziāng", "ziáng", "ziǎng", "ziàng", "ziang" }
    },
    ["ziieining"] = {
      { "ziē",  "zié",  "ziě",  "ziè",  "zie" },
      { "zīn",  "zín",  "zǐn",  "zìn",  "zin" },
      { "zīng", "zíng", "zǐng", "zìng", "zing" }
    },
    ["ziiiao"] = {
      { false,  false,  false,  false,  false },
      { "ziī",  "zií",  "ziǐ",  "ziì",  "zii" },
      { "ziāo", "ziáo", "ziǎo", "ziào", "ziao" }
    },
    ["zivevn"] = {
      { "züē", "züé", "züě", "züè", "züe" },
      { "zǖn", "zǘn", "zǚn", "zǜn", "zün" },
      { false, false, false, false, false }
    },
    ["zv"] = {
      { false, false, false, false, false },
      { false, false, false, false, false },
      { "zǖ",  "zǘ",  "zǚ",  "zǜ",  "zü" }
    },
    ["zvan"] = {
      { false,  false,  false,  false,  false },
      { "züān", "züán", "züǎn", "züàn", "züan" },
      { false,  false,  false,  false,  false }
    }
  }
}
