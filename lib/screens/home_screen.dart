import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_widget/connectivity_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:task_app/notification_services.dart';
import 'package:task_app/providers/user_details_providers.dart';
import 'package:task_app/screens/new_task_screen.dart';
import 'package:task_app/shared_preferences.dart';
import 'package:task_app/styles.dart';

import '../providers/app_providers.dart';
import '../providers/task_details_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  double percent = 0.2;
  int newPercent = 0;
  DateTime date = DateTime.now();
  late TabController tabController;
  String selected = "Personal", userName = "";
  List<String> taskType = ["Business", "Personal"];
  String email = 'email';
  String inboxStatus = "INBOX",
      completedStatus = "Completed",
      pendingStatus = "Pending",
      deleteStatus = "Deleted";

  late ScrollController _scrollController;

  @override
  void initState() {
    _scrollController = ScrollController();

    tabController = TabController(
      length: 4,
      vsync: this,
    );

    getEmail();
    super.initState();
  }

  @override
  void dispose() {
    tabController.dispose();
    AwesomeNotifications().actionSink.close();
    super.dispose();
  }

  void getEmail() async {
    email = await StorageServices.getUserEmail();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Scaffold(
          backgroundColor: AppColors.white,
          floatingActionButton: InkWell(
            onTap: (() {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NewTaskScreen(),
                ),
              );
            }),
            child: Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                color: AppColors.sky,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 20,
                    color: AppColors.sky!.withOpacity(0.7),
                  ),
                ],
              ),
              child: const Icon(
                Icons.add,
                color: AppColors.white,
                size: 40,
              ),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              physics: AppColors.scrollPhysics,
              child: ConnectivityWidget(
                offlineBanner: Container(
                  height: 25,
                  width: MediaQuery.of(context).size.width,
                  decoration: const BoxDecoration(
                    color: AppColors.backgroundColour,
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      "Please check your connection",
                      style: TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                builder: (connectivityContext, isConnect) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height / 3.3,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage("assets/bg.jpg"),
                            fit: BoxFit.cover,
                          ),
                          color: AppColors.backgroundColour,
                        ),
                        child: Consumer<TaskDetailsProvider>(
                          builder: (taskDetailsContext, taskDetailsProvider,
                              taskDetailChild) {
                            taskDetailsProvider.taskCountFunc();
                            taskDetailsProvider.taskDoneFunc();
                            taskDetailsProvider.taskDeleteFunc();
                            taskDetailsProvider.taskPendingFunc();
                            taskDetailsProvider.taskBusinessFunc();
                            taskDetailsProvider.taskPersonalFunc();
                            if (taskDetailsProvider.taskCount != 0 &&
                                taskDetailsProvider.taskDone != 0) {
                              percent = (taskDetailsProvider.taskDone /
                                  (taskDetailsProvider.taskCount -
                                      taskDetailsProvider.taskDelete));
                            } else {
                              percent = 0.0;
                            }
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Consumer<UserDetailsProvider>(builder:
                                    (userDetailsContext, userDetailsProvider,
                                        userDetailsChild) {
                                  Future.delayed(
                                    Duration.zero,
                                    (() {
                                      userDetailsProvider.userNameFunc();
                                    }),
                                  );
                                  return Container(
                                    padding: const EdgeInsets.only(
                                      top: 10,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 10),
                                          child: IconButton(
                                            onPressed: (() {}),
                                            icon: const Icon(
                                              Icons.menu,
                                              color: AppColors.white,
                                              size: 30,
                                            ),
                                            splashRadius: 20,
                                          ),
                                        ),
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              30,
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 15),
                                          child: Text(
                                            userDetailsProvider.userName!
                                                .replaceAll(RegExp(" "), "\n"),
                                            style: const TextStyle(
                                              overflow: TextOverflow.ellipsis,
                                              color: AppColors.white,
                                              fontSize: 30,
                                              fontWeight: FontWeight.w400,
                                              letterSpacing: 7,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              20,
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 15),
                                          child: Text(
                                            "${DateFormat.MMMM().format(date)[0]}${DateFormat.MMMM().format(date)[1]}${DateFormat.MMMM().format(date)[2]} ${date.day}, ${date.year}",
                                            style: TextStyle(
                                              color: AppColors.white
                                                  .withOpacity(0.5),
                                              fontWeight: FontWeight.w400,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              1.72,
                                          height: 3,
                                          decoration: BoxDecoration(
                                              gradient: LinearGradient(colors: [
                                            AppColors.newTaskScreenColour,
                                            AppColors.sky!,
                                          ])),
                                        )
                                      ],
                                    ),
                                  );
                                }),
                                Container(
                                  padding: const EdgeInsets.only(
                                    right: 15,
                                    left: 10,
                                    bottom: 15,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.blackLow.withOpacity(0.2),
                                  ),
                                  width:
                                      MediaQuery.of(context).size.width / 2.4,
                                  height:
                                      MediaQuery.of(context).size.height / 3,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          taskDetailsTile(
                                            count: taskDetailsProvider
                                                .taskPersonal
                                                .toString(),
                                            heading: "Personal",
                                          ),
                                          taskDetailsTile(
                                            count: taskDetailsProvider
                                                .taskBusiness
                                                .toString(),
                                            heading: "Business",
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height /
                                                15,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          CircularPercentIndicator(
                                            backgroundColor: AppColors.white
                                                .withOpacity(0.3),
                                            circularStrokeCap:
                                                CircularStrokeCap.round,
                                            animation: true,
                                            radius: 15,
                                            lineWidth: 2.5,
                                            percent: percent,
                                            progressColor: AppColors.skyLight,
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            " ${(percent * 100).toInt()}% done",
                                            style: TextStyle(
                                              color: AppColors.white
                                                  .withOpacity(0.5),
                                              fontSize: 15,
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 15,
                              ),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "INBOX",
                                  style: TextStyle(
                                    color: AppColors.blackLow.withOpacity(0.5),
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height / 1.9,
                              width: MediaQuery.of(context).size.width,
                              child: Consumer<AllAppProviders>(
                                builder: (allAppProvidersCtx,
                                    allAppProvidersProviders,
                                    allAppProvidersChild) {
                                  return bottomTiles(
                                    status: inboxStatus,
                                    firestoreEmail: email,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 25,
                            ),
                            child: Text(
                              "COMPLETED",
                              style: TextStyle(
                                color: AppColors.blackLow.withOpacity(0.5),
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Consumer<TaskDetailsProvider>(builder:
                              (taskDetailsContext, taskDetailsProvider,
                                  taskDetailsChild) {
                            taskDetailsProvider.taskDoneFunc();
                            return Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: AppColors.blackLow.withOpacity(0.4),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  taskDetailsProvider.taskDone.toString(),
                                  style: const TextStyle(
                                    color: AppColors.white,
                                    fontSize: 17,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Column taskDetailsTile({
    required String count,
    required String heading,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          count,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 25,
            fontWeight: FontWeight.w400,
          ),
        ),
        Text(
          heading,
          style: TextStyle(
            color: AppColors.white.withOpacity(0.5),
          ),
        ),
      ],
    );
  }

  Container tabBarContainer({
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.backgroundColour,
        ),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(
        label,
      ),
    );
  }

  void deleteTasks({
    required String taskDocID,
    required String status,
    required String firestoreEmail,
    required int taskSavedYear,
    required int taskSavedDay,
    required int taskSavedHour,
    required int taskSavedMonth,
    required int taskSavedMinute,
  }) async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection("users")
        .doc(firestoreEmail)
        .get();
    DocumentSnapshot taskDoc = await FirebaseFirestore.instance
        .collection("users")
        .doc(firestoreEmail)
        .collection("tasks")
        .doc(taskDocID)
        .get();

    final userDocUpdate =
        FirebaseFirestore.instance.collection("users").doc(firestoreEmail);

    final taskDocUpdate = FirebaseFirestore.instance
        .collection("users")
        .doc(firestoreEmail)
        .collection("tasks")
        .doc(taskDocID);

    DateTime taskSavedDate = DateTime(
      taskSavedYear,
      taskSavedMonth,
      taskSavedDay,
      taskSavedHour,
      taskSavedMinute,
    );

    DateTime date = DateTime.now();

    if (status == "Pending") {
      userDocUpdate.update(
        {
          Keys.taskPending: userDoc[Keys.taskPending] - 1,
        },
      );

      if (taskDoc[Keys.taskType] == "Business") {
        userDocUpdate.update(
          {
            Keys.taskBusiness: userDoc[Keys.taskBusiness] - 1,
          },
        );
      } else if (taskDoc[Keys.taskType] == "Personal") {
        userDocUpdate.update(
          {
            Keys.taskPersonal: userDoc[Keys.taskPersonal] - 1,
          },
        );
      }
    } else if (status == "Completed") {
      userDocUpdate.update(
        {
          Keys.taskDone: userDoc[Keys.taskDone] - 1,
        },
      );

      if (taskDoc[Keys.taskType] == "Business") {
        userDocUpdate.update(
          {
            Keys.taskBusiness: userDoc[Keys.taskBusiness] - 1,
          },
        );
      } else if (taskDoc[Keys.taskType] == "Personal") {
        userDocUpdate.update(
          {
            Keys.taskPersonal: userDoc[Keys.taskPersonal] - 1,
          },
        );
      }

      userDocUpdate.update(
        {
          Keys.taskDelete: userDoc[Keys.taskDelete] - 1,
        },
      );
    }

    taskDocUpdate.update(
      {
        Keys.taskStatus: Keys.deleteStatus,
      },
    );

    userDocUpdate.update(
      {
        Keys.taskDelete: userDoc[Keys.taskDelete] + 1,
      },
    );

    if (taskSavedDate.difference(date).inMinutes > 0) {
      NotificationServices().cancelTaskScheduledNotification(
        id: taskDoc[Keys.notificationID],
      );
    }
  }

  void undoTasks({
    required String taskDocID,
    required String status,
    required String firestoreEmail,
    required int taskSavedYear,
    required int taskSavedDay,
    required int taskSavedHour,
    required int taskSavedMonth,
    required int taskSavedMinute,
  }) async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection("users")
        .doc(firestoreEmail)
        .get();
    DocumentSnapshot taskDoc = await FirebaseFirestore.instance
        .collection("users")
        .doc(firestoreEmail)
        .collection("tasks")
        .doc(taskDocID)
        .get();

    DateTime taskSavedDate = DateTime(
      taskSavedYear,
      taskSavedMonth,
      taskSavedDay,
      taskSavedHour,
      taskSavedMinute,
    );

    DateTime date = DateTime.now();

    final userDocUpdate =
        FirebaseFirestore.instance.collection("users").doc(firestoreEmail);

    final taskDocUpdate = FirebaseFirestore.instance
        .collection("users")
        .doc(firestoreEmail)
        .collection("tasks")
        .doc(taskDocID);

    userDocUpdate.update(
      {
        Keys.taskPending: userDoc[Keys.taskPending] + 1,
      },
    );
    userDocUpdate.update(
      {
        Keys.taskDelete: userDoc[Keys.taskDelete] - 1,
      },
    );

    if (taskDoc[Keys.taskType] == "Business") {
      userDocUpdate.update(
        {
          Keys.taskBusiness: userDoc[Keys.taskBusiness] + 1,
        },
      );
    } else if (taskDoc[Keys.taskType] == "Personal") {
      userDocUpdate.update(
        {
          Keys.taskPersonal: userDoc[Keys.taskPersonal] + 1,
        },
      );
    }

    taskDocUpdate.update(
      {
        Keys.taskStatus: "Pending",
      },
    );

    if (taskSavedDate.difference(date).inMinutes > 0) {
      NotificationServices().createScheduledTaskNotification(
        id: taskDoc[Keys.notificationID],
        title: taskDoc[Keys.taskNotification],
        body: "${taskDoc[Keys.taskName]}\n${taskDoc[Keys.taskDes]}",
        payload: taskDoc[Keys.taskDes],
        dateTime: taskSavedDate,
      );
    }
  }

  void updateTasks({
    required String taskDocID,
    required String status,
    required String firestoreEmail,
    required int taskSavedYear,
    required int taskSavedDay,
    required int taskSavedHour,
    required int taskSavedMonth,
    required int taskSavedMinute,
  }) async {
    final taskDocUpdate = FirebaseFirestore.instance
        .collection("users")
        .doc(firestoreEmail)
        .collection("tasks")
        .doc(taskDocID);

    DocumentSnapshot taskDocRef = await taskDocUpdate.get();

    DateTime taskSavedDate = DateTime(
      taskSavedYear,
      taskSavedMonth,
      taskSavedDay,
      taskSavedHour,
      taskSavedMinute,
    );

    DateTime date = DateTime.now();

    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection("users")
        .doc(firestoreEmail)
        .get();

    final userDocUpdate =
        FirebaseFirestore.instance.collection("users").doc(firestoreEmail);

    if (status == "Pending") {
      taskDocUpdate.update(
        {
          Keys.taskStatus: "Completed",
        },
      );

      userDocUpdate.update(
        {
          Keys.taskDone: userDoc[Keys.taskDone] + 1,
        },
      );
      userDocUpdate.update(
        {
          Keys.taskPending: userDoc[Keys.taskPending] - 1,
        },
      );

      if (taskSavedDate.difference(date).inMinutes > 0) {
        NotificationServices().cancelTaskScheduledNotification(
          id: taskDocRef[Keys.notificationID],
        );
      }
    } else if (status == "Completed") {
      taskDocUpdate.update(
        {
          Keys.taskStatus: "Pending",
        },
      );

      userDocUpdate.update(
        {
          Keys.taskPending: userDoc[Keys.taskPending] + 1,
        },
      );
      userDocUpdate.update(
        {
          Keys.taskDone: userDoc[Keys.taskDone] - 1,
        },
      );

      if (taskSavedDate.difference(date).inMinutes > 0) {
        NotificationServices().createScheduledTaskNotification(
          title: taskDocRef[Keys.taskNotification],
          body: "${taskDocRef[Keys.taskName]}\n${taskDocRef[Keys.taskDes]}",
          id: taskDocRef[Keys.notificationID],
          payload: taskDocRef[Keys.taskName],
          dateTime: taskSavedDate,
        );
      }
    }
  }

  String dayStatus(int time) {
    switch (time) {
      case 00:
        return "am";
      case 01:
        return "am";
      case 02:
        return "am";
      case 03:
        return "am";
      case 04:
        return "am";
      case 05:
        return "am";
      case 06:
        return "am";
      case 07:
        return "am";
      case 08:
        return "am";
      case 09:
        return "am";
      case 10:
        return "am";
      case 11:
        return "am";
      case 12:
        return "pm";
      case 13:
        return "pm";
      case 14:
        return "pm";
      case 15:
        return "pm";
      case 16:
        return "pm";
      case 17:
        return "pm";
      case 18:
        return "pm";
      case 19:
        return "pm";
      case 20:
        return "pm";
      case 21:
        return "pm";
      case 22:
        return "pm";
      case 23:
        return "pm";
      default:
        return "";
    }
  }

  String timeChange(String time) {
    switch (time) {
      case "13":
        return "1";
      case "14":
        return "2";
      case "15":
        return "3";
      case "16":
        return "4";
      case "17":
        return "5";
      case "18":
        return "6";
      case "19":
        return "7";
      case "20":
        return "8";
      case "21":
        return "9";
      case "22":
        return "10";
      case "23":
        return "11";
      default:
        return time;
    }
  }

  Padding bottomTiles({
    required String status,
    required String firestoreEmail,
  }) {
    final firestoreAll = FirebaseFirestore.instance
        .collection("users")
        .doc(firestoreEmail)
        .collection("tasks")
        .where(Keys.taskStatus, isNotEqualTo: "Deleted")
        .orderBy(Keys.taskStatus, descending: true)
        .snapshots();

    return Padding(
      padding: const EdgeInsets.only(
        right: 10,
        left: 10,
      ),
      child: StreamBuilder<QuerySnapshot>(
        stream: firestoreAll,
        builder: (streamContext, snapshot) {
          // print(snapshot.data!.docs.length);

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.newTaskScreenColour,
              ),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text("error"),
            );
          }

          if (snapshot.data!.docs.isEmpty) {
            return Center(
              child: Lottie.asset("assets/empty_animation.json"),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 10,
              ),
              SizedBox(
                // color: AppColors.sky,
                height: MediaQuery.of(context).size.height / 2.1,
                width: MediaQuery.of(context).size.width,
                child: ListView.separated(
                  physics: AppColors.scrollPhysics,
                  itemCount: snapshot.data!.docs.length,
                  controller: _scrollController,
                  itemBuilder: (listContext, listIndex) {
                    final taskDocRef = snapshot.data!.docs[listIndex];

                    int taskSavedDay = int.parse(
                        "${taskDocRef[Keys.taskDate][0]}${taskDocRef[Keys.taskDate][1]}");
                    int taskSavedMonth = int.parse(
                        "${taskDocRef[Keys.taskDate][3]}${taskDocRef[Keys.taskDate][4]}");
                    int taskSavedYear = int.parse(
                        "${taskDocRef[Keys.taskDate][6]}${taskDocRef[Keys.taskDate][7]}${taskDocRef[Keys.taskDate][8]}${taskDocRef[Keys.taskDate][9]}");
                    int taskSavedHour = int.parse(
                        "${taskDocRef[Keys.taskTime][0]}${taskDocRef[Keys.taskTime][1]}");
                    int taskSavedMinute = int.parse(
                        "${taskDocRef[Keys.taskTime][3]}${taskDocRef[Keys.taskTime][4]}");

                    DateTime taskSavedDate = DateTime(
                      taskSavedYear,
                      taskSavedMonth,
                      taskSavedDay,
                      taskSavedHour,
                      taskSavedMinute,
                    );

                    return Column(
                      children: [
                        FocusedMenuHolder(
                          onPressed: (() {}),
                          menuBoxDecoration: const BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.all(
                              Radius.circular(15),
                            ),
                          ),
                          openWithTap: true,
                          menuItems: [
                            if ((snapshot.data!.docs[listIndex]
                                    [Keys.taskStatus] !=
                                "Deleted"))
                              FocusedMenuItem(
                                title: (snapshot.data!.docs[listIndex]
                                            [Keys.taskStatus] ==
                                        "Pending")
                                    ? Text(
                                        "Done",
                                        style: TextStyle(
                                          color: AppColors.green,
                                        ),
                                      )
                                    : Text(
                                        "Un Done",
                                        style: TextStyle(
                                          color: AppColors.red,
                                        ),
                                      ),
                                trailingIcon: (snapshot.data!.docs[listIndex]
                                            [Keys.taskStatus] ==
                                        "Pending")
                                    ? Icon(
                                        Icons.done,
                                        color: AppColors.lightGreen,
                                        size: 20,
                                      )
                                    : Icon(
                                        Icons.cancel_outlined,
                                        color: AppColors.red,
                                        size: 20,
                                      ),
                                onPressed: (() async {
                                  String taskDocID = snapshot
                                      .data!.docs[listIndex].reference.id;

                                  if ((snapshot.data!.docs[listIndex]
                                              [Keys.taskStatus] !=
                                          "Pending") &&
                                      (taskSavedDate
                                              .difference(date)
                                              .inMinutes >
                                          0)) {
                                    updateTasks(
                                      taskDocID: taskDocID,
                                      status: snapshot.data!.docs[listIndex]
                                          [Keys.taskStatus],
                                      firestoreEmail: firestoreEmail,
                                      taskSavedDay: taskSavedDay,
                                      taskSavedHour: taskSavedHour,
                                      taskSavedMinute: taskSavedMinute,
                                      taskSavedMonth: taskSavedMonth,
                                      taskSavedYear: taskSavedYear,
                                    );
                                  } else if (snapshot.data!.docs[listIndex]
                                          [Keys.taskStatus] ==
                                      "Pending") {
                                    updateTasks(
                                      taskDocID: taskDocID,
                                      status: snapshot.data!.docs[listIndex]
                                          [Keys.taskStatus],
                                      firestoreEmail: firestoreEmail,
                                      taskSavedDay: taskSavedDay,
                                      taskSavedHour: taskSavedHour,
                                      taskSavedMinute: taskSavedMinute,
                                      taskSavedMonth: taskSavedMonth,
                                      taskSavedYear: taskSavedYear,
                                    );
                                  } else {
                                    ScaffoldMessenger.of(streamContext)
                                        .showSnackBar(
                                      SnackBar(
                                        backgroundColor:
                                            AppColors.backgroundColour,
                                        content: const Text(
                                          "This event is already outdated, Please",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        action: SnackBarAction(
                                          textColor: AppColors.white,
                                          label: "Edit",
                                          onPressed: (() {
                                            String taskDocID = snapshot.data!
                                                .docs[listIndex].reference.id;
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (nextPageContext) =>
                                                    NewTaskScreen(
                                                  taskName: snapshot
                                                          .data!.docs[listIndex]
                                                      [Keys.taskName],
                                                  taskDes: snapshot
                                                          .data!.docs[listIndex]
                                                      [Keys.taskDes],
                                                  taskNoti: snapshot
                                                          .data!.docs[listIndex]
                                                      [Keys.taskNotification],
                                                  taskTime: snapshot
                                                          .data!.docs[listIndex]
                                                      [Keys.taskTime],
                                                  taskType: snapshot
                                                          .data!.docs[listIndex]
                                                      [Keys.taskType],
                                                  taskDoc: taskDocID,
                                                  userEmail: firestoreEmail,
                                                  taskDate: snapshot
                                                          .data!.docs[listIndex]
                                                      [Keys.taskDate],
                                                ),
                                              ),
                                            );
                                          }),
                                        ),
                                      ),
                                    );
                                  }
                                }),
                                backgroundColor: AppColors.white,
                              ),
                            FocusedMenuItem(
                              title: Text(
                                "Edit",
                                style: TextStyle(
                                  color: AppColors.blackLow,
                                ),
                              ),
                              onPressed: (() {
                                String taskDocID =
                                    snapshot.data!.docs[listIndex].reference.id;
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (nextPageContext) => NewTaskScreen(
                                      taskName: snapshot.data!.docs[listIndex]
                                          [Keys.taskName],
                                      taskDes: snapshot.data!.docs[listIndex]
                                          [Keys.taskDes],
                                      taskNoti: snapshot.data!.docs[listIndex]
                                          [Keys.taskNotification],
                                      taskTime: snapshot.data!.docs[listIndex]
                                          [Keys.taskTime],
                                      taskType: snapshot.data!.docs[listIndex]
                                          [Keys.taskType],
                                      taskDoc: taskDocID,
                                      userEmail: firestoreEmail,
                                      taskDate: snapshot.data!.docs[listIndex]
                                          [Keys.taskDate],
                                    ),
                                  ),
                                );
                              }),
                              backgroundColor: AppColors.white,
                            ),
                            FocusedMenuItem(
                              title: ((snapshot.data!.docs[listIndex]
                                          [Keys.taskStatus] ==
                                      Keys.deleteStatus))
                                  ? Text(
                                      "Undo",
                                      style: TextStyle(
                                        color: AppColors.green,
                                      ),
                                    )
                                  : Text(
                                      "Delete",
                                      style: TextStyle(
                                        color: AppColors.red,
                                      ),
                                    ),
                              onPressed: (() {
                                String taskDocID =
                                    snapshot.data!.docs[listIndex].reference.id;

                                if (snapshot.data!.docs[listIndex]
                                        [Keys.taskStatus] !=
                                    Keys.deleteStatus) {
                                  deleteTasks(
                                    taskSavedDay: taskSavedDay,
                                    taskSavedYear: taskSavedYear,
                                    taskSavedMonth: taskSavedMonth,
                                    taskSavedMinute: taskSavedMinute,
                                    taskSavedHour: taskSavedHour,
                                    taskDocID: taskDocID,
                                    status: snapshot.data!.docs[listIndex]
                                        [Keys.taskStatus],
                                    firestoreEmail: firestoreEmail,
                                  );
                                }

                                // (taskSavedDate.difference(date).inMinutes >
                                //     0)

                                if ((snapshot.data!.docs[listIndex]
                                        [Keys.taskStatus] ==
                                    Keys.deleteStatus)) {
                                  if (taskSavedDate.difference(date).inMinutes >
                                      0) {
                                    undoTasks(
                                      taskSavedDay: taskSavedDay,
                                      taskSavedYear: taskSavedYear,
                                      taskSavedMonth: taskSavedMonth,
                                      taskSavedMinute: taskSavedMinute,
                                      taskSavedHour: taskSavedHour,
                                      taskDocID: taskDocID,
                                      status: snapshot.data!.docs[listIndex]
                                          [Keys.taskStatus],
                                      firestoreEmail: firestoreEmail,
                                    );
                                  } else {
                                    ScaffoldMessenger.of(streamContext)
                                        .showSnackBar(
                                      SnackBar(
                                        backgroundColor:
                                            AppColors.backgroundColour,
                                        content: const Text(
                                          "This event is already outdated, Please",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        action: SnackBarAction(
                                          textColor: AppColors.white,
                                          label: "Edit",
                                          onPressed: (() {
                                            String taskDocID = snapshot.data!
                                                .docs[listIndex].reference.id;
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (nextPageContext) =>
                                                    NewTaskScreen(
                                                  taskName: snapshot
                                                          .data!.docs[listIndex]
                                                      [Keys.taskName],
                                                  taskDes: snapshot
                                                          .data!.docs[listIndex]
                                                      [Keys.taskDes],
                                                  taskNoti: snapshot
                                                          .data!.docs[listIndex]
                                                      [Keys.taskNotification],
                                                  taskTime: snapshot
                                                          .data!.docs[listIndex]
                                                      [Keys.taskTime],
                                                  taskType: snapshot
                                                          .data!.docs[listIndex]
                                                      [Keys.taskType],
                                                  taskDoc: taskDocID,
                                                  userEmail: firestoreEmail,
                                                  taskDate: snapshot
                                                          .data!.docs[listIndex]
                                                      [Keys.taskDate],
                                                ),
                                              ),
                                            );
                                          }),
                                        ),
                                      ),
                                    );
                                  }
                                }
                              }),
                              backgroundColor: AppColors.white,
                            ),
                          ],
                          child: Container(
                            margin: const EdgeInsets.only(
                              bottom: 5,
                              top: 5,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: const BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(15),
                                topRight: Radius.circular(15),
                                bottomRight: Radius.circular(15),
                                bottomLeft: Radius.circular(15),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(15),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: AppColors.blackLow
                                              .withOpacity(0.2),
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.work_outline,
                                        color: AppColors.sky,
                                        size: 35,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 15,
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              3,
                                          child: Text(
                                            snapshot.data!.docs[listIndex]
                                                [Keys.taskName],
                                            // overflow: TextOverflow.ellipsis,
                                            softWrap: true,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 17,
                                              color: AppColors.blackLow,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              3,
                                          child: Text(
                                            snapshot.data!.docs[listIndex]
                                                [Keys.taskDes],
                                            // overflow: TextOverflow.ellipsis,
                                            softWrap: true,
                                            style: TextStyle(
                                              color: AppColors.blackLow
                                                  .withOpacity(0.5),
                                              fontWeight: FontWeight.w400,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Text(
                                  (int.parse("${snapshot.data!.docs[listIndex][Keys.taskTime][0]}") !=
                                          0)
                                      ? "${timeChange(("${snapshot.data!.docs[listIndex][Keys.taskTime][0]}${snapshot.data!.docs[listIndex][Keys.taskTime][1]}"))}${dayStatus(int.parse("${snapshot.data!.docs[listIndex][Keys.taskTime][0]}${snapshot.data!.docs[listIndex][Keys.taskTime][1]}"))}"
                                      : (int.parse(
                                                  "${snapshot.data!.docs[listIndex][Keys.taskTime][1]}") !=
                                              0)
                                          ? "${timeChange("${snapshot.data!.docs[listIndex][Keys.taskTime][1]}")}${dayStatus(int.parse("${snapshot.data!.docs[listIndex][Keys.taskTime][0]}${snapshot.data!.docs[listIndex][Keys.taskTime][1]}"))}"
                                          : "12${dayStatus(int.parse("${snapshot.data!.docs[listIndex][Keys.taskTime][0]}${snapshot.data!.docs[listIndex][Keys.taskTime][1]}"))}",
                                  textAlign: TextAlign.end,
                                  style: TextStyle(
                                    color: AppColors.blackLow.withOpacity(0.5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                  separatorBuilder:
                      (BuildContext separatorContext, int separatorIndex) {
                    return Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 10,
                      ),
                      height: 2,
                      color: AppColors.grey.withOpacity(0.1),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Container tasksBrief({
    required String value,
    required String head,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 10,
      ),
      height: 70,
      width: 70,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 20,
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Text(
              head,
              style: TextStyle(
                color: AppColors.white.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
