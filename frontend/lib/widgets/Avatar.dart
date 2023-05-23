import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Auth/customAuth.dart';
import '../utils/global_variable.dart';

class UserAvatar extends StatelessWidget {
  final String userId;
  final double? width;
  final double? height;
  const UserAvatar({
    Key? key,
    required this.userId,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: "$ip/api/user/downloadavatar?name=${userId}.jpg",
        httpHeaders: {
          'Authorization': CustomAuth.currentUser.jwt,
        },
        placeholder: (context, url) => const CircularProgressIndicator(),
        errorWidget: (context, url, error) => const Icon(Icons.error),
        width: width == null ? 32 : width,
        height: height == null ? 32 : height,
      ),
    );
  }
}
