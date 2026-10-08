import Foundation
let hrv = BaselineState(baseline:50,spread:8,nValid:14,nightsSinceUpdate:0,status:.trusted)
let rhr = BaselineState(baseline:60,spread:4,nValid:14,nightsSinceUpdate:0,status:.trusted)
let empty = Baselines.foldHistory([],cfg:Baselines.respCfg)
for rate in [10.0,14.0,18.0,22.0] {
 let absent=RecoveryScorer.recovery(hrv:55,rhr:58,resp:rate,hrvBaseline:hrv,rhrBaseline:rhr,respBaseline:nil,sleepPerf:0.85)!
 let supplied=RecoveryScorer.recovery(hrv:55,rhr:58,resp:rate,hrvBaseline:hrv,rhrBaseline:rhr,respBaseline:empty,sleepPerf:0.85)!
 print(String(format:"resp %.0f emptyBaseline %.6f absentBaseline %.6f",rate,supplied,absent))
}
