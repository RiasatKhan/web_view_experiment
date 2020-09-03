import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

ValueNotifier<GraphQLClient> client = ValueNotifier(
  GraphQLClient(
    cache: InMemoryCache(),
    link: HttpLink(uri: 'https://takemed-api.flightlocal.com/graphql'),
  ),
);

final String setDeviceTokenForDoctor = """
mutation setDeviceTokenForDoctor(\$deviceUuid: String!, \$deviceToken: String!) {
  setDeviceTokenForDoctor(
    deviceUuid: \$deviceUuid, 
    deviceToken: \$deviceToken,
    device: {
      deviceType: _ANDROID_
      appType: _NATIVE_
    }
  ) {
    message
    statusCode
    result {
      id
    }
  }
}
""";
