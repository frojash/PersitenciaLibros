//
//  tvcLista.swift
//  PeticionOpenLib
//
//  Created by Fernando Rojas Hidalgo on 6/8/18.
//  Copyright © 2018 Rohisa. All rights reserved.
//

import UIKit
import CoreData

class tvcLista: UITableViewController {
    
    var datos = Datos()

    var libroSel:String="NA"
    var contextoData : NSManagedObjectContext? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        self.contextoData = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let librosEntidad = NSEntityDescription.entity(forEntityName: "Libros", in: self.contextoData!)

        let peticion = librosEntidad?.managedObjectModel.fetchRequestTemplate(forName: "petLibros")
        do{
            
            let libros = try self.contextoData?.fetch(peticion!) as! [NSManagedObject]
            print(libros)

            if (!(libros.isEmpty)){
            
                for libro in libros {
                    let dato = libro.value(forKey: "numero") as! String
                    datos.array.append(dato)
                }
            }
        

            
        }
        catch{
            
        }
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        let rightBarButton = UIBarButtonItem(title: "+", style: .plain, target: self, action: #selector(irBuscarLibro))


        self.navigationItem.rightBarButtonItem = rightBarButton
        
        

    }

    @objc func irBuscarLibro(){
        libroSel = "NA"
        self.performSegue(withIdentifier: "idBuscarLibro", sender: self)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return datos.array.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        cell.textLabel?.text = datos.array[indexPath.row]
        return cell
    }


    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        libroSel = datos.array[indexPath.row]
        performSegue(withIdentifier: "idBuscarLibro", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "idBuscarLibro" {
            let destination = segue.destination as! buscarLibro
            destination.datos = datos
            destination.libroElejido = libroSel
            print(libroSel)
        }
    }

}
