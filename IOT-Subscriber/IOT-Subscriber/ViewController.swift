//
//  ViewController.swift
//  IOT-Subscriber
//
//  Created by Adolpho Francisco Zimmermann Piazza on 05/11/20.
//

import UIKit
import Moscapsule

enum Paths {
    static let heartFrequence   = "adolpho/heartFrequence"
    static let bloodPressure    = "adolpho/bloodPressure"
    static let bodyTemperature  = "adolpho/bodyTemperature"
}

class ViewController: UIViewController {

    @IBOutlet var buttons: [UIButton]!
    @IBOutlet weak var heartFrequenceLabel: UILabel!
    @IBOutlet weak var bloodPressuraLabel: UILabel!
    @IBOutlet weak var bodyTemperatureLabel: UILabel!
    
    private var mqttConfig: MQTTConfig?
    private var mqttClient: MQTTClient?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupButtons()
    }
    
    private func setupButtons() {
        buttons.forEach { (button) in
            button.layer.cornerRadius = 10
        }
    }

    @IBAction func heartFrequenceSwitch(_ sender: UISwitch) {
        sender.isOn ?
            mqttClient?.subscribe(Paths.heartFrequence, qos: 2) :
            mqttClient?.unsubscribe(Paths.heartFrequence)
    }
    
    @IBAction func bloodPressureSwitch(_ sender: UISwitch) {
        sender.isOn ?
            mqttClient?.subscribe(Paths.bloodPressure, qos: 2) :
            mqttClient?.unsubscribe(Paths.bloodPressure)
    }
    
    @IBAction func bodyTemperatureSwitch(_ sender: UISwitch) {
        sender.isOn ?
            mqttClient?.subscribe(Paths.bodyTemperature, qos: 2) :
            mqttClient?.unsubscribe(Paths.bodyTemperature)
    }
    
    @IBAction func connect(_ sender: Any) {
        mqttConfig = MQTTConfig(clientId: "subscriber", host: "test.mosquitto.org", port: 1883, keepAlive: 60)
        
        mqttConfig?.onConnectCallback = { returnCode in
            NSLog("Return Code is \(returnCode.description)")
        }
        
        mqttConfig?.onMessageCallback = { mqttMessage in
            switch mqttMessage.topic {
            case Paths.heartFrequence:
                DispatchQueue.main.async {
                    if let value = mqttMessage.payloadString {
                        self.heartFrequenceLabel.text = "\(value) BPM"
                    }
                }
                NSLog("Heart frequence payload=\(String(describing: mqttMessage.payloadString))")
            case Paths.bloodPressure:
                DispatchQueue.main.async {
                    if let value = mqttMessage.payloadString {
                        self.bloodPressuraLabel.text = "\(value) mmHg"
                    }
                }
                NSLog("Blood pressure payload=\(String(describing: mqttMessage.payloadString))")
            case Paths.bodyTemperature:
                DispatchQueue.main.async {
                    if let value = mqttMessage.payloadString {
                        self.bodyTemperatureLabel.text = "\(value) ºC"
                    }
                }
                NSLog("Body temperature payload=\(String(describing: mqttMessage.payloadString))")
            default:
                NSLog("MQTT Message received: payload = \(String(describing: mqttMessage.payloadString))")
            }
        }
        
        mqttConfig?.onSubscribeCallback = { (messageId, grantedQos) in
            NSLog("subscribed (mid=\(messageId), grantedQos=\(grantedQos))")
        }
        
        mqttConfig?.onUnsubscribeCallback = { messageId in
            NSLog("unsubscribed mid:\(messageId)")
        }
        
        if let mqttConfig = mqttConfig {
            mqttClient = MQTT.newConnection(mqttConfig)
            showAlert(message: "Conectado!")
        }
    }
    
    @IBAction func disconnect(_ sender: Any) {
        mqttClient?.disconnect()
        showAlert(message: "Desconectado")
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
}

