import 'dart:convert';

class Grades {
  List<Assessment> assessments;

  Grades(this.assessments);

  Map<String, dynamic> toMap() {
    return {
      'assessments': json.encode(assessments.map((a) => a.toMap()).toList()),
    };
  }

  static Grades fromMap(Map<String, dynamic> map) {
    return Grades(
      (json.decode(map['assessments']) as List).map((a) => Assessment.fromMap(a)).toList(),
    );
  }

  double calculate_average() {
    double totalWeight = 0;
    double totalWeightedAvg = 0;
    assessments.forEach((assmt) {
      double assmtAvg = assmt.calculate_assessment_average();
      totalWeightedAvg += assmt.weight * assmtAvg;
      totalWeight += assmt.weight;
    });
    return totalWeight > 0 ? totalWeightedAvg / totalWeight : 0;
  }
}

class Assessment {
  String name;
  int weight;
  List<Grade> grades;

  Assessment(this.name, this.weight, this.grades);

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'weight': weight,
      'grades': json.encode(grades.map((g) => g.toMap()).toList()),
    };
  }

  static Assessment fromMap(Map<String, dynamic> map) {
    return Assessment(
      map['name'],
      map['weight'],
      (json.decode(map['grades']) as List).map((g) => Grade.fromMap(g)).toList(),
    );
  }

  double calculate_assessment_average() {
    double totalWeight = 0;
    double totalWeightedScore = 0;
    grades.forEach((grade) {
      totalWeightedScore += grade.weight * grade.grade;
      totalWeight += grade.weight;
    });
    return totalWeight > 0 ? totalWeightedScore / totalWeight : 0;
  }
}

class Grade {
  String name;
  int weight;
  double grade;

  Grade(this.name, this.weight, this.grade);

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'weight': weight,
      'grade': grade,
    };
  }

  static Grade fromMap(Map<String, dynamic> map) {
    return Grade(
      map['name'],
      map['weight'],
      map['grade'],
    );
  }
}

