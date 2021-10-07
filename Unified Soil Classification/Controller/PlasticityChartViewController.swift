//
//  PlasticityChartViewController.swift
//  Unified Soil Classification
//
//  Created by Aybatu Kerküklüoğlu on 3.10.2021.
//

import UIKit
import CorePlot
import CoreData

class PlasticityChartViewController: UIViewController {
    
    @IBOutlet weak var hostView: CPTGraphHostingView!
    @IBOutlet weak var liquidLimitLabel: UILabel!
    @IBOutlet weak var plasticLimitLabel: UILabel!
    @IBOutlet weak var plasticityIndexLabel: UILabel!
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var laboratoryResults: LabResultDefault?
    var sample: Sample? {
        didSet {
            predicateLabResults()
        }
    }
    
    // Graph main plots
    private var mainPlot: CPTScatterPlot!
    private var aLinePlot: CPTScatterPlot!
    private var fiftyLinePlot: CPTScatterPlot!
    private var indexSevenPlot: CPTScatterPlot!
    private var indexFourPlot: CPTScatterPlot!
    private var uLinePlot: CPTScatterPlot!
    private var resultPlotX: CPTScatterPlot!
    private var resultPlotY: CPTScatterPlot!
    
    // Line plot values
    private let mainX = [0, 60]
    private let mainY = [0, 60]
    private let aLineX = [((4 / 0.73) + 20), 110]
    private let aLineY = [4, (0.73 * (110 - 20))]
    private let fiftyLineX = [50, 50]
    private let fiftyLineY = [0, 50]
    private let indexSevenX = [7, ((7 / 0.73) + 20)]
    private let indexSevenY = [7, 7]
    private let indexFourX = [4, ((4 / 0.73) + 20)]
    private let indexFourY = [4, 4]
    private let uLineX = [16, ((60 / 0.9) + 8)]
    private let uLineY = [7, 60]
    
    // Label Plots
    private var clMlPlot: CPTScatterPlot!
    private var mlOlPlot: CPTScatterPlot!
    private var mhOhPlot: CPTScatterPlot!
    private var clOlPlot: CPTScatterPlot!
    private var chOhPlot: CPTScatterPlot!
    private var uLineLabelPlot: CPTScatterPlot!
    private var aLineLabelPlot: CPTScatterPlot!
    
    // Label plot values
    private let clMlLabelPlotX = [15]
    private let clMlLabelPlotY = [4]
    private let mlOlPlotX = [40]
    private let mlOlPlotY = [4]
    private let mhOhPlotX = [70]
    private let mhOhPlotY = [15]
    private let clOlPlotX = [40]
    private let clOlPlotY = [20]
    private let chOhPlotX = [65]
    private let chOhPlotY = [40]
    private let uLinePlotX = [68]
    private let uLinePlotY = [50]
    private let aLinePlotX = [90]
    private let aLinePlotY = [40]
    
