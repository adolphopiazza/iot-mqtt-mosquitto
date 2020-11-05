//
//  ViewController.swift
//  IOT-Publisher
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
    @IBOutlet weak var heartFrequenceInput: UITextField!
    @IBOutlet weak var bloodPressureInput: UITextField!
    @IBOutlet weak var bodyTemperatureInput: UITextField!
    
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

    @IBAction func publishHeartFrequence(_ sender: Any) {
        if let message = heartFrequenceInput.text {
            mqttClient?.publish(string: message, topic: Paths.heartFrequence, qos: 2, retain: false)
            heartFrequenceInput.text = ""
            showAlert(message: "Sua mensagem foi publicada!")
        }
    }
    
    @IBAction func publishBloodPressure(_ sender: Any) {
        if let message = bloodPressureInput.text {
            mqttClient?.publish(string: message, topic: Paths.bloodPressure, qos: 2, retain: false)
            bloodPressureInput.text = ""
            showAlert(message: "Sua mensagem foi publicada!")
        }
    }
    
    @IBAction func publishBodyTemperature(_ sender: Any) {
        if let message = bodyTemperatureInput.text {
            mqttClient?.publish(string: message, topic: Paths.bodyTemperature, qos: 2, retain: false)
            bodyTemperatureInput.text = ""
            showAlert(message: "Sua mensagem foi publicada!")
        }
    }
    
    @IBAction func connect(_ sender: Any) {
        mqttConfig = MQTTConfig(clientId: "publisher", host: "test.mosquitto.org", port: 1883, keepAlive: 60)
        
        mqttConfig?.onConnectCallback = { returnCode in
            NSLog("Return Code is \(returnCode.description)")
        }
        
        mqttConfig?.onMessageCallback = { mqttMessage in
            switch mqttMessage.topic {
            case Paths.heartFrequence:
                NSLog("Heart frequence payload=\(String(describing: mqttMessage.payloadString))")
            case Paths.bloodPressure:
                NSLog("Blood pressure payload=\(String(describing: mqttMessage.payloadString))")
            case Paths.bodyTemperature:
                NSLog("Body temperature payload=\(String(describing: mqttMessage.payloadString))")
            default:
                NSLog("MQTT Message received: payload = \(String(describing: mqttMessage.payloadString))")
            }
        }
        
        mqttConfig?.onPublishCallback = { messageId in
            NSLog("MQTT Message published mid = \(String(describing: messageId))")
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
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            self.heartFrequenceInput.resignFirstResponder()
            self.bloodPressureInput.resignFirstResponder()
            self.bodyTemperatureInput.resignFirstResponder()
        }))
        self.present(alert, animated: true)
    }
}

