//
//  GradationChartViewController.swift
//  Unified Soil Classification
//
//  Created by Aybatu Kerküklüoğlu on 3.10.2021.
//

import UIKit
import CorePlot
import CoreData

class GradationChartViewController: UIViewController {

    @IBOutlet weak var hostView: CPTGraphHostingView!
    @IBOutlet weak var d10Label: UILabel!
    @IBOutlet weak var d30Label: UILabel!
    @IBOutlet weak var d60Label: UILabel!
    @IBOutlet weak var cULabel: UILabel!
    @IBOutlet weak var cCLabel: UILabel!
    @IBOutlet weak var notSupportedLabel: UILabel!
    
    private var testResultsCalculationModel = TestResultsCalculationModel()
    var laboratoryTestResults: LaboratoryResults? {
        didSet {
            testResultsCalculationModel.soilEvaluation(threeInch: laboratoryTestResults?.threeInch ?? 0.0, threeFourInch: laboratoryTestResults?.threeFourInch ?? 0.0, noFour: laboratoryTestResults?.no4 ?? 0.0, noTen: laboratoryTestResults?.no10 ?? 0.0, noFourty: laboratoryTestResults?.no40 ?? 0.0, noTwoHundred: laboratoryTestResults?.no200 ?? 0.0, pan: laboratoryTestResults?.pan ?? 0.0, plasticLimit: laboratoryTestResults?.plasticLimit ?? 0.0, liquidLimit: laboratoryTestResults?.liquidLimit ?? 0.0, driedWeight: laboratoryTestResults?.driedWeight ?? 0.0, notDriedWeight: laboratoryTestResults?.wetWeight ?? 0.0)
        }
    }
    var sample: Sample? {
        didSet {
            loadData()
        }
    }
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private var mainPlot: CPTScatterPlot!
    private var d60Plot: CPTScatterPlot!
    private var d30Plot: CPTScatterPlot!
    private var d10Plot: CPTScatterPlot!
    
    private var dx60Plot: CPTScatterPlot!
    private var dx30Plot: CPTScatterPlot!
    private var dx10Plot: CPTScatterPlot!
    
    private var xValues = [Double]()
    private var yValues = [Double]()
    private var dYx10Values = [Double]()
    private var dYy10Values = [Double]()
    private var dYx30Values = [Double]()
    private var dYy30Values = [Double]()
    private var dYx60Values = [Double]()
    private var dYy60Values = [Double]()
    
    private var dXx10Values = [Double]()
    private var dXy10Values = [Double]()
    private var dXx30Values = [Double]()
    private var dXy30Values = [Double]()
    private var dXx60Values = [Double]()
    private var dXy60Values = [Double]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if testResultsCalculationModel.cU == Double.infinity || testResultsCalculationModel.cC == Double.infinity ||  testResultsCalculationModel.cU == Double.nan || testResultsCalculationModel.cC == Double.nan  ||  testResultsCalculationModel.cU == 0 && testResultsCalculationModel.cC == 0 {
            notSupportedLabel.isHidden = false
        } else {
            notSupportedLabel.isHidden = true
        }
        
