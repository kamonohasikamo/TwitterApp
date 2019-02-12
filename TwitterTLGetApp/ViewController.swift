import UIKit
import Accounts     //Twitterアカウント認証する場合にインポートします
import Social       //Twitterの各機能を利用する場合にインポートします

class ViewController: UIViewController {
    
    @IBOutlet weak var myTextView: UITextView!
    
    var accountStore = ACAccountStore() //Twitter、Facebookなどの認証を行うクラス
    var twitterAccount: ACAccount?      //Twitterのアカウントデータを格納する
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //アプリ実行時にTwitter認証を行うアカウントデータを取得する
        getTwitterAccount()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Button押下時にTwitterに投稿する
    @IBAction func TouchTweet(sender: AnyObject) {
        postTweet()
    }
    
    //Twitterのアカウント認証を行う
    private func getTwitterAccount() {
        
        //アカウントを取得するタイプをTwitterに設定する
        let accountType =
            accountStore.accountType(withAccountTypeIdentifier: ACAccountTypeIdentifierTwitter)
        
        //Twitterのアカウントを取得する
        accountStore.requestAccessToAccounts(with: accountType, options: [:]) { (success: Bool, error: Error?) -> Void in
            
            if error != nil {
                // エラー処理
                print("error! \(error)")
                return
            }
            
            // Twitterアカウント情報を取得
            let accounts = self.accountStore.accounts(with: accountType)
                as! [ACAccount]
            
            if accounts.count == 0 {
                print("error! 設定画面からアカウントを設定してください")
                return
            }
            
            // ActionSheetを表示
            self.selectTwitterAccount(accounts: accounts)
        }
    }
    
    private func selectTwitterAccount(accounts: [ACAccount]) {
        
        // ActionSheetのタイトルとメッセージを設定する
        let alert = UIAlertController(title: "Twitter",
                                      message: "アカウントを選択してください",
                                      preferredStyle: .actionSheet)
        
        // アカウント選択のActionSheetを表示するボタン
        for account in accounts {
            alert.addAction(UIAlertAction(title: account.username, style: .default,
                                          handler: { (action) -> Void in
                                            
                                            // 選択したTwitterアカウントのデータを変数に格納する
                                            print("your select account is \(account)")
                                            self.twitterAccount = account
            }))
        }
        
        // 表示する
        self.present(alert, animated: true, completion: nil)
    }
    
    // ツイートを投稿
    private func postTweet() {
        
        let URL = NSURL(string: "https://api.twitter.com/1.1/statuses/update.json")
        
        // ツイートしたい文章をセット
        let params = ["status" : myTextView.text]
        
        // リクエストを生成
        let request = SLRequest(forServiceType: SLServiceTypeTwitter,
                                requestMethod: .POST,
                                url: URL as! URL,
                                parameters: params)
        
        // 取得したアカウントをセット
        request?.account = twitterAccount
        
        // APIコールを実行
        request?.perform { (responseData, urlResponse, error) -> Void in
            
            if error != nil {
                print("error is \(error)")
            }
            else {
                // 結果の表示
                do {
                    let result = try JSONSerialization.jsonObject(with: responseData!,
                                                                          options: .allowFragments) as! NSDictionary
                    
                    print("result is \(result)")
                    
                } catch {
                    return
                }
            }
        }
    }
}
