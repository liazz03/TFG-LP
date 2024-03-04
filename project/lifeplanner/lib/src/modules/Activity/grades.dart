class Grades
{ 
  List<Assessment> assesments;
  Grades(this.assesments);

  // Calculate overall average
  double calculate_average(){
    double avg = 0;

    for (var assmt in assesments){
      avg += (assmt.weight * assmt.calculate_assesment_average());
    }
    
    return avg;
  }
}

class Assessment
{ 
  String name;
  int weight;
  List<Grade> grades;

  Assessment(this.name, this.weight, this.grades);

  // calculate Assesment average
  double calculate_assesment_average(){
    double avg = 0;

    for (var grade in grades){
      avg += (grade.weight * grade.grade);
    }
    
    return avg;
  }
}

class Grade
{
  String name;
  int weight;
  double grade;

  Grade(this.name, this.weight, this.grade);
}


