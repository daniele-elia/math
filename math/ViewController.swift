//
//  ViewController.swift
//  math
//
//  Created by Daniele Elia on 18/02/15.
//  Copyright (c) 2015 Daniele Elia. All rights reserved.
//

import UIKit
import AVFoundation
import iAd

class ViewController: UIViewController, ADBannerViewDelegate {
    
    var bannerView:ADBannerView?
    
    @IBOutlet var labelScore: UILabel!
    @IBOutlet var labelTime: UILabel!
    @IBOutlet var labelNumber: UILabel!
    
    @IBOutlet var place1: UILabel!
    @IBOutlet var place2: UILabel!
    @IBOutlet var place3: UILabel!
    @IBOutlet var place4: UILabel!
    @IBOutlet var place5: UILabel!
    @IBOutlet var labelRisultato: UILabel!
    @IBOutlet var pallino: UIImageView!
    @IBOutlet var pallinoRosso: UIImageView!
    @IBOutlet var imagePlay: UIImageView!
    
    var player : AVAudioPlayer?
    
    //Varibili timer
    var globalTimer: NSTimer!
    var tempoDaInizio: Double!
    var tempoPartita: Int!
    var delayUscita: Int!
    
    //Varibili partita
    var nuovaPartita = true
    var hit = false
    
    //Varibili numeri
    let minBound: Int = 20
    let maxBound: Int = 100
    var indiceNumero: Int!
    var tempoAttesa: Int!
    var queue: [Int] = [0,0,0,0,0]
    var controllaRisultato = false
    var fattoreMoltiplicazione = 2

    override func viewDidLoad() {
        super.viewDidLoad()
        cleanPlace()
        pallino.hidden = true
        pallinoRosso.hidden = true
        imagePlay.hidden = false
        labelNumber.hidden = true
        
        decora(place1)
        decora(place2)
        decora(place3)
        decora(place4)
        decora(place5)
        
        self.canDisplayBannerAds = true
        self.bannerView?.delegate = self
        self.bannerView?.hidden = true
        
    }
    
    func bannerViewDidLoadAd(banner: ADBannerView!) {
        self.bannerView?.hidden = false
    }
    
    func bannerViewActionShouldBegin(banner: ADBannerView!, willLeaveApplication willLeave: Bool) -> Bool {
        return willLeave
    }
    
    func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
        self.bannerView?.hidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func tapPlay(sender: UITapGestureRecognizer) {
        tempoDaInizio = 0
        tempoPartita = 120
        delayUscita = 3000
        
        cleanPlace()
        labelRisultato.text = ""
        labelScore.text = ""
        labelTime.text = "\(tempoPartita)"
        nuovaPartita = false
        hit = false
        tempoAttesa = delayUscita
        
        generaRisultato()
        
        globalTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target:self, selector: Selector("controlloPartita"), userInfo: nil, repeats: true)
        
