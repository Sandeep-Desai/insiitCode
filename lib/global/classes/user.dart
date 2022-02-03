class User {
  String name;
  String imageUrl;

  String uid;
  String email;
  User(
      {this.name = 'John Doe',
      this.imageUrl = 'random', // TODO
      this.uid = '12345',
      this.email = 'johndoe@iitgn.ac.in'});
  Map<String, dynamic> toJson() {
    Map<String, dynamic> ret = {
      'full_name': name,
      "image_link": imageUrl,
      "user_id": uid,
      "email": email
    };
    return ret;
  }
}
