import UIKit
import FirebaseAnalytics
import FirebaseAuth
import GoogleSignIn
import FBSDKLoginKit
import TwitterKit
import AuthenticationServices

class AuthViewController: UIViewController {
    
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    private var currentNonce : String?

    override func viewDidLoad() {
        super.viewDidLoad()
        Analytics.logEvent("InitScreen", parameters: ["message" : "Estas dentro del la ventana login"])
        
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance()?.delegate = self
    }
    
    @IBAction func registarAction(_ sender: Any) {
        if email.text != "", password.text != "" {
            Auth.auth().createUser(withEmail: email.text!, password: password.text!) { (result, error) in
                self.showHome(result: result, error: error, proveedor: .Basic)
            }
        } else {
            alertaCampos(controlador: self)
        }
    }
    
    @IBAction func accederAction(_ sender: Any) {
        if email.text != "", password.text != "" {
            Auth.auth().signIn(withEmail: email.text!, password: password.text!) { (result, error) in
                self.showHome(result: result, error: error, proveedor: .Basic)
            }
        } else {
            alertaCampos(controlador: self)
        }
    }
    
    @IBAction func googleAction(_ sender: Any) {
        GIDSignIn.sharedInstance()?.signOut()
        GIDSignIn.sharedInstance()?.signIn()
    }
    
    @IBAction func facebookAction(_ sender: Any) {
        let loginManager = LoginManager()
        loginManager.logOut()
        loginManager.logIn(permissions: ["public_profile", "email"], viewController: self) { (result) in
            switch result {
            case .success(granted: _, declined: _, token: let token):
                let credencial: AuthCredential = FacebookAuthProvider.credential(withAccessToken: token.tokenString)
                Auth.auth().signIn(with: credencial) { (result, error) in
                    self.showHome(result: result, error: error, proveedor: .Facebook)
                }
            case .cancelled:
                break
            case .failed(_):
                break
            }
        }
    }
    
    @IBAction func appleAction(_ sender: Any) {
        
        currentNonce = Generar.randomNonceString()
        
        let appleiDProvider = ASAuthorizationAppleIDProvider()
        let request = appleiDProvider.createRequest()
        request.requestedScopes = [.email]
        request.nonce = Generar.sha256(currentNonce!)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
        
    }
    
    @IBAction func twitterAction(_ sender: Any) {
        TWTRTwitter.sharedInstance().logIn { (session, error) in
            if let session = session {
                let credencial = TwitterAuthProvider.credential(withToken: session.authToken, secret: session.authTokenSecret)
                Auth.auth().signIn(with: credencial) { (resultado, error) in
                    if let resultado = resultado {
                        self.showHome(result: resultado, error: error, proveedor: .Twiiter)
                    }
                }
            } else {
                print(error!)
            }
        }
    }
    
    private func showHome(result: AuthDataResult?, error: Error?, proveedor: ProviderType) -> Void {
        if let resultado = result, error == nil {
            let usuariox: Usuario = Usuario(email: resultado.user.email ?? "Sin email", provedor: proveedor)
            self.navigationController?.pushViewController(LocalViewController(usuario: usuariox), animated: true)
        } else {
            alertaError(controlador: self, opcion: true, proveedor: proveedor)
        }
    }

}


// DELEGADOS
extension AuthViewController: GIDSignInDelegate {
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if error == nil && user.authentication != nil {
            let credencial: AuthCredential = GoogleAuthProvider.credential(withIDToken: user.authentication.idToken, accessToken: user.authentication.accessToken)
            Auth.auth().signIn(with: credencial) { (result, error) in
                self.showHome(result: result, error: error, proveedor: .Google)
            }
        }
    }
    
}


extension AuthViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let nonce = currentNonce,
            let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
            let appleIDToken = appleIDCredential.identityToken,
            let appleIDTokenString = String(data: appleIDToken, encoding: .utf8) {
            
            let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: appleIDTokenString, rawNonce: nonce)
            Auth.auth().signIn(with: credential) { (result, error) in
                self.showHome(result: result, error: error, proveedor: .Apple)
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
    
}
