import 'package:expenses_tracker/models/category_data.dart';
import 'package:expenses_tracker/services/firestore_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';


//TO VIEW THE CATEGORY THAT WE HAVE ADDED IN THE DATA : HISTORY PAGE
class HistoryPage extends StatefulWidget {
  final Category category;

  HistoryPage({Key key, this.category}) : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final doc = Firestore.instance;
  DateTime _dateTime = DateTime.now();
  GlobalKey<FormState> _key = GlobalKey<FormState>();
  TextEditingController _expenseController = new TextEditingController();
  TextEditingController _budgetController = new TextEditingController();

 
  Future displayDateRangePicker (BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: _dateTime,
        firstDate: new DateTime(2015),
        lastDate: new DateTime(2026));
    if (picked !=null && picked != _dateTime ){
      setState(() {
        _dateTime = picked;
      });
    }
  }

  createAlertDialog (BuildContext context, DocumentSnapshot document){
    final category = Category.fromSnapshot(document);

    return showDialog(context: context, builder: (context){
      return  AlertDialog(
        title: Text("Edit Expense"),
        content:  new SingleChildScrollView(
          child: Form(
            key: _key,
            child: new Column(
              children: <Widget>[
                Text(category.type),
                TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return "Budget field cannot be empty";
                    return null;
                  },
                  controller: _expenseController,
                  maxLines: 1,
                  decoration: InputDecoration(
                    labelText: "Update Expenses",
                    labelStyle: TextStyle(color: Colors.black, fontSize:20.0),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: false),
                  inputFormatters: [
                    WhitelistingTextInputFormatter.digitsOnly,
                  ],
                ),

                TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return "Budget field cannot be empty";
                    return null;
                  },
                  controller: _budgetController,
                  maxLines: 1,
                  decoration: InputDecoration(
                    labelText: "Update Budget",
                    labelStyle: TextStyle(color: Colors.black, fontSize:20.0),
                    border: OutlineInputBorder(),
                  ),

                  keyboardType: TextInputType.numberWithOptions(decimal: false),
                  inputFormatters: [
                    WhitelistingTextInputFormatter.digitsOnly,
                  ],
                ),
                RaisedButton(
                  child: Text("Select Date"),
                  onPressed: () async {
                    await displayDateRangePicker(context);
                  },),
                Text("Date : ${DateFormat('MM/dd/yyyy').format(_dateTime).toString()}"),
              ],
            ),
          ),
        ),


        actions: <Widget>[
          FlatButton(
              child: Text("Update"),
              onPressed: () async {
                  if (_key.currentState.validate()) {
                    try {
                      Category categories = Category(
                        expenses: double.parse(_expenseController.text),
                        budget: double.parse(_budgetController.text),
                        date: _dateTime,
                        type: category.type,
                        id: category.id,
                      );
                      await FirestoreService().updateData(categories);
                      Navigator.pop(context);
                    } catch (e) {
                      print(e);
                    }

                  }
              }),

        ],
      );
    }
    );
  }

  void _deleteData(BuildContext context,String id) async {
    if(await _showConfirmationDialog(context)) {
      try {
        await FirestoreService().deleteData(id);
      }catch(e) {
        print(e);
      }
    }
  }

  Future<bool> _showConfirmationDialog(BuildContext context) async {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => AlertDialog(
          content: Text("Are you sure you want to delete?"),
          actions: <Widget>[
            FlatButton(
              textColor: Colors.red,
              child: Text("Delete"),
              onPressed: () => Navigator.pop(context,true),
            ),
            FlatButton(
              textColor: Colors.black,
              child: Text("No"),
              onPressed: () => Navigator.pop(context,false),
            ),
          ],
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return  Container(
      color: Colors.deepPurple[50],
      child: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder(
                stream: Firestore.instance.collection('Category').orderBy("Date").snapshots(),
                builder: (context, snapshot) {
                  if(!snapshot.hasData ) return const Text("Loading...");
                  return new ListView.builder(
                      itemCount: snapshot.data.documents.length,
                      itemBuilder: (BuildContext context, int index) =>
                          buildExpenseCard(context, snapshot.data.documents[index]));
                }
            ),
          ),
        ],
      ),
    );
  }

  Widget buildExpenseCard(BuildContext context, DocumentSnapshot document) {
    final category = Category.fromSnapshot(document);


    final primaryColor = const Color(0xFFEDE7F6);

    return new Container(
      color: primaryColor,
      child: Column(
        children: <Widget>[
          // Container(
          //     child: Text(DateFormat('MMMM yyyy').format(category.date).toString(), style: new TextStyle(fontSize: 25),)
          // ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(1),
              child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Row(children: <Widget>[
                        Text(category.type,  style: new TextStyle(fontSize: 25.0, fontStyle: FontStyle.italic),),
                        Spacer(),
                        IconButton(icon: Icon(Icons.delete),
                            onPressed: (){
                              _deleteData(context, category.id);
                            })
                      ]),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(2),
                      child: Row(children: <Widget>[
                        Text("Date : ${DateFormat('d MMMM yyyy').format(category.date).toString()}",  style: new TextStyle(fontSize: 20.0),),
                        Spacer(),
                        IconButton(icon: Icon(Icons.edit),
                            onPressed: (){
                              createAlertDialog(context, document);
                            })
                      ]),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(2),
                      child: Row(
                        children: <Widget>[
                          Text("\$RM${(category.expenses == null)? "n/a" : category.expenses.toStringAsFixed(2)}", style: new TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold),),
                          Spacer(),
                          Text("\$RM${(category.budget == null)? "n/a" : category.budget.toStringAsFixed(2)}", style: new TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold),),
                        ],
                      ),)
                  ]),
            ),
          ),
        ],
      ),
    );
  }
}
