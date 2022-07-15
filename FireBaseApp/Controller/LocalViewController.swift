import UIKit
import FirebaseAnalytics
import FirebaseAuth
import GoogleSignIn
import FBSDKLoginKit
import TwitterKit

class LocalViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UILabel!
    @IBOutlet weak var provedorTextField: UILabel!
    
    private let usuario: Usuario
    
    init(usuario: Usuario) {
        self.usuario = usuario
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        Analytics.logEvent("InitScreen", parameters: ["message" : "Estas dentro del la ventana Home"])
        title = "Inicio"
        navigationItem.setHidesBackButton(true, animated: false)
        
        emailTextField.text = usuario.email
        provedorTextField.text = usuario.provedor.rawValue
    }

    @IBAction func cerrarAction(_ sender: Any) {
        
        fireBaseLogOut()
        
        if usuario.provedor == .Google {
            GIDSignIn.sharedInstance()?.signOut()
        }
        if usuario.provedor == .Facebook {
            LoginManager().logOut()
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    private func fireBaseLogOut() -> Void {
        do {
            try Auth.auth().signOut()
        } catch {
            print("Error al cerrar sesión")
        }
    }
    
}
