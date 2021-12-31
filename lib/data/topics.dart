import '../models/topic_item.dart';

var topicList = [
  TopicItem(
      "北京区", "地下通衢肇始燕，铁流暗涌古城垣。北畅南达东西贯，京都旧貌换新颜。", "beijing.svg", 7, "Beijing"),
  TopicItem("天津区", "跨越海河津门，连接新区古镇，通达京都江淮，品味公交百年，感受城轨脉动。", "tianjin.svg", 6,
      "Tianjin"),
  TopicItem(
      "上海区", "浦江两岸齐飞腾，城厢南北共繁盛；上海，因你努力而精彩。", "shanghai.svg", 8, "Shanghai"),
  TopicItem(
      "广州区", "上班、落班，地铁带你返工放工。地下铁嘅故事就喺呢度发生。", "guangzhou.svg", 23, "Guangzhou"),
  TopicItem("长春区", "长春区版块介绍征集中，欢迎投稿。", "changchun.svg", 40, "Changchun"),
  TopicItem("大连区", "大连地铁版块，介绍征集中，欢迎投稿。", "dalian.svg", 41, "Dalian"),
  TopicItem(
      "武汉区", "长江汉水分三镇，楚天大地展宏图，遁地铁龙潜南北，巍巍江城遍通途。", "wuhan.svg", 39, "Wuhan"),
  TopicItem("重庆区", "观两江品山城神韵，登缙云感雾都风华。居蜀道享轨道便捷，立西南叹重庆雄起。", "chongqing.svg", 38,
      "Chongqing"),
  TopicItem("深圳区", "享罗宝快捷，乘蛇口舒适，坐龙岗欢乐，拥龙华便利，试环中悠然，爱鹏城地铁。", "shenzhen.svg", 24,
      "Shenzhen"),
  TopicItem("南京区", "虎踞龙蟠，六朝遗韵；金陵地铁，闪耀古都。", "nanjing.svg", 22, "Nanjing"),
  TopicItem(
      "成都区", "九天开出一成都，万户千门入画图。飞云流彩织锦绣，生活一脉乐悠悠。", "chengdu.svg", 53, "Chengdu"),
  TopicItem("沈阳区", "沈阳地铁，乐享都市新生活！", "shenyang.svg", 50, "Shenyang"),
  TopicItem("佛山区", "穿越千年美丽，相约动感佛山。", "foshan.svg", 56, "Foshan"),
  TopicItem("西安区", "一朝步入西安，一日读懂千年。", "xian.svg", 54, "Xiaan"),
  TopicItem("苏州区", "山水地堑园林重镇，轨道穿越水城古今。", "suzhou.svg", 51, "Suzhou"),
  TopicItem("昆明区", "昆明区板块介绍征集中，欢迎投稿。", "kunming.svg", 70, "Kunming"),
  TopicItem(
      "杭州区", "畅行城市山林，串联钱塘古今，云汇科创新风，轨通吴越大地。", "hangzhou.svg", 52, "Hangzhou"),
  TopicItem("哈尔滨区", "哈尔滨地铁版块，介绍征集中，欢迎投稿。", "harbin.svg", 55, "Harbin"),
  TopicItem("郑州区", "郑州地铁讨论区", "zhengzhou.svg", 64, "Zhengzhou"),
  TopicItem("长沙区", "长沙地铁讨论区，版块介绍征集中，欢迎投稿", "changsha.svg", 67, "Changsha"),
  TopicItem("宁波区", "宁波地铁版块，介绍征集中，欢迎投稿。", "ningbo.svg", 65, "Ningbo"),
  TopicItem("无锡区", "无锡地铁版块，介绍征集中，欢迎投稿。", "wuxi.svg", 68, "Wuxi"),
  TopicItem("青岛区", "青岛地铁论坛", "qingdao.svg", 66, "Qingdao"),
  TopicItem("南昌区", "南昌地铁论坛", "nanchang.svg", 71, "Nanchang"),
  TopicItem("福州区", "福州轨道交通讨论区", "fuzhou.svg", 72, "Fuzhou"),
  TopicItem("东莞区", "东莞轨道交通讨论区", "dongguan.svg", 75, "Dongguan"),
  TopicItem("南宁区", "南宁轨道交通讨论区", "nanning.svg", 73, "Nanning"),
  TopicItem("合肥区", "合肥轨道交通讨论区", "hefei.svg", 74, "Hefei"),
  TopicItem("石家庄区", "石家庄轨道交通讨论区", "shijiazhuang.svg", 140, "Shijiazhuang"),
  TopicItem("贵阳区", "贵阳轨道交通讨论区", "guiyang.svg", 76, "Guiyang"),
  TopicItem("厦门区", "厦门轨道交通讨论区", "xiamen.svg", 77, "Xiamen"),
  TopicItem("乌鲁木齐区", "乌鲁木齐轨道交通讨论区", "urumqi.svg", 143, "Urumqi"),
  TopicItem("温州区", "温州轨道交通讨论版块。", "wenzhou.svg", 142, "Wenzhou"),
  TopicItem("济南区", "济南轨道交通讨论版块。", "jinan.svg", 148, "Jinan"),
  TopicItem("兰州区", "兰州轨道交通讨论版块。", "lanzhou.svg", 78, "Lanzhou"),
  TopicItem("常州区", "常州轨道交通讨论版块。", "changzhou.svg", 48, "Changzhou"),
  TopicItem("徐州区", "徐州轨道交通讨论版块。", "xuzhou.svg", 144, "Xuzhou"),
  TopicItem("呼和浩特", "呼和浩特轨道交通讨论版块。", "hohhot.svg", 151, "Huhhot"),
  TopicItem(
      "香港", "地下铁碰着她好比心中爱神进入梦，地下铁再遇她沉默对望车厢中。", "hongkong.svg", 28, "Hongkong"),
  TopicItem("澳门", "澳门轨道交通讨论区", "macau.svg", 79, "Macau"),
  TopicItem("台湾", "连结每一处繁华，连结每一处幸福。遇见未来，美丽正在发生。", "taiwan.svg", 36, "Taipei"),
  TopicItem("海外", "国外地铁列车、车站、路线、贴图讨论与资料分享。", "oversea.svg", 47, "Sydney"),
  TopicItem("综合区", "国内地铁轻轨建设中城市以及地铁轻轨规划中城市讨论区。", "comprehensive.svg", 37, ""),
  TopicItem("轨道收藏", "轨道交通模型、磁卡、票据等周边产品收藏交流区。", "stamp.svg", 33, ""),
  TopicItem("都市风情", "轨道交通城市风情生活展示区。", "park.svg", 16, ""),
  TopicItem("都市地产", "地铁周边房地产讨论及地铁建设动迁信息发布。", "building.svg", 31, ""),
  TopicItem("地铁美食", "全国地铁城市地铁美食发布分享区。", "food.svg", 15, ""),
  TopicItem("交易市场", "族友专属交易区，轨道交通周边产品及其他闲置物品。（商家绕道）", "market.svg", 60, ""),
  TopicItem("轨交游戏", "城市及轨道交通类游戏讨论区", "game.svg", 145, ""),
  TopicItem("站前广场", "闲谈杂侃版块，严禁灌水。", "message.svg", 21, ""),
  TopicItem("城际铁路", "城际高速铁路路线、特色车站、国内外交通枢纽及转乘车站、城际铁路选线、城际铁路列车站。",
      "high_speed_railway.svg", 46, ""),
  TopicItem("轨道知识", "地铁和轨道交通相关技术、知识发表讨论区。", "book.svg", 43, ""),
  TopicItem("意见建议", "意见建议、反馈中心", "feedback.svg", 18, ""),
  TopicItem("站务公告", "站务公告中心", "announcement.svg", 17, "")
];

var recommendedTopicList = [
  topicList[0],
  topicList[1],
  topicList[2],
  topicList[3],
  topicList[8],
  topicList[10],
  topicList[14],
  topicList[53],
  topicList[49]
];
