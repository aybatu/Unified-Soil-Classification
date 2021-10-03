//
//  SoilClassificationModel.swift
//  Soil Classification
//
//  Created by Aybatu Kerkukluoglu on 31.08.2021.
//

import Foundation

struct SoilClassificationModel {
    func classificateSoil(d60: Double, d30: Double, d10: Double, threeIncPer: Double, threeFourPer: Double, noFourPer: Double, noTenPer: Double, noFourtyPer: Double, noTwoHundredPer: Double, lL: Double, pL: Double, organicConstant: Double, cc: Double, cu:Double) -> String? {
        var finesType = ""
        
        let gravel = 100 - noFourPer
        let sandAndFines = noFourPer
        let fines = noTwoHundredPer
        let sand = sandAndFines - fines
        let no200Plus = 100 - noTwoHundredPer
        let cc = cc
        let cu = cu
        var aLine = 0.73 * (lL - 20)
        let uLine = 0.9 * (lL - 8)
        let pI = lL - pL
        
        if 0.73 * (lL - 20) <= 0 {
            aLine = 4
        }
        
        //fine types
        if 4...7 ~= pI && 4...((7 / 0.73) + 20) ~= lL {
            finesType = K.FinesType.clMl
        }
        if organicConstant > 0.75 {
            if pI > 7 && pI > aLine && 50 < lL && pI < uLine {
                finesType = K.FinesType.ch
            } else if pI > 0 && pI < aLine && 25.5...50 ~= lL {
                finesType = K.FinesType.ml
            } else if pI > 7 && pI > aLine && 16...50 ~= lL && pI < uLine {
               finesType = K.FinesType.cl
           } else if pI > 7 && pI < aLine && 50 < lL {
               finesType = K.FinesType.mh
           }
        } else if organicConstant < 0.75 {
            if pI > 7 && pI > aLine && 50 < lL && pI < uLine {
                finesType = K.FinesType.oh
            } else if pI > 0 && pI < aLine && 25.5...50 ~= lL {
                finesType = K.FinesType.ol
            } else if pI > 7 && pI > aLine && 16...50 ~= lL && pI < uLine {
                finesType = K.FinesType.ol
            } else if pI > 7 && pI < aLine && 50 < lL {
                finesType = K.FinesType.oh
            }
        }
        
//        print("no200plus:\(no200Plus)")
//        print("fines:\(fines)")
//        print("sand:\(sand)")
//        print("gravel:\(gravel)")
//        print("cu:\(cu)")
//        print("cc:\(cc)")
//        print("finesType:\(finesType)")
//        print("aLine:\(aLine)")
//        print("plastic index:\(pI)")
//        print("liquid limit:\(lL)")
        
        //MARK: - Inorganic type soils
        if fines < 50 {
            //gravel type soils
            if gravel > sand {
                if fines < 5 {
                    if cu >= 4 && 1...3 ~= cc {
                        if sand < 15 {
                            return "Well-graded gravel \"GW\""
                        } else if sand >= 15 {
                            return "Well-graded gravel with sand \"GW\""
                        }
                    } else if cu < 4 || cc < 1 || cc > 3 {
                        if sand < 15 {
                            return "Poorly graded gravel \"GP\""
                        } else if sand >= 15 {
                            return "Poorly graded gravel with sand \"GP\""
                        }
                    }
                } else if 5...12 ~= fines {
                    if cu >= 4 && 1...3 ~= cc {
                        if finesType == K.FinesType.ml || finesType == K.FinesType.mh  {
                            if sand < 15 {
                                return "Well-graded gravel with silt \"GW-GM\""
                            } else if sand >= 15 {
                                return "Well-graded gravel with silt and sand \"GW-GM\""
                            }
                        } else if finesType == K.FinesType.cl || finesType == K.FinesType.ch || finesType == K.FinesType.clMl {
                            if sand < 15 {
                                return "Well-graded gravel with clay (or silty clay) \"GW-GC\""
                            } else if sand >= 15 {
                                return "Well-graded gravel with clay and sand (or silty clay and sand \"GW-GC\""
                            }
                        }
                    } else if cu < 4 || cc < 1 || cc > 3 {
                        if finesType == K.FinesType.ml || finesType == K.FinesType.mh  {
                            if sand < 15 {
                                return "Poorly graded gravel with silt \"GP-GM\""
                            } else if sand >= 15 {
                                return "Poorly graded gravel with silt and sand \"GP-GM\""
                            }
                        } else if finesType == K.FinesType.cl || finesType == K.FinesType.ch || finesType == K.FinesType.clMl {
                            if sand < 15 {
                                return "Poorly graded gravel with clay (or silty clay) \"GP-GC\""
                            } else if sand >= 15 {
                                return "Poorly graded gravel with clay (or silty clay and sand) \"GP-GC\""
                            }
                        }
                    }
                } else if fines > 12 {
                    if finesType == K.FinesType.ml || finesType == K.FinesType.mh {
                        if sand < 15 {
                            return "Silty gravel \"GM\""
                        } else if sand >= 15 {
                            return "Silty gravel with sand \"GM\""
                        }
                    } else if finesType == K.FinesType.cl || finesType == K.FinesType.ch {
                        if sand < 15 {
                            return "Clayey gravel \"GC\""
                        } else if sand >= 15 {
                            return "Clayey gravel with sand \"GC\""
                        }
                    } else if finesType == K.FinesType.clMl {
                        if sand < 15 {
                            return "Silty, clayey gravel \"GC-GM\""
                        } else if sand >= 15 {
                            return "Silty, clayey gravel with sand \"GC-GM\""
                        }
                    }
                }
                //sand type soils
            } else if sand > gravel {
                if fines < 5 {
                    if cu >= 6 && 1...3 ~= cc {
                        if gravel < 15 {
                            return "Well-graded sand \"SW\""
                        } else if gravel >= 15 {
                            return "Well-graded sand with gravel \"SW\""
                        }
                    } else if cu < 6 || cc < 1 || cc > 3 {
                        if gravel < 15 {
                            return "Poorly graded sand \"SP\""
                        } else if gravel >= 15 {
                            return "Poorly graded sand with gravel \"SP\""
                        }
                    }
                } else if 5...15 ~= fines {
                    if cu >= 6 && 1...3 ~= cc {
                        if finesType == K.FinesType.ml || finesType == K.FinesType.mh {
                            if gravel < 15 {
                                return "Well-graded sand with silt \"SW-SM\""
                            } else if gravel >= 15 {
                                return "Well-graded sand with silt and gravel \"SW-SM\""
                            }
                        } else if finesType == K.FinesType.cl || finesType == K.FinesType.ch || finesType == K.FinesType.clMl {
                            if gravel < 15 {
                                return "Well-graded sand with clay (or silty clay) \"SW-SC\""
                            } else if gravel >= 15 {
                                return "Well-graded sand with clay and gravel (or silty clay and gravel) \"SW-SC\""
                            }
                        }
                    } else if cu < 6 || cc < 1 || cc > 3 {
                        if finesType == K.FinesType.ml || finesType == K.FinesType.mh {
                            if gravel < 15 {
                                return "Poorly graded sand with silt \"SP-SM\""
                            } else if gravel >= 15 {
                                return "Poorly graded sand with silt and gravel \"SP-SM\""
                            }
                        } else if finesType == K.FinesType.cl || finesType == K.FinesType.ch || finesType == K.FinesType.clMl {
                            if gravel < 15 {
                                return "Poorly graded sand with clay (or silty clay) \"SP-SC\""
                            } else if gravel >= 15 {
                                return "Poorly graded sand with clay and gravel (or silty clay and gravel) \"SP-SC\""
                            }
                        }
                    }
                } else if fines > 12 {
                    if finesType == K.FinesType.ml || finesType == K.FinesType.mh {
                        if gravel < 15 {
                            return "Silty sand \"SM\""
                        } else if gravel >= 15 {
                            return "Silty sand with gravel \"SM\""
                        }
                    } else if finesType == K.FinesType.cl || finesType == K.FinesType.ch {
                        if gravel < 15 {
                            return "Clayey sand \"SC\""
                        } else if gravel >= 15 {
                            return "Clayey sand with gravel \"SC\""
                        }
                    } else if finesType == K.FinesType.clMl {
                        if gravel < 15 {
                            return "Silty, clayey sand \"SC-SM\""
                        } else if gravel >= 15 {
                            return "Silty, clayey sand with gravel \"SC-SM\""
                        }
                    }
                }
            }
        }
        
        if fines >= 50 {
            //fine type soils
            if lL < 50 {
                //OL soil type
                if organicConstant < 0.75 {
                    if pI >= 4 && pI >= aLine {
                        if no200Plus < 30 {
                            if no200Plus < 15 {
                                return "Organic clay \"OL\""
                            } else if 15...30 ~= no200Plus {
                                if sand >= gravel {
                                    return "Organic clay with sand \"OL\""
                                } else if sand < gravel {
                                    return "Organic clay with gravel \"OL\""
                                }
                            }
                        } else if no200Plus >= 30 {
                            if sand >= gravel {
                                if gravel < 15 {
                                    return "Sandy organic clay \"OL\""
                                } else if gravel >= 15 {
                                    return "Sandy organic clay with gravel \"OL\""
                                }
                            } else if sand < gravel {
                                if sand < 15 {
                                    return "Gravelly organic clay \"OL\""
                                } else if sand >= 15 {
                                    return "Gravelly organic clay with sand \"OL\""
                                }
                            }
                        }
                    } else if pI < 4 && pI <= aLine {
                        if no200Plus < 30 {
                            if no200Plus < 15 {
                                return "Organic silt \"OL\""
                            } else if 15...30 ~= no200Plus {
                                if sand >= gravel {
                                    return "Organic silt with sand \"OL\""
                                } else if sand < gravel {
                                    return "Organic silt with gravel \"OL\""
                                }
                            }
                        } else if no200Plus >= 30 {
                            if sand >= gravel {
                                if gravel < 15 {
                                    return "Sandy organic silt \"OL\""
                                } else if gravel >= 15 {
                                    return "Sandy organic silt with gravel \"OL\""
                                }
                            } else if sand < gravel {
                                if sand < 15 {
                                    return "Gravelly organic silt \"OL\""
                                } else if sand >= 15 {
                                    return "Gravelly organic silt with sand \"OL\""
                                }
                            }
                        }
                    }
                    
                    //CL type soils
                } else if organicConstant > 0.75 {
                    if pI > 7 && pI >= aLine {
                        if no200Plus < 30 {
                            if no200Plus < 15 {
                                return "Lean clay \"CL\""
                            } else if 15...30 ~= no200Plus {
                                if sand >= gravel {
                                    return "Lean clay with sand \"CL\""
                                } else if sand < gravel {
                                    return "Lean clay with gravel \"CL\""
                                }
                            }
                        } else if no200Plus >= 30 {
                            if sand >= gravel {
                                if gravel < 15 {
                                    return "Sandy lean clay \"CL\""
                                } else if gravel >= 15 {
                                    return "Sandy lean clay with gravel \"CL\""
                                }
                            } else if sand < gravel {
                                if sand < 15 {
                                    return "Gravelly lean clay \"CL\""
                                } else if sand >= 15 {
                                    return "Gravelly lean clay with sand \"CL\""
                                }
                            }
                        }
                        //CL-ML type soils
                    } else if 4...7 ~= pI && pI >= aLine {
                        if no200Plus < 30 {
                            if no200Plus < 15 {
                                return "Silty clay \"CL-ML\""
                            } else if 15...30 ~= no200Plus {
                                if sand >= gravel {
                                    return "Silty clay with sand \"CL-ML\""
                                } else if sand < gravel {
                                    return "Silty clay with gravel \"CL-ML\""
                                }
                            }
                        } else if no200Plus >= 30 {
                            if sand >= gravel {
                                if gravel < 15 {
                                    return "Sandy silty clay \"CL-ML\""
                                } else if gravel >= 15 {
                                    return "Sandy silty clay with gravel \"CL-ML\""
                                }
                            } else if sand < gravel {
                                if sand < 15 {
                                    return "Gravelly silty clay \"CL\""
                                } else if sand >= 15 {
                                    return "Gravelly silty clay with sand \"CL-ML\""
                                }
                            }
                        }
                        //ML Type Soils
                    } else if pI < 4 || pI < aLine {
                        if no200Plus < 30 {
                            if no200Plus < 15 {
                                return "Silt \"ML\""
                            } else if 15...30 ~= no200Plus {
                                if sand >= gravel {
                                    return "Silt with sand \"ML\""
                                } else if sand < gravel {
                                    return "Silt with gravel \"ML\""
                                }
                            }
                        } else if no200Plus >= 30 {
                            if sand >= gravel {
                                if gravel < 15 {
                                    return "Sandy silt \"ML\""
                                } else if gravel >= 15 {
                                    return "Sandy silt with gravel \"ML\""
                                }
                            } else if sand < gravel {
                                if sand < 15 {
                                    return "Gravelly silt \"ML\""
                                } else if sand >= 15 {
                                    return "Gravelly silt with sand \"ML\""
                                }
                            }
                        }
                    }
                }
            } else if lL >= 50 {
                //OH type soild
                if organicConstant < 0.75 {
                    if pI > aLine {
                        if no200Plus < 30 {
                            if no200Plus < 15 {
                                return "Organic clay \"OH\""
                            } else if 15...30 ~= no200Plus {
                                if sand >= gravel {
                                    return "Organic clay with sand \"OH\""
                                } else if sand < gravel {
                                    return "Organic clay with gravel \"OH\""
                                }
                            }
                        } else if no200Plus >= 30 {
                            if sand >= gravel {
                                if gravel < 15 {
                                    return "Sandy organic clay \"OH\""
                                } else if gravel >= 15 {
                                    return "Sandy organic clay with gravel \"OH\""
                                }
                            } else if sand < gravel {
                                if sand < 15 {
                                    return "Gravelly organic clay \"OH\""
                                } else if sand >= 15 {
                                    return "Gravelly organic clay with sand \"OH\""
                                }
                            }
                        }
                    } else if pI < aLine {
                        if no200Plus < 30 {
                            if no200Plus < 15 {
                                return "Organic silt \"OH\""
                            } else if 15...30 ~= no200Plus {
                                if sand >= gravel {
                                    return "Organic silt with sand \"OH\""
                                } else if sand < gravel {
                                    return "Organic silt with gravel \"OH\""
                                }
                            }
                        } else if no200Plus >= 30 {
                            if sand >= gravel {
                                if gravel < 15 {
                                    return "Sandy organic silt \"OH\""
                                } else if gravel >= 15 {
                                    return "Sandy organic silt with gravel \"OH\""
                                }
                            } else if sand < gravel {
                                if sand < 15 {
                                    return "Gravelly organic silt \"OH\""
                                } else if sand >= 15 {
                                    return "Gravelly organic silt with sand \"OH\""
                                }
                            }
                        }
                    }
                    //CH type soils
                } else if organicConstant > 0.75 {
                    if pI >= aLine {
                        if no200Plus < 30 {
                            if no200Plus < 15 {
                                return "Fat clay \"CH\""
                            } else if 15...30 ~= no200Plus {
                                if sand >= gravel {
                                    return "Fat clay with sand \"CH\""
                                } else if sand < gravel {
                                    return "Fat clay with gravel \"CH\""
                                }
                            }
                        } else if no200Plus >= 30 {
                            if sand >= gravel {
                                if gravel < 15 {
                                    return "Sandy fat clay \"CH\""
                                } else if gravel >= 15 {
                                    return "Sandy fat clay with gravel \"CH\""
                                }
                            } else if sand < gravel {
                                if sand < 15 {
                                    return "Gravelly fat clay \"CH\""
                                } else if sand >= 15 {
                                    return "Gravelly fat clay with sand \"CH\""
                                }
                            }
                        }
                        //MH type soils
                    } else if pI < aLine {
                        if no200Plus < 30 {
                            if no200Plus < 15 {
                                return "Elastic silt \"MH\""
                            } else if 15...30 ~= no200Plus {
                                if sand >= gravel {
                                    return "Elastic silt with sand \"MH\""
                                } else if sand < gravel {
                                    return "Elastic silt with gravel \"MH\""
                                }
                            }
                        } else if no200Plus >= 30 {
                            if sand >= gravel {
                                if gravel < 15 {
                                    return "Sandy elastic silt \"MH\""
                                } else if gravel >= 15 {
                                    return "Sandy elastic silt with gravel \"MH\""
                                }
                            } else if sand < gravel {
                                if sand < 15 {
                                    return "Gravelly elastic silt \"MH\""
                                } else if sand >= 15 {
                                    return "Gravelly elastic silt with sand \"MH\""
                                }
                            }
                        }
                        
                    }
                }
            }
        }
        
        return "Check test results you have entered, soil type couldn't identified."
    }
}
