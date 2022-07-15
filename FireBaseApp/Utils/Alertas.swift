import Foundation
import UIKit

func alertaCampos(controlador: UIViewController) {
    let alerta = UIAlertController(title: "Error", message: "Favor de llenar todos los campos", preferredStyle: .alert)
    alerta.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: nil))
    controlador.present(alerta, animated: true, completion: nil)
}

func alertaError(controlador: UIViewController, opcion: Bool, proveedor: ProviderType) {
    let alerta = UIAlertController(title: "Error", message: opcion ? "No se ha podido logear el usuario con prooverdor \(proveedor.rawValue)" : "No se ha podido registar el usuario con prooverdor \(proveedor.rawValue)", preferredStyle: .alert)
    alerta.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: nil))
    controlador.present(alerta, animated: true, completion: nil)
}
