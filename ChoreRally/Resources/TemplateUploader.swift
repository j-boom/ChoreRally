import Foundation
import FirebaseFirestore

// This class is a one-time utility to upload chore templates from the local JSON
// file to your Firestore database. You can remove the call to it from the AppDelegate
// after the first successful run.
class ChoreTemplateUploader {
    
    /// Checks if chore templates exist in Firestore and uploads them if not.
    static func uploadChoreTemplatesIfNeeded() {
        let db = Firestore.firestore()
        let templatesRef = db.collection("choreTemplates")
        
        // Check if templates already exist to avoid duplicate uploads.
        templatesRef.limit(to: 1).getDocuments { (snapshot, error) in
            if let error = error {
                print("Error checking for chore templates: \(error.localizedDescription)")
                return
            }
            
            // If there are no documents, proceed with the upload.
            if snapshot?.documents.isEmpty ?? true {
                print("No chore templates found in Firestore. Uploading from JSON...")
                uploadTemplates(to: templatesRef)
            } else {
                print("Chore templates already exist in Firestore. Skipping upload.")
            }
        }
    }
    
    /// Reads the local JSON file and uploads its contents to the specified collection.
    private static func uploadTemplates(to collectionRef: CollectionReference) {
        guard let url = Bundle.main.url(forResource: "ChoreTemplates", withExtension: "json") else {
            print("ChoreTemplates.json file not found. Make sure it's included in the app bundle.")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            // The Chore model is Codable, so we can decode directly from the JSON data.
            let templates = try JSONDecoder().decode([Chore].self, from: data)
            
            let batch = collectionRef.firestore.batch()
            for chore in templates {
                // Let Firestore generate the document ID by creating a reference to a new document.
                let docRef = collectionRef.document()
                try batch.setData(from: chore, forDocument: docRef)
            }
            
            batch.commit { error in
                if let error = error {
                    print("Error uploading chore templates in a batch: \(error.localizedDescription)")
                } else {
                    print("Successfully uploaded \(templates.count) chore templates.")
                }
            }
        } catch {
            print("Error decoding or uploading chore templates: \(error)")
        }
    }
}
