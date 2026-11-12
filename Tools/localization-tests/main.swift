import Foundation
extension Bundle {
    static let module = Bundle(path: ProcessInfo.processInfo.environment["WATTSON_TEST_RESOURCES"]!)!
}
let chinese = ProcessInfo.processInfo.environment["WATTSON_LANGUAGE"] == "zh-Hans"
let cases: [(String, String)] = [
    ("DRAWING FROM CHARGER", "当前外部供电"),
    ("holding", "暂停充电"), ("charging", "正在充电"), ("draining", "正在放电"),
    ("85 W headroom", "剩余功率余量 85 W"),
    ("peak 35.1 W", "峰值 35.1 W"),
    ("LAST 3 min", "最近 3 min"),
    ("2.90 GHz of 4.46 GHz", "2.90 GHz，上限 4.46 GHz"),
    ("No device matches “测试”", "没有与“测试”匹配的设备"),
    ("1000 of 3100 mA granted", "已分配 1000 mA，总计 3100 mA"),
    ("Battery · holding · 27 °C", "电池 · 暂停充电 · 27 °C"),
    ("CHARGING", "正在充电"),
    ("Vendor: General", "制造商：General"),
    ("No device matches “General”", "没有与“General”匹配的设备"),
    ("Apple A2343", "Apple A2343"), ("DELL U2723QE", "DELL U2723QE"),
    ("USB-C", "USB-C"), ("Thunderbolt 4", "Thunderbolt 4"),
    ("USB4 (40 Gbps)", "USB4 (40 Gbps)"), ("65.00 W", "65.00 W"),
    ("This Mac: charges at up to 70 W · this charger offers 65 W (20 V / 3.25 A)", "本机：最高充电功率 70 W · 此适配器可提供 65 W（20 V / 3.25 A）")
]
let table = try! JSONSerialization.jsonObject(with: Data(contentsOf: URL(fileURLWithPath: CommandLine.arguments[1]))) as! [[String]]
let allCases = cases + table.map { ($0[0], $0[1]) }
var failures = 0
for (source, target) in allCases {
 let actual = L10n.text(source)
 if actual != (chinese ? target : source) {
    print("FAIL: \(source) -> \(actual); expected \(chinese ? target : source)"); failures += 1
 }
}
print("Language \(chinese ? "zh-Hans" : "en"): \(allCases.count) cases, \(failures) failures")
exit(failures == 0 ? 0 : 1)
