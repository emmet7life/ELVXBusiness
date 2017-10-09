//
//  ELAreaCode.swift
//  ELVXBusiness
//
//  Created by 陈建立 on 2017/9/13.
//  Copyright © 2017年 emmet7life. All rights reserved.
//

import Foundation

/// 区号
public enum ELAreaCode {
    // 四个直辖市
//    case 北京市 = 10
//    case 上海市 = 21
//    case 天津市 = 22
//    case 重庆市 = 23
//
//    // 两个特别行政区
//    case 香港 = 852
//    case 澳门 = 853
//
//    // 23个省份城市
//
//    // 河北省
//    case 邯郸市 = 310
//    case 石家庄 = 311
//    case 保定市 = 312
//    case 张家口 = 313
//    case 承德市 = 314
//    case 唐山市 = 315
//    case 廊坊市 = 316
//    case 沧州市 = 317
//    case 衡水市 = 318
//    case 邢台市 = 319
//    case 秦皇岛 = 335
//
//    // 浙江省
//    case 衢州市 = 570
//    case 杭州市 = 571
//    case 湖州市 = 572
//    case 嘉兴市 = 573
//    case 宁波市 = 574
//    case 绍兴市 = 575
//    case 台州市 = 576
//    case 温州市 = 577
//    case 丽水市 = 578
//    case 金华市 = 579
//    case 舟山市 = 580
//
//    // 辽宁省
//    case 沈阳市 = 24
//    case 铁岭市 = 410
//    case 大连市 = 411
//    case 鞍山市 = 412
//    case 抚顺市 = 413
//    case 本溪市 = 414
//    case 丹东市 = 415
//    case 锦州市 = 416
//    case 营口市 = 417
//    case 阜新市 = 418
//    case 辽阳市 = 419
//    case 朝阳市 = 421
//    case 盘锦市 = 427
//    case 葫芦岛 = 429
//
//    // 湖北省
//    case 武汉市 = 27
//    case 襄城市 = 710
//    case 鄂州市 = 711
//    case 孝感市 = 712
//    case 黄州市 = 713
//    case 黄石市 = 714
//    case 咸宁市 = 715
//    case 荆沙市 = 716
//    case 宜昌市 = 717
//    case 恩施市 = 718
//    case 十堰市 = 719
//    case 随枣市 = 722
//    case 荆门市 = 724
//    case 江汉市 = 728
//
//    // 江苏省
//    case 南京市 = 25
//    case 无锡市 = 510
//    case 镇江市 = 511
//    case 苏州市 = 512
//    case 南通市 = 513
//    case 扬州市 = 514
//    case 盐城市 = 515
//    case 徐州市 = 516
//    case 淮阴淮安市 = 517
//    case 连云港 = 518
//    case 常州市 = 519
//    case 泰州市 = 523
//
//    // 内蒙古
//    case 海拉尔 = 470
//    case 呼和浩特 = 471
//    case 包头市 = 472
//    case 乌海市 = 473
//    case 集宁市 = 474
//    case 通辽市 = 475
//    case 赤峰市 = 476
//    case 东胜市 = 477
//    case 临河市 = 478
//    case 锡林浩特 = 479
//    case 乌兰浩特 = 482
//    case 阿拉善左旗 = 483
//
//    // 江西省
//    case 新余市 = 790
//    case 南昌市 = 791
//    case 九江市 = 792
//    case 上饶市 = 793
//    case 临川市 = 794
//    case 宜春市 = 795
//    case 吉安市 = 796
//    case 赣州市 = 797
//    case 景德镇 = 798
//    case 萍乡市 = 799
//    case 鹰潭市 = 701
//
//    // 山西省
//    case 忻州市 = 350
//    case 太原市 = 351
//    case 大同市 = 352
//    case 阳泉市 = 353
//    case 榆次市 = 354
//    case 长治市 = 355
//    case 晋城市 = 356
//    case 临汾市 = 357
//    case 离石市 = 358
//    case 运城市 = 359
//
//    // 甘肃省
//    case 临夏市 = 930
//    case 兰州市 = 931
//    case 定西市 = 932
//    case 平凉市 = 933
//    case 西峰市 = 934
//    case 武威市 = 935
//    case 张掖市 = 936
//    case 酒泉市 = 937
//    case 天水市 = 938
//    case 甘南州 = 941
//    case 白银市 = 943
//
//    // 山东省
//    case 菏泽市 = 530
//    case 济南市 = 531
//    case 青岛市 = 532
//    case 淄博市 = 533
//    case 德州市 = 534
//    case 烟台市 = 535
//    case 淮坊市 = 536
//    case 济宁市 = 537
//    case 泰安市 = 538
//    case 临沂市 = 539
//
//    // 黑龙江
//    case 阿城市 = 450
//    case 哈尔滨 = 451
//    case 齐齐哈尔 = 452
//    case 牡丹江 = 453
//    case 佳木斯 = 454
//    case 绥化市 = 455
//    case 黑河市 = 456
//    case 加格达奇 = 457
//    case 伊春市 = 458
//    case 大庆市 = 459
//
//    // 福建省
//    case 福州市 = 591
//    case 厦门市 = 592
//    case 宁德市 = 593
//    case 莆田市 = 594
//    case 晋江泉州市 = 595
//    case 漳州市 = 596
//    case 龙岩市 = 597
//    case 三明市 = 598
//    case 南平市 = 599
//
//    // 广东省
//    case 广州市 = 20
//    case 韶关市 = 751
//    case 惠州市 = 752
//    case 梅州市 = 753
//    case 汕头市 = 754
//    case 深圳市 = 755
//    case 珠海市 = 756
//    case 佛山市 = 757
//    case 肇庆市 = 758
//    case 湛江市 = 759
//    case 中山市 = 760
//    case 河源市 = 762
//    case 清远市 = 763
//    case 顺德市 = 765
//    case 云浮市 = 766
//    case 潮州市 = 768
//    case 东莞市 = 769
//    case 汕尾市 = 660
//    case 潮阳市 = 661
//    case 阳江市 = 662
//    case 揭西市 = 663
//
//    // 四川省
//    case 成都市 = 28
//    case 涪陵市 = 810
//    case 攀枝花 = 812
//    case 自贡市 = 813
//    case 永川市 = 814
//    case 绵阳市 = 816
//    case 南充市 = 817
//    case 达县市 = 818
//    case 万县市 = 819
//    case 遂宁市 = 825
//    case 广安市 = 826
//    case 巴中市 = 827
//    case 泸州市 = 830
//    case 宜宾市 = 831
//    case 内江市 = 832
//    case 乐山市 = 833
//    case 西昌市 = 834
//    case 雅安市 = 835
//    case 康定市 = 836
//    case 马尔康 = 837
//    case 德阳市 = 838
//    case 广元市 = 839
//
//    // 湖南省
//    case 岳阳市 = 730
//    case 长沙市 = 731
//    case 湘潭市 = 732
//    case 株州市 = 733
//    case 衡阳市 = 734
//    case 郴州市 = 735
//    case 常德市 = 736
//    case 益阳市 = 737
//    case 娄底市 = 738
//    case 邵阳市 = 739
//    case 吉首市 = 743
//    case 张家界 = 744
//    case 怀化市 = 745
//    case 永州冷 = 746
//
//    // 河南省
//    case 商丘市 = 370
//    case 郑州市 = 371
//    case 安阳市 = 372
//    case 新乡市 = 373
//    case 许昌市 = 374
//    case 平顶山 = 375
//    case 信阳市 = 376
//    case 南阳市 = 377
//    case 开封市 = 378
//    case 洛阳市 = 379
//    case 焦作市 = 391
//    case 鹤壁市 = 392
//    case 濮阳市 = 393
//    case 周口市 = 394
//    case 漯河市 = 395
//    case 驻马店 = 396
//    case 三门峡 = 398
//
//    // 云南省
//    case 昭通市 = 870
//    case 昆明市 = 871
//    case 大理市 = 872
//    case 个旧市 = 873
//    case 曲靖市 = 874
//    case 保山市 = 875
//    case 文山市 = 876
//    case 玉溪市 = 877
//    case 楚雄市 = 878
//    case 思茅市 = 879
//    case 景洪市 = 691
//    case 潞西市 = 692
//    case 东川市 = 881
//    case 临沧市 = 883
//    case 六库市 = 886
//    case 中甸市 = 887
//    case 丽江市 = 888
//
//    // 安徽省
//    case 滁州市 = 550
//    case 合肥市 = 551
//    case 蚌埠市 = 552
//    case 芜湖市 = 553
//    case 淮南市 = 554
//    case 马鞍山 = 555
//    case 安庆市 = 556
//    case 宿州市 = 557
//    case 阜阳市 = 558
//    case 黄山市 = 559
//    case 淮北市 = 561
//    case 铜陵市 = 562
//    case 宣城市 = 563
//    case 六安市 = 564
//    case 巢湖市 = 565
//    case 贵池市 = 566
//
//    // 宁夏
//    case 银川市 = 951
//    case 石嘴山 = 952
//    case 吴忠市 = 953
//    case 固原市 = 954
//
//    // 吉林省
//    case 长春市 = 431
//    case 吉林市 = 432
//    case 延吉市 = 433
//    case 四平市 = 434
//    case 通化市 = 435
//    case 白城市 = 436
//    case 辽源市 = 437
//    case 松原市 = 438
//    case 浑江市 = 439
//    case 珲春市 = 440
//
//    // 广西省
//    case 防城港 = 770
//    case 南宁市 = 771
//    case 柳州市 = 772
//    case 桂林市 = 773
//    case 梧州市 = 774
//    case 玉林市 = 775
//    case 百色市 = 776
//    case 钦州市 = 777
//    case 河池市 = 778
//    case 北海市 = 779
//
//    // 贵州省
//    case 贵阳遵义市 = 851
//    case 安顺市 = 853
//    case 都均市 = 854
//    case 凯里市 = 855
//    case 铜仁市 = 856
//    case 毕节市 = 857
//    case 六盘水 = 858
//    case 兴义市 = 859
//
//    // 陕西省
//    case 西安市 = 29
//    case 咸阳市 = 910
//    case 延安市 = 911
//    case 榆林市 = 912
//    case 渭南市 = 913
//    case 商洛市 = 914
//    case 安康市 = 915
//    case 汉中市 = 916
//    case 宝鸡市 = 917
//    case 铜川市 = 919
//
//    // 青海省
//    case 西宁市 = 971
//    case 海东市 = 972
//    case 同仁市 = 973
//    case 共和市 = 974
//    case 玛沁市 = 975
//    case 玉树市 = 976
//    case 德令哈 = 977
//
//    // 海南省
//    case 儋州市 = 890
//    case 海口市 = 898
//    case 三亚市 = 899
//
//    // 西藏
//    case 拉萨市 = 891
//    case 日喀则 = 892
//    case 山南市 = 893
}
