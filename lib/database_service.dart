import 'package:sample_project/constants.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:bcrypt/bcrypt.dart';

class DatabaseService {
  static late Db db;
  static late DbCollection usersCollection;
  static late DbCollection productsCollection;
  static late DbCollection businessesCollection;

  static Future<void> connect() async {
    db = await Db.create(
        "mongodb+srv://$dbUser:$dbPass@dd.zrune.mongodb.net/DiverseDen?retryWrites=true&w=majority&appName=DD");
    await db.open();

    usersCollection = db.collection("users");
    productsCollection = db.collection("products");
    businessesCollection = db.collection("businesses");
  }

  // Find user by email
  static Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    return await usersCollection.findOne(where.eq("email", email));
  }

  // Register user with hashed password
  static Future<void> registerUser(Map<String, dynamic> userData) async {
    userData['password'] = BCrypt.hashpw(userData['password'], BCrypt.gensalt());
    await usersCollection.insert(userData);
  }

  // Fetch business details by business ID
  static Future<Map<String, dynamic>?> getBusiness(ObjectId businessId) async {
    return await businessesCollection.findOne(
      where.eq('_id', businessId)
    );
  }

  // Check if SKU exists in the database for a specific business
  static Future<Map<String, dynamic>?> getProductBySKU(
      String sku, String businessId) async {
    return await productsCollection.findOne({
      'sku': sku,
      'business': ObjectId.parse(businessId),
    });
  }

  // Upload 3D Model Path
  static Future<void> upload3DModel(String sku, String businessId, String modelPath) async {
    await productsCollection.updateOne(
      {'sku': sku, 'business': ObjectId.parse(businessId)},
      {
        '\$set': {'modelPath': modelPath}
      },
    );
  }

  // Get All Products
  static Future<List<Map<String, dynamic>>> getAllProducts() async {
    return await productsCollection.find().toList();
  }

  // Get All Products with 3D Models 
  static Future<List<Map<String, dynamic>>> getProductsWith3DModels() async {
    return await productsCollection.find(where.exists("modelPath")).toList();
  }

  // Check If Email Already Exists
  static Future<bool> checkIfEmailExists(String email) async {
    var existingUser = await usersCollection.findOne({"email": email});
    return existingUser != null; // Returns true if email exists
  }

  // Check If Phone Already Exists
  static Future<bool> checkIfPhoneExists(String phone) async {
    var existingUser = await usersCollection.findOne({"phone": phone});
    return existingUser != null; // Returns true if phone exists
  }

}