    //Liquid limit and plasticity index axis result values
    var liquidLimitXAxis: [Double]?
    var plasticityIndexXAxis: [Double]?
    var liquidLimitYAxis: [Double]?
    var plasticityIndexYAxis: [Double]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        initPlot()
    }
    
    //MARK: - plot configuration
    
    func initPlot() {
        configureHostView()
        configureGraph()
        configureChart()
    }
    
    //MARK: - Host view configuration
    
    func configureHostView() {
        hostView.allowPinchScaling = false
    }
    
    //MARK: - Graph configuration
    
    func configureGraph() {
        // Axis value range
        let xMax = 110.0
        let xMin = 0.0
        let yMax = 60.0
        let yMin = 0.0
        
        // Graph view settings
        let graph = CPTXYGraph(frame: hostView.bounds)
        graph.plotAreaFrame?.masksToBorder = false
        hostView.hostedGraph = graph
        
        graph.apply(CPTTheme(named: CPTThemeName.plainWhiteTheme))
        graph.fill = CPTFill(color: CPTColor.clear())
        graph.paddingBottom = 10.0
        graph.paddingLeft = 30.0
        graph.paddingTop = 0.0
        graph.paddingRight = 0.0
        
        //Graph axis label value configuration
        guard let plotSpace = graph.defaultPlotSpace as? CPTXYPlotSpace else { return }
        plotSpace.xRange = CPTPlotRange(locationDecimal: CPTDecimalFromDouble(xMin), lengthDecimal: CPTDecimalFromDouble(xMax - xMin))
        plotSpace.yRange = CPTPlotRange(locationDecimal: CPTDecimalFromDouble(yMin), lengthDecimal: CPTDecimalFromDouble(yMax - yMin))
        plotSpace.xScaleType = .linear
        plotSpace.yScaleType = .linear
        
        //Axis sets configration
        let axisSet = graph.axisSet as! CPTXYAxisSet
        
        //Axis number formatter
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        formatter.maximumFractionDigits = 0
        
        //Grid line configuration
        let majorGridLineStyle = CPTMutableLineStyle()
        majorGridLineStyle.lineWidth = 0.5
        majorGridLineStyle.lineColor = CPTColor.black()
        
        //Axis title style
        let titleStyle = CPTMutableTextStyle()
        titleStyle.color = CPTColor.black()
        titleStyle.fontName = "HelveticaNeue-Bold"
        titleStyle.fontSize = 14.0
        titleStyle.textAlignment = .left
        graph.titleTextStyle = titleStyle
        
        //Axis creation
        if let y = axisSet.yAxis {
            y.majorIntervalLength   = 10
            y.orthogonalPosition  = NSNumber(value: xMin)
            y.minorTicksPerInterval = 0
            y.title = "PLASTICITY INDEX"
            y.titleTextStyle = titleStyle
            y.majorGridLineStyle = majorGridLineStyle
            y.labelFormatter = formatter
        }
        
        if let x = axisSet.xAxis {
            x.majorIntervalLength = 10
            x.minorTicksPerInterval = 0
            x.orthogonalPosition = NSNumber(value: yMin)
            x.title = "LIQUID LIMIT"
            x.titleTextStyle = titleStyle
            x.labelFormatter = formatter
            x.majorGridLineStyle = majorGridLineStyle
        }
    }
    
    //MARK: - Chart configuration
    
    func configureChart() {
        // Line plots
        mainPlot = CPTScatterPlot()
        aLinePlot = CPTScatterPlot()
        fiftyLinePlot = CPTScatterPlot()
        indexSevenPlot = CPTScatterPlot()
        indexFourPlot = CPTScatterPlot()
        uLinePlot = CPTScatterPlot()
        resultPlotX = CPTScatterPlot()
        resultPlotY = CPTScatterPlot()
        
        setPlot(for: mainPlot)
        setPlot(for: aLinePlot)
        setPlot(for: fiftyLinePlot)
        setPlot(for: indexSevenPlot)
        setPlot(for: indexFourPlot)
        
        // Label Plots
        clMlPlot = CPTScatterPlot()
        mlOlPlot = CPTScatterPlot()
        mhOhPlot = CPTScatterPlot()
        clOlPlot = CPTScatterPlot()
        chOhPlot = CPTScatterPlot()
        uLineLabelPlot = CPTScatterPlot()
        aLineLabelPlot = CPTScatterPlot()
        
        setPlot(for: clMlPlot)
        setPlot(for: mlOlPlot)
        setPlot(for: mhOhPlot)
        setPlot(for: clOlPlot)
        setPlot(for: chOhPlot)
        setPlot(for: uLineLabelPlot)
        setPlot(for: aLineLabelPlot)
        
        // Custom type plots
        uLinePlot.interpolation = .linear
        
        let uPlotLineStyle = CPTMutableLineStyle()
        uPlotLineStyle.lineWidth = 1
        uPlotLineStyle.dashPattern = [10]
        uLinePlot.dataLineStyle = uPlotLineStyle
        
        let resultPlotLineStyle = CPTMutableLineStyle()
        resultPlotLineStyle.lineColor = CPTColor.red()
        resultPlotX.dataLineStyle = resultPlotLineStyle
        resultPlotY.dataLineStyle = resultPlotLineStyle
        
        guard let graph = hostView.hostedGraph else { return }
        uLinePlot.dataSource = self
        uLinePlot.delegate = self
        resultPlotX.dataSource = self
        resultPlotX.delegate = self
        resultPlotY.dataSource = self
        resultPlotY.delegate = self
        graph.add(uLinePlot, to: graph.defaultPlotSpace)
        graph.add(resultPlotX, to: graph.defaultPlotSpace)
        graph.add(resultPlotY, to: graph.defaultPlotSpace)
        
        
    }
    
    func setPlot(for plot: CPTScatterPlot) {
        plot.interpolation = .linear
        
        let plotLineStile = CPTMutableLineStyle()
        plotLineStile.lineWidth = 3
        plotLineStile.lineColor = CPTColor.black()
        plot.dataLineStyle = plotLineStile
        
        guard let graph = hostView.hostedGraph else { return }
        plot.dataSource = self
        plot.delegate = self
        graph.add(plot, to: graph.defaultPlotSpace)
    }
    
    //MARK: - Label Configuration
    
    func dataLabel(for plot: CPTPlot, record idx: UInt) -> CPTLayer? {
        //Chart data content Labels
        let labelStyle = CPTMutableTextStyle()
        labelStyle.color = CPTColor.black()
        labelStyle.fontName = "HelveticaNeue"
        labelStyle.fontSize = 13.0
        
        let lineLabelStyle = CPTMutableTextStyle()
        lineLabelStyle.color = CPTColor.black()
        lineLabelStyle.fontName = "HelveticaNeue-bold"
        lineLabelStyle.fontSize = 15.0
        
        if plot == clMlPlot && idx == 0 {
            let labelStyle = CPTMutableTextStyle()
            labelStyle.color = CPTColor.black()
            labelStyle.fontName = "HelveticaNeue"
            labelStyle.fontSize = 11.0
            
            let clMlLayer = CPTTextLayer(text: "CL-ML", style: labelStyle)
            clMlLayer.paddingBottom = -3
            return clMlLayer
        } else if plot == mlOlPlot {
            let mlOlLayer = CPTTextLayer(text: "ML or OL", style: labelStyle)
            return mlOlLayer
        } else if plot == mhOhPlot {
            let mhOhLayer = CPTTextLayer(text: "MH or OH", style: labelStyle)
            return mhOhLayer
        } else if plot == clOlPlot {
            let clOlLayer = CPTTextLayer(text: "CL or OL", style: labelStyle)
            return clOlLayer
        } else if plot == chOhPlot {
            let chOhLayer = CPTTextLayer(text: "CH or OH", style: labelStyle)
            return chOhLayer
        } else if plot == uLineLabelPlot {
            let uLineLayer = CPTTextLayer(text: "\"U\" LINE", style: lineLabelStyle)
            return uLineLayer
        } else if plot == aLineLabelPlot{
            let aLineLayer = CPTTextLayer(text: "\"A\" LINE", style: lineLabelStyle)
            return aLineLayer
        }else {
            return nil
        }
    }
    
    //MARK: - Data manipulation methods
    
    func loadData() {
        
        if let liquidLimit = laboratoryResults?.lL, let plasticLimit = laboratoryResults?.pL {
            let plasticityIndex = liquidLimit - plasticLimit
           //result marker
           liquidLimitXAxis = [Double(liquidLimit), Double(liquidLimit)]
           plasticityIndexXAxis = [0, plasticityIndex]
           liquidLimitYAxis = [0, liquidLimit]
           plasticityIndexYAxis = [plasticityIndex, plasticityIndex]
           
           //labels for result
           liquidLimitLabel.text = "LL = \(liquidLimit)"
           plasticLimitLabel.text = "PL = \(plasticLimit)"
           plasticityIndexLabel.text = "PI = \(plasticityIndex)"
        }
    }
    
    func predicateLabResults() {
        let request: NSFetchRequest<LaboratoryResults> = LaboratoryResults.fetchRequest()
        let predicate = NSPredicate(format: "parentSample.uuid MATCHES %@", sample!.uuid!)
        request.predicate = predicate

        do {
            let data = try context.fetch(request).last
            var newLabResults = LabResultDefault()
            newLabResults.threeInch = data!.threeInch
            newLabResults.threeFourInch = data!.threeFourInch
            newLabResults.no4 = data!.no4
            newLabResults.no10 = data!.no10
            newLabResults.no40 = data!.no40
            newLabResults.no200 = data!.no200
            newLabResults.pan = data!.pan
            newLabResults.pL = data!.plasticLimit
            newLabResults.lL = data!.liquidLimit
            newLabResults.wetWeight = data!.wetWeight
            newLabResults.driedWeight = data!.driedWeight
            laboratoryResults = newLabResults
        } catch {
            print("Error fetch data for graph: \(error)")
        }
    }
}

