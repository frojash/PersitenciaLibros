
//
//  ViewController.swift
//  PeticionOpenLib
//
//  Created by Fernando Rojas Hidalgo on 5/28/18.
//  Copyright © 2018 Rohisa. All rights reserved.
//

import UIKit
import CoreData


class buscarLibro: UIViewController, UINavigationControllerDelegate {
 
    var datos = Datos()
    var libroElejido:String?
    var contexto : NSManagedObjectContext? = nil
    @IBOutlet weak var btnInvocar: UIButton!
    
    @IBOutlet weak var lblMensaje: UILabel!
    @IBOutlet weak var txtParametro: UITextField!
    @IBOutlet weak var lblTitulo: UILabel!
    @IBOutlet weak var lblAutores: UILabel!
    @IBOutlet weak var lblPortada: UILabel!
    @IBOutlet weak var imgPortada: UIImageView!
    
    func sincrono(){
        print("SINCRONO4444")
        let urls = "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:" + txtParametro.text!
        let url =  NSURL(string: urls)
        let datosNS = NSData(contentsOf: url! as URL)
        let texto = NSString(data:datosNS! as Data, encoding:String.Encoding.utf8.rawValue)
        let libro = txtParametro.text

      
        do{
            let json = try JSONSerialization.jsonObject(with: datosNS! as Data, options: JSONSerialization.ReadingOptions.mutableLeaves)
            
            
            var DatosImagen : Data? = nil

            var raiz = "ISBN:" + txtParametro.text!
            let dic1 = json as! NSDictionary
            
            if let dic2 = dic1[raiz] as? NSDictionary {
             
                var titulo = dic2["title"]! as! NSString as String
                lblTitulo.text = "Titulo: \(titulo)"
                
                txtParametro.isEnabled = false
                
                if (dic2["cover"] != nil){
                    let dicCover = try dic2["cover"] as! NSDictionary
                    if (dicCover.count > 0){
                        let cover = dicCover["medium"]! as! NSString as String
                        print(cover)
                        let url = URL(string: cover)
                        print(url)
                        
                        let dataImg = try? Data(contentsOf: url!)
                        
                        if (dataImg != nil){
                            DatosImagen = dataImg!
                            print(dataImg)
                            imgPortada.image = UIImage(data: dataImg!)
                            lblPortada.isHidden = false;
                        }
                        
                    }else{
                        lblPortada.isHidden = true;
                    }
                }
                
                let dicAutores = dic2["authors"] as? NSArray
                
                let insertlibroEntidad = NSEntityDescription.insertNewObject(forEntityName: "Libros", into: self.contexto!)
                insertlibroEntidad.setValue(titulo, forKey: "titulo")
                insertlibroEntidad.setValue(libro, forKey: "numero")
                if (DatosImagen != nil){
                    insertlibroEntidad.setValue(DatosImagen, forKey: "portada")
                }
    
                if (dicAutores != nil){
                    let insertAutorEntidad = NSEntityDescription.insertNewObject(forEntityName: "Autores_Libros", into: self.contexto!)
                    
                    var entidades = Set<NSObject>()
                    for item in dicAutores! { // loop through data items
                        let obj = item as! NSDictionary
                        var autores :String = "Autores: \n"
                        var cont : Int = 1
                        
                        for (key, value) in obj {
                            if (key as! String == "name"){
                                insertAutorEntidad.setValue(value, forKey: "nombre")
                                entidades.insert(insertAutorEntidad)

                                autores += "\(cont) - \(value) \n"
                                cont = cont + 1
                            }
                            
                            lblAutores.text = autores
                            
                        }
                    }
                    print("AQUIIIIIIIII")
                    insertlibroEntidad.setValue(entidades, forKey: "tiene")
                }
                
                do{
                    print("AQUIIIIIIIII2")
                    
                    try self.contexto?.save()
                    datos.array.append(libro!)
                    
                    
                }catch{
                    
                }

            }
            
        }catch{
            
        }
        
        
        lblMensaje.text = texto! as String
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.contexto = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        if (libroElejido != "NA" && libroElejido != ""){
            txtParametro.text = libroElejido
            
            let libroEntidad = NSEntityDescription.entity(forEntityName: "Libros", in: self.contexto!)
            let peticion = libroEntidad?.managedObjectModel.fetchRequestFromTemplate (withName: "petLibro", substitutionVariables: ["numero" : libroElejido])
            do{
                let libros = try self.contexto?.fetch(peticion!) as! [NSManagedObject]
               
                
                if (libros != nil){
                    
                    do{
                        print(libros)
                        let libroEntidad2 = libros.first
                       
                        
                        txtParametro.text = libroEntidad2?.value(forKey: "numero") as! String
                        lblTitulo.text = libroEntidad2?.value(forKey: "titulo") as! String
                        
                        let autores = libroEntidad2?.value(forKey: "tiene") as! Set<NSObject>
                        var autoresTexto :String = "Autores: \n"

                        for aut in autores{
                           
                            var cont : Int = 1
                           
                            autoresTexto += "\(cont) - \(aut.value(forKey: "nombre") as! String) \n"
                            cont = cont + 1

                        }
                        
                        lblAutores.text = autoresTexto
                        
                        if (libroEntidad2?.value(forKey: "portada") != nil){
                            let dataImg = libroEntidad2?.value(forKey: "portada") as! NSObject
                        
                            if (dataImg != nil){
                                imgPortada.image = UIImage(data: dataImg as! Data)
                                lblPortada.isHidden = false;
                            }
                        }
                        

                    }
                    catch{
                        
                    }
                    btnInvocar.isHidden = true;
                    return
                }else{
                    sincrono()
                }
                
            }catch{
                
            }
            
            
            
        }else{
            txtParametro.text = ""
        }
        
        libroElejido = nil

        
        do {
            Network.reachability = try Reachability(hostname: "www.google.com")
            do {
                try Network.reachability?.start()
            } catch let error as Network.Error {
                print(error)
            } catch {
                print(error)
            }
        } catch {
            print(error)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func Invocar(_ sender: UIButton) {
        if (txtParametro.text != ""){
            if (Network.reachability?.isReachable)!{
                self.contexto = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                
                if (libroElejido != "NA" && txtParametro.text != ""){
                    
                    let libroEntidad = NSEntityDescription.entity(forEntityName: "Libros", in: self.contexto!)
                    let peticion = libroEntidad?.managedObjectModel.fetchRequestFromTemplate (withName: "petLibro", substitutionVariables: ["numero" : txtParametro.text])
                    do{
                        let libros = try self.contexto?.fetch(peticion!) as! [NSManagedObject]
                        
                        
                        if (libros.count > 0){
                            
                            do{
                                print(libros)
                                let libroEntidad2 = libros.first
                                
                                
                                lblTitulo.text = libroEntidad2?.value(forKey: "titulo") as? String
                                
                                let autores = libroEntidad2?.value(forKey: "tiene") as! Set<NSObject>
                                var autoresTexto :String = "Autores: \n"
                                
                                for aut in autores{
                                    
                                    var cont : Int = 1
                                    
                                    autoresTexto += "\(cont) - \(aut.value(forKey: "nombre") as! String) \n"
                                    cont = cont + 1
                                    
                                }
                                
                                lblAutores.text = autoresTexto
                                
                                if (libroEntidad2?.value(forKey: "portada") != nil){
                                    let dataImg = libroEntidad2?.value(forKey: "portada") as! NSObject
                                    
                                    if (dataImg != nil){
                                        imgPortada.image = UIImage(data: dataImg as! Data)
                                        lblPortada.isHidden = false;
                                    }
                                }
                                
                                
                            }
                            catch{
                                
                            }
                            btnInvocar.isHidden = true;
                            return
                        }else{
                            sincrono()
                        }
                        
                    }catch{
                        
                    }

                }
            }else{
                lblMensaje.text = "No hay internet"
                print("Error: No hay conexión a Internet")
            }
        }
    }
    
    
}



//    func sincrono(){
//        let urls = "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:" + txtParametro.text!
//        let url =  NSURL(string: urls)
//        let datos:NSData? =  NSData(contentsOf: url! as URL)
//        let texto = NSString(data:datos! as Data, encoding:String.Encoding.utf8.rawValue)
//        lblMensaje.text = texto! as String
//    }
//
//
//    func asincrono(){
//
//        let urls = "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:" + self.txtParametro.text!
//        let url = NSURL(string: urls)
//        let sesion = URLSession.shared
//
//        let bloque = {(datos: Data?, resp : URLResponse?, error : Error?) -> Void in let texto = NSString(data: datos! as Data, encoding:String.Encoding.utf8.rawValue)
//             DispatchQueue.main.async {
//                self.lblMensaje.text = texto! as String}}
//        let dt = sesion.dataTask(with: url! as URL,completionHandler: bloque)
//        dt.resume()
//
//    }




