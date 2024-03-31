abstract class Activity
{
  String name;
  String? description;
  
  Activity(this.name, this.description);


  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
    };
  }
}

