//
//  ViewController.swift
//  CameraApp
//
//  Created by 野村俊介 on 2021/08/26.
//

import UIKit


//UINavigationControllerDelegateは写真を撮り終わった場合
//UIImagePickerControllerDelegateは写真を選択し終わった場合の処理がこれを追加することによってできるようになる
class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var cameraStart: UIButton!
    
    @IBOutlet weak var snsPost: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//       ボタンの角を丸くする
        cameraStart.layer.cornerRadius = 10.0
        snsPost.layer.cornerRadius = 10.0

    }

    @IBOutlet weak var photoImage: UIImageView!
    
    @IBAction func cameraLaunchAction(_ sender: Any) {
//  カメラが使えるかどうかの関数[.isSourceTypeAvailable(camera)]
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            print("Camera can be used!")
            
//            ipc＝UIImagePickerControllerのインスタンス作成、下の関数
            let ipc = UIImagePickerController()
//            ipcのソースタイプに.cameraを設定
            ipc.sourceType = .camera
//            ipcのdelegateの設定つまり写真を撮った後、自分自身（self）←一旦こうゆうものだと覚えとくわ
            ipc.delegate = self
//            present(表示する)関数→animatedはアニメーションさせるかどうか、completionはプレゼンテーション終了後に実行するブロック
            present(ipc, animated: true, completion: nil)
            
        }else{
            print("Camera is not be available!")
        }
    }
    
    @IBAction func shareAction(_ sender: Any) {
//        画像があれば進む
        if let sharedImage = photoImage.image{
            
//            5MB以内に収める
            let resizedImage = sharedImage.fixedOrientation()?.resizeImage(maxSize: 5 * 1024 * 1024)
//            圧縮した画像データを格納する配列に入れる
            let  sharedItems = [resizedImage!]
//            シェアをするためのアクティビティのデータを渡す
            let controller = UIActivityViewController(activityItems: sharedItems, applicationActivities: nil)
//            ipadでの表示の対策（iphoneではいらない）
            controller.popoverPresentationController?.sourceView = view
//            シェア用のメニューを表示
            present(controller, animated: true, completion: nil)
            
        }
    }
    
//    撮った画像を扱う
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
//        delegateで終わったもの、イメージがあったらUIImage型としてphotoImageに渡す。InfoKeyからユーザーが選択した画像（originalImage）が取ることが可能
        photoImage.image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        
//        dismiss関数で画像を選択するダイアログを閉じる
        dismiss(animated: true, completion: nil)
    }
    

}

extension UIImage {

    /// 上下逆になった画像を反転する
    func fixedOrientation() -> UIImage? {
        if self.imageOrientation == UIImage.Orientation.up {
            return self
        }
        UIGraphicsBeginImageContextWithOptions(self.size, false, scale)
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else {
            return nil
        }
        UIGraphicsEndImageContext()
        return newImage
    }

    /// イメージ縮小
    func resizeImage(maxSize: Int) -> UIImage? {

        guard let jpg = self.jpegData(compressionQuality: 1) as NSData? else {
            return nil
        }
        if isLessThanMaxByte(data: jpg, maxDataByte: maxSize) {
            return self
        }
        // 80%に圧縮
        let _size: CGSize = CGSize(width: (self.size.width * 0.8), height: (self.size.height * 0.8))
        UIGraphicsBeginImageContext(_size)
        self.draw(in: CGRect(x: 0, y: 0, width: _size.width, height: _size.height))
        guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else {
            return nil
        }
        UIGraphicsEndImageContext()
        // 再帰処理
        return newImage.resizeImage(maxSize: maxSize)
    }

    /// 最大容量チェック
    func isLessThanMaxByte(data: NSData?, maxDataByte: Int) -> Bool {

        if maxDataByte <= 0 {
            // 最大容量の指定が無い場合はOK扱い
            return true
        }
        guard let data = data else {
            fatalError("Data unwrap error")
        }
        if data.length < maxDataByte {
            // 最大容量未満：OK　※以下でも良いがバッファを取ることにした
            return true
        }
        // 最大容量以上：NG
        return false
    }
}