        generaNumero()
        imagePlay.hidden = true
        labelNumber.hidden = false
        
    }
    
    
    @IBAction func tapNumero(sender: UITapGestureRecognizer) {
        if nuovaPartita {
            //TODO cambia i numeri per cambiare il livello
            
        } else {
            //TODO
           hit = true
  
        }
    }

    func controlloPartita() {
        
        tempoDaInizio = tempoDaInizio + 100
        
        let tmp = tempoDaInizio/1000
        let intTmp = Int(tmp)
        
        if tmp == Double(intTmp) {
            //Secondo pieno aggiorno interfaccia
            tempoPartita = tempoPartita - 1
            labelTime.text = "\(tempoPartita)"
            
            if tempoPartita == 0 {
                globalTimer.invalidate()
                nuovaPartita = true
                //labelNumber.text = "start"
                labelNumber.text = ""
                labelNumber.hidden = true
                imagePlay.hidden = false
                pallino.hidden = true
                pallinoRosso.hidden = true
                
                var alert = UIAlertController(title: "Score", message: labelScore.text, preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Restart", style: UIAlertActionStyle.Default, handler: nil))
                alert.addAction(UIAlertAction(title: "Share", style: UIAlertActionStyle.Default, handler: shareScore ))
                self.presentViewController(alert, animated: true, completion: nil)
                
            }
        }
        
        
        
        if controllaRisultato {
            if indiceNumero == 6 {
                //Calcolo la somma
                sleep(1)
                var somma: Int = 0
                for j in queue {
                    somma = somma + j
                }
                

                //Confronto il risultato
                debugPrintln("somma -> \(somma) - dovevi ottenere -> \(labelRisultato.text!)")
                if somma == (labelRisultato.text! as NSString).integerValue {
                    labelScore.text = "\((labelScore.text! as NSString).integerValue + 1)"
                    //Suono Carino
                    fx("Glass")
                    pallino.hidden = false
                    pallinoRosso.hidden = true
                } else {
                    labelScore.text = "\((labelScore.text! as NSString).integerValue - 1)"
                    //Suono brutto
                    fx("fail")
                    pallino.hidden = true
                    pallinoRosso.hidden = false
                }
                cleanPlace()
                generaRisultato()
//                sleep(1)
                NSThread.sleepForTimeInterval(0.4)
                generaNumero()
                
            }
        }
        
        
        if hit {

            let valore: NSString = labelNumber.text!
            let i = valore.integerValue
            queue[indiceNumero - 1] = i

            switch indiceNumero {
                case 1: place1.text = labelNumber.text
                case 2: place2.text = labelNumber.text
                case 3: place3.text = labelNumber.text
                case 4: place4.text = labelNumber.text
                case 5: place5.text = labelNumber.text
                default: cleanPlace()
            }
            indiceNumero = indiceNumero + 1
            controllaRisultato = true
            hit = false
            generaNumero()
            tempoAttesa = delayUscita
            
        }
        
        tempoAttesa = tempoAttesa - 100
        if tempoAttesa <= 0 {
            generaNumero()
            tempoAttesa = delayUscita
        }

        
        
        
    }
    
    func shareScore (action : UIAlertAction!) {
        let postText = "fastSum\nScore: \(labelScore.text!)"
        //let postImage = UIImage(named: "windsor_castle.jpg")
        let activityItems = [postText]
        let activityController = UIActivityViewController(activityItems:activityItems, applicationActivities: nil)
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            self.presentViewController(activityController, animated: true, completion: nil)
            activityController.popoverPresentationController?.sourceView = self.view
        } else {
            self.presentViewController(activityController, animated: true, completion: nil)
        }
        return
    }
    
    func generaNumero ()  {
        
        var somma = 0
        
        for var i = 0; i < queue.count; i++ {
            somma = somma + queue[i]
        }
        var rimanenza = (labelRisultato.text! as NSString).integerValue - somma
        debugPrintln("rimangono -> \(rimanenza)")
        
        somma = somma + (queue.count + 1 - indiceNumero) * fattoreMoltiplicazione
        
        var limiteSup = (labelRisultato.text! as NSString).integerValue - somma
        var limiteInf = 0
        
        if limiteSup <= 4 {
            limiteSup = 4
        }
        if indiceNumero == 5 {
            //Prendo un intorno della rimanenza
            limiteSup = rimanenza + 2
            limiteInf = rimanenza - 2
            if limiteInf < 0 {
                limiteInf = 0
            }
            //Accorcio il tempo di attesa
            delayUscita = 1000
        } else {
            delayUscita = 3000
        }
        debugPrintln("limiteInf: \(limiteInf), limiteSup: \(limiteSup)")
        
        let numero = Int(arc4random_uniform( (limiteSup - limiteInf) + 1) ) + limiteInf
        
        labelNumber.text = ("\(numero)")
        
        fx("Pop")
    }
    
    func generaRisultato() {
        indiceNumero = 1
        
        //Numero da trovare
        let risultato = Int(arc4random_uniform( (maxBound - minBound) + 1) ) + minBound
        
        //TODO mettere il numero da trovare nella casella
        labelRisultato.text = "\(risultato)"
        
        controllaRisultato = false
    }
    
    func cleanPlace () {
        place1.text = ""
        place2.text = ""
        place3.text = ""
        place4.text = ""
        place5.text = ""
        queue = [0,0,0,0,0]
    }
    
    func fx(nome: String) {
        //var audioPlayer = AVAudioPlayer()
        let file = NSBundle.mainBundle().URLForResource(nome, withExtension: "aiff")
        player = AVAudioPlayer(contentsOfURL: file, error: nil)
        player!.volume = 0.5
        player!.prepareToPlay()
        player!.play()
    }
    
    func decora (label: UILabel) {
        
        let offSett: CGFloat = 0
        
        var bordo: CAShapeLayer = CAShapeLayer()
        var fill: CAShapeLayer = CAShapeLayer()
        
        var path: UIBezierPath = UIBezierPath(roundedRect: CGRectMake(offSett, offSett, label.frame.size.width - (offSett * 2), label.frame.size.height - (offSett * 2)), cornerRadius: 7)
        
        bordo.strokeColor = UIColor.redColor().CGColor
        bordo.fillColor = nil
        bordo.lineWidth = 1.0
        bordo.path = path.CGPath
        bordo.borderColor = UIColor.redColor().CGColor
        
        fill.fillColor = UIColor.greenColor().CGColor
        fill.opacity = 0.05
        fill.path = path.CGPath
        
        label.layer.addSublayer(bordo)
        label.layer.insertSublayer(fill, below: label.layer)

    }
    
    
    
}

