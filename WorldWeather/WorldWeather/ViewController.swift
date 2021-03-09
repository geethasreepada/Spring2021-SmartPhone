//
//  ViewController.swift
//  WorldWeather
//
//  Created by alkadios on 3/5/21.
//

import UIKit
import Alamofire
import SwiftyJSON
import PromiseKit
import CoreLocation

class ViewController: UIViewController,CLLocationManagerDelegate,UITableViewDelegate,UITableViewDataSource{
    


    @IBOutlet weak var forecastTbl: UITableView!
    @IBOutlet weak var lblCity: UILabel!
    
    
    @IBOutlet weak var lblLat: UILabel!
    @IBOutlet weak var lblLng: UILabel!
    
    var forecastArray:[Forecast] = [Forecast]()
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
               forecastTbl.delegate = self
                forecastTbl.dataSource = self
                locationManager.delegate = self
                locationManager.requestWhenInUseAuthorization()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return forecastArray.count
        }
        
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            //let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
            let cell = Bundle.main.loadNibNamed("forecastTableViewCell", owner: self, options: nil)?.first as! forecastTableViewCell
                    
                    cell.lblMin.text = forecastArray[indexPath.row].min
                    
                    cell.lblMax.text = forecastArray[indexPath.row].max
                    cell.lblDate.text = forecastArray[indexPath.row].Date
                    return cell
                }
    
    override func viewWillAppear(_ animated: Bool) {
        
        updateFiveDayData("https://dataservice.accuweather.com/forecasts/v1/daily/5day/2628192?apikey=8uiWN1fBvl6V25XOSSiGH6x7hv5hLiyz")
        
           }
    @IBAction func clickBtn(_ sender: Any) {
        
        locationManager.requestLocation()
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let currLocation=locations.last{
            let lng=currLocation.coordinate.longitude
            let lat=currLocation.coordinate.latitude
            
            
            print("lat:\(lat)")
            print("lng:\(lng)")
            
            lblLat.text = "lat:\(lat)"
            lblLng.text = "lng:\(lng)"
            
            self.updateLocalWeather(lat,lng)
            
            
            
        }
    }
    func updateLocalWeather(_ lat:CLLocationDegrees,_ lng:CLLocationDegrees){
        let url = getLocationURL(lat, lng)
        
        
        getLocationData(url).done{
            (Key,city) in
            print(Key)
            print(city)
            
            self.lblCity.text = city
            let fiveDayForecastURL = self.getFiveDayForecastURL(Key)
            
            self.updateFiveDayData(fiveDayForecastURL).done{ (Rain) in
                
                print(Rain)
                
                
            }
            .catch { error in
                
                print("getting the 5 day Data:/(error.localizedDescription)")
            }
            print(fiveDayForecastURL)
        }
        
        .catch { error in
            
            print("Error in getting city:\(error.localizedDescription)")
          }
        
    }
    
    func getLocationURL(_ lat:CLLocationDegrees,_ lng:CLLocationDegrees)->String{

        var url=locationURL
        url.append(apiKey)
        url.append("&q=\(lat),\(lng)")
        return url

    }
    
    func getFiveDayForecastURL(_ cityKey:String)->String{
        
        var url=fiveDayForecastURL
        url.append("\(cityKey)")
        url.append("?apikey=\(apiKey)")
        return url
        
    }
    func getLocationData(_ url:String)->Promise<(String,String)>{
        
        return Promise<(String,String)>{seal -> Void in
            
            AF.request(url).responseJSON{response in
                
                if response.error != nil{
                    
                    seal.reject(response.error!)
                    
                }
                
                let locationJSON :JSON = JSON(response.data as Any)
                
                let Key = locationJSON["Key"].stringValue
                let   city   = locationJSON["LocalizedName"].stringValue
                seal.fulfill( (Key,city) )
            }
        }
    }
    
    
    
    func updateFiveDayData(_ url:String)->Promise<(String,Int)>{
        
        return Promise<(String,Int)>{seal -> Void in
            
            AF.request(url).responseJSON{response in

                if response.error != nil{

                    seal.reject(response.error!)

                }
                
                let locationJSON :JSON = JSON(response.data)
                print(locationJSON)
                
                            
                let minTemp :[JSON] = locationJSON["DailyForecasts[Temperature].Minimum"].arrayValue
                
                print(minTemp)
                
                
                let json:JSON = JSON(response.data)

                let dailyForecasts:[JSON] = json["DailyForecasts"].arrayValue


                self.forecastArray=[Forecast]()


                for dateVal in dailyForecasts{


                    print(dateVal["Date"])
                    print(dateVal["Temperature"])

                    print(dateVal["Temperature"]["Minimum"]["Value"])

                    print(dateVal["Temperature"]["Maximum"]["Value"])
                }

                seal.fulfill( ("One",1) )
            }
                
                
                }
        
    }
    
    
    
    
                

}