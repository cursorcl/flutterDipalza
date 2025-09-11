import 'package:flutter/material.dart';

import 'package:package_info/package_info.dart';

class VersionWidget extends StatefulWidget {
  VersionWidget();

  @override
  _VersionWidgetState createState() => _VersionWidgetState();
}

class _VersionWidgetState extends State<VersionWidget> {
  // String _appName;

  // String _packageName;

   String? _version;

   String? _buildNumber;

  @override
  void initState() {
    _cargaVersion();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Versión $_version+$_buildNumber',
        style: TextStyle(color: Colors.grey, fontSize: 10.0),
      ),
    );
  }

  _cargaVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    // _appName = packageInfo.appName;
    // _packageName = packageInfo.packageName;
    _version = packageInfo.version;
    _buildNumber = packageInfo.buildNumber;
    setState(() {});
  }
}
