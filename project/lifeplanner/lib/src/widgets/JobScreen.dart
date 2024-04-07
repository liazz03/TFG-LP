
import 'package:flutter/material.dart';
import 'package:lifeplanner/src/database/dao/Jobs_dao.dart';
import 'package:lifeplanner/src/modules/Job/job.dart';

class JobsScreen extends StatefulWidget {
  @override
  _JobsScreenState createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  final JobsDao _jobsDao = JobsDao();
  final _formKey = GlobalKey<FormState>(); // Form key


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Jobs'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            iconSize: 30, 
            onPressed: () {  }, // Add job, add income
          ),
        ],
      ),
      body: FutureBuilder<List<Job>>(
        future: _jobsDao.getallJobs(), // Fetch vacations from the database
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            List<Job> jobs = snapshot.data!;
            return ListView.builder(
              itemCount: jobs.length,
              itemBuilder: (context, index) {
                final job = jobs[index];
                return ListTile(
                  title: Text(job.name),  // show job
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          // edit job
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Color.fromARGB(255, 163, 21, 10)),
                        onPressed: () => _confirmDeleteJob(job.id), // delete job
                      ),
                    ],
                  ),
                  isThreeLine: true,
                );
              },
            );
          } else {
            return Center(child: Text("No jobs found!"));
          }
        },
      ),
    );
  }

  void _confirmDeleteJob(int? id) {
    if (id == null) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Job'),
          content: Text('Are you sure you want to delete this job?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () async {
                await _jobsDao.deleteJob(id);
                Navigator.of(context).pop(); 
                setState(() {}); 
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("job deleted successfully.")));
              },
            ),
          ],
        );
      },
    );
  }

}