        //cc and cu label values
        cULabel.text = "Cᵤ = \(String(format: "%.02f", testResultsCalculationModel.cU))"
        cCLabel.text = "C𝚌 = \(String(format: "%.02f", testResultsCalculationModel.cC))"
        //d60 label value
        d60Label.text = "D₆₀ = \(String(format: "%.02f", testResultsCalculationModel.dx["60"] ?? 0.0))"
        //d60 redLing y values
        dYx60Values.append(100.0)
        dYy60Values.append(60.0)
        dYx60Values.append(testResultsCalculationModel.dx["60"] ?? 0.0)
        dYy60Values.append(60.0)
        //d60 redLine x values
        dXx60Values.append(testResultsCalculationModel.dx["60"] ?? 0.0)
        dXx60Values.append(testResultsCalculationModel.dx["60"] ?? 0.0)
        dXy60Values.append(0)
        dXy60Values.append(60.0)
        //d30 label value
        d30Label.text = "D₃₀ = \(String(format: "%.02f", testResultsCalculationModel.dx["30"] ?? 0.0))"
        //d30 redLine y values
        dYx30Values.append(100.0)
        dYy30Values.append(30.0)
        dYx30Values.append(testResultsCalculationModel.dx["30"] ?? 0.0)
        dYy30Values.append(30.0)
        //d30 redLine x values
        dXx30Values.append(testResultsCalculationModel.dx["30"] ?? 0.0)
        dXx30Values.append(testResultsCalculationModel.dx["30"] ?? 0.0)
        dXy30Values.append(0)
        dXy30Values.append(30.0)
        
        //d10 label value
        d10Label.text = "D₁₀ = \(String(format: "%.02f", testResultsCalculationModel.dx["10"] ?? 0.0))"
        //d10 redLine y values
        dYx10Values.append(100.0)
        dYy10Values.append(10.0)
        dYx10Values.append(testResultsCalculationModel.dx["10"] ?? 0.0)
        dYy10Values.append(10.0)
        //d10 redLine x valyes
        dXx10Values.append(testResultsCalculationModel.dx["10"] ?? 0.0)
        dXx10Values.append(testResultsCalculationModel.dx["10"] ?? 0.0)
        dXy10Values.append(0)
        dXy10Values.append(10.0)
       
        yValues.append(testResultsCalculationModel.passingPercent["threeInchPer"] ?? 0.0)
        xValues.append(75.0)
    
        yValues.append(testResultsCalculationModel.passingPercent["threeFourInchPer"] ?? 0.0)
        xValues.append(19.0)
  
        yValues.append(testResultsCalculationModel.passingPercent["noFourPer"] ?? 0.0)
        xValues.append(4.75)
  
        yValues.append(testResultsCalculationModel.passingPercent["noTenPer"] ?? 0.0)
        xValues.append(2.0)
  
        yValues.append(testResultsCalculationModel.passingPercent["noFourtyPer"] ?? 0.0)
        xValues.append(0.425)
  