//MARK: - Plot delegate and data source methods

extension PlasticityChartViewController: CPTPlotDelegate, CPTScatterPlotDataSource {
    func numberOfRecords(for plot: CPTPlot) -> UInt {
        if plot == mainPlot {
            return UInt(mainX.count)
        } else if plot == aLinePlot {
            return UInt(aLineX.count)
        } else if plot == fiftyLinePlot {
            return UInt(fiftyLineX.count)
        } else if plot == indexSevenPlot {
            return UInt(indexSevenX.count)
        } else if plot == indexFourPlot {
            return UInt(indexFourX.count)
        } else if plot == uLinePlot {
            return UInt(uLineX.count)
        } else if plot == resultPlotX {
            return UInt(liquidLimitXAxis?.count ?? 0)
        } else if plot == resultPlotY {
            return UInt(liquidLimitYAxis?.count ?? 0)
        } else {
            return 1
        }
    }
    
    func number(for plot: CPTPlot, field fieldEnum: UInt, record idx: UInt) -> Any? {
        
        switch CPTScatterPlotField(rawValue: Int(fieldEnum))! {
        case .X:
            if plot == mainPlot {
                return mainX[Int(idx)] as NSNumber
            } else if plot == aLinePlot {
                return aLineX[Int(idx)] as NSNumber
            } else if plot == fiftyLinePlot{
                return fiftyLineX[Int(idx)]
            } else if plot == indexSevenPlot {
                return indexSevenX[Int(idx)] as NSNumber
            } else if plot == indexFourPlot {
                return indexFourX[Int(idx)] as NSNumber
            } else if plot == uLinePlot {
                return uLineX[Int(idx)] as NSNumber
            } else if plot == clMlPlot {
                return clMlLabelPlotX[Int(idx)] as NSNumber
            } else if plot == mlOlPlot {
                return mlOlPlotX[Int(idx)] as NSNumber
            } else if plot == mhOhPlot {
                return mhOhPlotX[Int(idx)] as NSNumber
            } else if plot == clOlPlot {
                return clOlPlotX[Int(idx)] as NSNumber
            } else if plot == chOhPlot {
                return chOhPlotX[Int(idx)] as NSNumber
            } else if plot == uLineLabelPlot {
                return uLinePlotX[Int(idx)] as NSNumber
            } else if plot == aLineLabelPlot {
                return aLinePlotX[Int(idx)] as NSNumber
            } else if plot == resultPlotX {
                return liquidLimitXAxis?[Int(idx)] ?? 0 as NSNumber
            } else if plot == resultPlotY {
                return liquidLimitYAxis?[Int(idx)] ?? 0 as NSNumber
            }
            
            else {
                return nil
            }
        case .Y:
            if plot == mainPlot {
                return mainY[Int(idx)] as NSNumber
            } else if plot == aLinePlot {
                return aLineY[Int(idx)] as NSNumber
            } else if plot == fiftyLinePlot {
                return fiftyLineY[Int(idx)]
            } else if plot == indexSevenPlot {
                return indexSevenY[Int(idx)] as NSNumber
            } else if plot == indexFourPlot {
                return indexFourY[Int(idx)] as NSNumber
            } else if plot == uLinePlot {
                return uLineY[Int(idx)] as NSNumber
            } else if plot == clMlPlot {
                return clMlLabelPlotY[Int(idx)] as NSNumber
            } else if plot == mlOlPlot {
                return mlOlPlotY[Int(idx)] as NSNumber
            } else if plot == mhOhPlot {
                return mhOhPlotY[Int(idx)] as NSNumber
            } else if plot == clOlPlot {
                return clOlPlotY[Int(idx)] as NSNumber
            } else if plot == chOhPlot {
                return chOhPlotY[Int(idx)] as NSNumber
            } else if plot == uLineLabelPlot {
                return uLinePlotY[Int(idx)] as NSNumber
            } else if plot == aLineLabelPlot {
                return aLinePlotY[Int(idx)] as NSNumber
            } else if plot == resultPlotX {
                return plasticityIndexXAxis![Int(idx)] as NSNumber
            } else if plot == resultPlotY {
                return plasticityIndexYAxis![Int(idx)] as NSNumber
            }
            else {
                return nil
            }
        default:
            return nil
        }
    }
}
