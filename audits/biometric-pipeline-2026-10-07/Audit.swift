import Foundation
import WhoopProtocol
import StrandAnalytics
func syntheticTachogram(base: Double, amp: Double, hz: Double, seconds: Double) -> [Double] {
    var rr: [Double] = [], t = 0.0
    while t < seconds { let value = base + amp * sin(2 * Double.pi * hz * t); rr.append(value); t += value / 1000 }
    return rr
}
@main enum Audit {
 static func main() {
    for step in [0.5,1.0] {
        let times=(0..<400).map {Double($0)*step}
        for hz in [0.1,0.25] {
            let first=times.map {20*sin(2*Double.pi*hz*$0)}
            let second=first.map {$0*2}
            let low=hz<0.15 ? 0.04 : 0.15, high=hz<0.15 ? 0.15 : 0.4
            let p1=HRVFreqDomain.bandPower(times:times,y:first,fLow:low,fHigh:high)
            let p2=HRVFreqDomain.bandPower(times:times,y:second,fLow:low,fHigh:high)
            print(String(format:"spectral fixed dt=%.1f frequency=%.2f amplitude20=%.9f amplitude40=%.9f ratio=%.9f expectedRatio=4",step,hz,p1,p2,p2/p1))
        }
    }
    for base in [600.0,800.0,1200.0] {
        for amp in [10.0,20.0,40.0] {
            let rr=syntheticTachogram(base:base,amp:amp,hz:0.25,seconds:120)
            let power=HRVFreqDomain.freqDomain(rawRR:rr)?.hf ?? -1
            print(String(format:"spectral public base=%.0f amplitude=%.0f HF=%.9f expectedApproxPower=%.1f",base,amp,power,amp*amp/2))
        }
    }
    let clean=(0..<300).map {RRInterval(ts:$0,rrMs:1000+($0%4)*10)}
    let duplicated=clean.flatMap {[$0,$0]}
    let banked=clean.enumerated().map {RRInterval(ts:($0.offset/6)*6,rrMs:$0.element.rrMs)}
    for (name,rr) in [("clean",clean),("duplicated",duplicated),("banked",banked)] {
        let timestamps=rr.map(\.ts), values=rr.map {Double($0.rrMs)}
        let cov=HRVAnalyzer.rrCoverage(tsSec:timestamps,rrMs:values)
        let col=HRVAnalyzer.collapsedCoverage(tsSec:timestamps,rrMs:values)
        let verdict=HRVAnalyzer.classifyCoverage(coverage:cov,collapsed:col)
        let beat=HRVAnalyzer.beatAccurateFraction(tsSec:timestamps,rrMs:values)
        print("SDNN \(name) index=\(HRVAnalyzer.sdnnIndex(rr) ?? -1) coverage=\(cov) verdict=\(verdict.rawValue) spreadTrusted=\(HRVAnalyzer.beatSpreadIsTrustworthy(verdict)) accuracy=\(beat) valuesTrusted=\(HRVAnalyzer.beatValuesAreTrustworthy(beatAccurateFraction:beat))")
    }
    for packet:[UInt8] in [[0,60],[8,60],[8,60,1],[8,60,1,0],[16,60],[16,60,0xe8],[16,60,0xe8,3],[16,60,0xe8,3,1]] {
        let decoded=StandardHeartRate.parse(packet)
        print("standard packet=\(packet) accepted=\(decoded != nil) rr=\(decoded?.rrRawTicks ?? [])")
    }
    for seconds in [200,400,800] {
        let times=(0..<seconds).map(Double.init)
        for hz in [0.25,0.253] {
            let signal=times.map {20*sin(2*Double.pi*hz*$0)}
            let mean=signal.reduce(0,+)/Double(signal.count)
            let y=signal.map {$0-mean}
            let p=HRVFreqDomain.bandPower(times:times,y:y,fLow:0.15,fHigh:0.4)
            print(String(format:"spectral grid seconds=%d frequency=%.3f normalizedIntegral=%.9f",seconds,hz,p))
        }
    }
    let hrvBase=BaselineState(baseline:50,spread:8,nValid:14,nightsSinceUpdate:0,status:.trusted)
    let rhrBase=BaselineState(baseline:60,spread:4,nValid:14,nightsSinceUpdate:0,status:.trusted)
    let emptyResp=Baselines.foldHistory([],cfg:Baselines.respCfg)
    for resp in [10.0,14.0,18.0,22.0] {
        let absent=RecoveryScorer.recovery(hrv:55,rhr:58,resp:resp,hrvBaseline:hrvBase,
            rhrBaseline:rhrBase,respBaseline:nil,sleepPerf:0.85)!
        let empty=RecoveryScorer.recovery(hrv:55,rhr:58,resp:resp,hrvBaseline:hrvBase,
            rhrBaseline:rhrBase,respBaseline:emptyResp,sleepPerf:0.85)!
        let drivers=RecoveryScorer.chargeDrivers(hrv:55,rhr:58,resp:resp,hrvBaseline:hrvBase,
            rhrBaseline:rhrBase,respBaseline:emptyResp,sleepPerf:0.85)
        print(String(format:"empty resp baseline n=%d usable=%@ rate=%.0f absentScore=%.6f emptyScore=%.6f driverCount=%d",
            emptyResp.nValid,String(emptyResp.usable),resp,absent,empty,drivers.count))
    }
 }
}