        yValues.append(testResultsCalculationModel.passingPercent["noTwoHundredPer"] ?? 0.0)
        xValues.append(0.075)
    
        
        initPlot()
    }
    
    func initPlot() {
        configureHostView()
        configureGraph()
        configureChart()
    }
    
    //MARK: - Chart configuration
    
    func configureHostView() {
        hostView.allowPinchScaling = true
    }
    
    func configureGraph() {
        
        let xLocations: Set<NSNumber> = [100, 10, 1, 0.1, 0.01]
        let xMinorLocations: Set<NSNumber> = [90, 80, 70, 60, 50, 40, 30, 20, 9, 8, 7, 6, 5, 4, 3, 2, 0.9, 0.8, 0.7, 0.6, 0.5, 0.4, 0.3, 0.2, 0.09, 0.08, 0.07, 0.06, 0.05, 0.04, 0.03, 0.02]
        
        let xMin = 0.01
        let xMax = 100.0
        let yMin = 0.0
        let yMax = 100.0
        
        let graph = CPTXYGraph(frame: hostView.bounds)
        graph.plotAreaFrame?.masksToBorder = false
        hostView.hostedGraph = graph
        
        graph.apply(CPTTheme(named: CPTThemeName.slateTheme))
        graph.fill = CPTFill(color: CPTColor.clear())
        graph.paddingBottom = 30.0
        graph.paddingLeft = 30.0
        graph.paddingTop = 0.0
        graph.paddingRight = 0.0
        
        let titleStyle = CPTMutableTextStyle()
        titleStyle.color = CPTColor.black()
        titleStyle.fontName = "HelveticaNeue-Bold"
        titleStyle.fontSize = 16.0
        titleStyle.textAlignment = .center
        graph.titleTextStyle = titleStyle
        
        guard let plotSpace = graph.defaultPlotSpace as? CPTXYPlotSpace else { return }
        plotSpace.xRange = CPTPlotRange(locationDecimal: CPTDecimalFromDouble(xMax), lengthDecimal: CPTDecimalFromDouble(xMin - xMax))
        plotSpace.yRange = CPTPlotRange(locationDecimal: CPTDecimalFromDouble(yMin), lengthDecimal: CPTDecimalFromDouble(yMax - yMin))
        plotSpace.xScaleType = .log
        
        let axisSet = graph.axisSet as! CPTXYAxisSet
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 3
        
        let gridLineStyle = CPTMutableLineStyle()
        gridLineStyle.lineWidth = 0.3
        gridLineStyle.lineColor = CPTColor.white()
        
        let xMajorLineStyle = CPTMutableLineStyle()
        xMajorLineStyle.lineWidth = 1
        xMajorLineStyle.lineColor = CPTColor.white()
        
        let tickLineStyle = CPTMutableLineStyle()
        tickLineStyle.lineColor = CPTColor.white()
        tickLineStyle.lineWidth = 3
        
        if let y = axisSet.yAxis {
            y.majorIntervalLength   = 10
            y.orthogonalPosition  = NSNumber(value: xMax)
            y.minorTicksPerInterval = 0
            y.labelFormatter = formatter
            y.title = "PERCENT PASSING"
            y.titleTextStyle = titleStyle
            y.majorGridLineStyle = gridLineStyle
        }
        
        if let x = axisSet.xAxis {
            x.title = "PARTICLE SIZE IN MILLIMETRES"
            x.titleTextStyle = titleStyle
            x.labelingPolicy = .locationsProvided
            x.labelFormatter = formatter
            x.minorGridLineStyle = gridLineStyle
            x.majorTickLineStyle = tickLineStyle
            x.majorGridLineStyle = xMajorLineStyle
            x.majorTickLocations = xLocations
            x.minorTickLocations = xMinorLocations
        }
        
    }
    
    func configureChart() {
        let titleStyle = CPTMutableTextStyle()
        titleStyle.color = CPTColor.black()
        titleStyle.fontName = "HelveticaNeue-Bold"
        titleStyle.fontSize = 16.0
        titleStyle.textAlignment = .center
        
        mainPlot = CPTScatterPlot()
        mainPlot.interpolation = .curved
        
        let plotLineStile = CPTMutableLineStyle()
        plotLineStile.lineWidth = 2
        plotLineStile.lineColor = CPTColor.cyan()
        mainPlot.dataLineStyle = plotLineStile
        
        guard let graph = hostView.hostedGraph else { return }
        mainPlot.dataSource = self
        mainPlot.delegate = self
        graph.add(mainPlot, to: graph.defaultPlotSpace)
        
        d60Plot = CPTScatterPlot()
        d30Plot = CPTScatterPlot()
        d10Plot = CPTScatterPlot()
        
        dx60Plot = CPTScatterPlot()
        dx30Plot = CPTScatterPlot()
        dx10Plot = CPTScatterPlot()
        
        setPlot(with: dx60Plot, for: graph)
        setPlot(with: dx30Plot, for: graph)
        setPlot(with: dx10Plot, for: graph)
        
        setPlot(with: d60Plot, for: graph)
        setPlot(with: d30Plot, for: graph)
        setPlot(with: d10Plot, for: graph)
    }
    
    func setPlot(with plot: CPTScatterPlot, for graph: CPTGraph) {
        let plotLineSyle = CPTMutableLineStyle()
        plotLineSyle.lineColor = CPTColor.red()
        plotLineSyle.lineWidth = 1
        plot.dataLineStyle = plotLineSyle
        
        plot.delegate = self
        plot.dataSource = self
        graph.add(plot, to: graph.defaultPlotSpace)
    }
    
    func dataLabel(for plot: CPTPlot, record idx: UInt) -> CPTLayer? {
        let titleStyle = CPTMutableTextStyle()
        titleStyle.color = CPTColor.black()
        titleStyle.fontName = "HelveticaNeue"
        titleStyle.fontSize = 16.0
        titleStyle.textAlignment = .left
        
        if plot == d10Plot && idx == 1 {
            if testResultsCalculationModel.dx["10"] != 0 {
                let layer = CPTTextLayer(text: "D10")
                layer.textStyle = titleStyle
                return layer
            } else {
                return nil
            }
        } else if plot == d30Plot && idx == 1 {
            if testResultsCalculationModel.dx["30"] != 0 {
                let layer = CPTTextLayer(text: "D30")
                layer.textStyle = titleStyle
                return layer
            } else {
                return nil
            }
        } else if plot == d60Plot && idx == 1 {
            if testResultsCalculationModel.dx["60"] != 0 {
                let layer = CPTTextLayer(text: "D60")
                layer.textStyle = titleStyle
                return layer
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    //MARK: - Data manipulation methods
    
    func loadData() {
        let request: NSFetchRequest<LaboratoryResults> = LaboratoryResults.fetchRequest()
        let predicate = NSPredicate(format: "parentSample.name MATCHES %@", sample!.name!)
        request.predicate = predicate

        do {
            laboratoryTestResults = try context.fetch(request).first
        } catch {
            print("Error fetch data for graph: \(error)")
        }
    }
    
}

//MARK: - Graph data source and delegate methods

extension GradationChartViewController: CPTScatterPlotDelegate, CPTScatterPlotDataSource {
    
    func numberOfRecords(for plot: CPTPlot) -> UInt {
        if plot == d10Plot {
            return UInt(dYx10Values.count)
        } else if plot == d30Plot {
            return UInt(dYx30Values.count)
        } else if plot == d60Plot {
            return UInt(dYx60Values.count)
        } else if plot == dx10Plot {
            return UInt(dXx10Values.count)
        } else if plot == dx30Plot {
            return UInt(dXx30Values.count)
        } else if plot == dx60Plot {
            return UInt(dXx60Values.count)
        } else {
            return UInt(xValues.count)
        }
    }
    
    func number(for plot: CPTPlot, field: UInt, record: UInt) -> Any? {
        
        switch CPTScatterPlotField(rawValue: Int(field))! {
        case .X:
            if plot == d10Plot {
                return (dYx10Values[Int(record)]) as NSNumber
            } else if plot == d30Plot {
                return (dYx30Values[Int(record)]) as NSNumber
            } else if plot == d60Plot {
                return (dYx60Values[Int(record)]) as NSNumber
            } else if plot == dx10Plot {
                return (dXx10Values[Int(1)]) as NSNumber
            } else if plot == dx30Plot {
                return (dXx30Values[Int(record)]) as NSNumber
            } else if plot == dx60Plot {
                return (dXx60Values[Int(record)]) as NSNumber
            } else {
                return (xValues[Int(record)]) as NSNumber
            }
        case .Y:
            
            if plot == d10Plot {
                return (dYy10Values[Int(record)]) as NSNumber
            } else if plot == d30Plot {
                return (dYy30Values[Int(record)]) as NSNumber
            } else if plot == d60Plot {
                return (dYy60Values[Int(record)]) as NSNumber
            } else if plot == dx10Plot {
                return (dXy10Values[Int(record)]) as NSNumber
            } else if plot == dx30Plot {
                return (dXy30Values[Int(record)]) as NSNumber
            } else if plot == dx60Plot {
                return (dXy60Values[Int(record)]) as NSNumber
            } else {
                return (yValues[Int(record)]) as NSNumber
            }
        default:
            return print("there is no data record for Sieve Analys Graph")
        }
    }
    
}
