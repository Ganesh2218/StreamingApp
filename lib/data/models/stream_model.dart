import 'package:equatable/equatable.dart';

enum StreamPlatform { youtube, facebook, custom }

enum StreamStatus {
  offline,
  connecting,
  live,
  rtmpConnecting,
  rtmpConnected,
  rtmpFailed,
  ended,
}

extension StreamStatusLabel on StreamStatus {
  String get label {
    switch (this) {
      case StreamStatus.offline:
        return 'Offline';
      case StreamStatus.connecting:
        return 'Connecting';
      case StreamStatus.live:
        return 'Live';
      case StreamStatus.rtmpConnecting:
        return 'RTMP Connecting';
      case StreamStatus.rtmpConnected:
        return 'RTMP Connected';
      case StreamStatus.rtmpFailed:
        return 'RTMP Failed';
      case StreamStatus.ended:
        return 'Ended';
    }
  }
}

class StreamModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final String channelName;
  final String rtmpServerUrl;
  final String streamKey;
  final StreamPlatform platform;
  final String hostId;
  final String hostName;
  final String hostAvatar;
  final StreamStatus status;
  final int viewerCount;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final bool isFeatured;
  final String thumbnailUrl;

  const StreamModel({
    required this.id,
    required this.title,
    this.description = '',
    required this.channelName,
    this.rtmpServerUrl = '',
    this.streamKey = '',
    this.platform = StreamPlatform.custom,
    required this.hostId,
    required this.hostName,
    this.hostAvatar = '',
    this.status = StreamStatus.offline,
    this.viewerCount = 0,
    this.startedAt,
    this.endedAt,
    this.isFeatured = false,
    this.thumbnailUrl = '',
  });

  bool get isLive => status == StreamStatus.live || status == StreamStatus.rtmpConnected;

  String get fullRtmpUrl {
    if (rtmpServerUrl.isEmpty || streamKey.isEmpty) return '';
    final base = rtmpServerUrl.endsWith('/') ? rtmpServerUrl : '$rtmpServerUrl/';
    return '$base$streamKey';
  }

  StreamModel copyWith({
    String? id,
    String? title,
    String? description,
    String? channelName,
    String? rtmpServerUrl,
    String? streamKey,
    StreamPlatform? platform,
    String? hostId,
    String? hostName,
    String? hostAvatar,
    StreamStatus? status,
    int? viewerCount,
    DateTime? startedAt,
    DateTime? endedAt,
    bool? isFeatured,
    String? thumbnailUrl,
  }) {
    return StreamModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      channelName: channelName ?? this.channelName,
      rtmpServerUrl: rtmpServerUrl ?? this.rtmpServerUrl,
      streamKey: streamKey ?? this.streamKey,
      platform: platform ?? this.platform,
      hostId: hostId ?? this.hostId,
      hostName: hostName ?? this.hostName,
      hostAvatar: hostAvatar ?? this.hostAvatar,
      status: status ?? this.status,
      viewerCount: viewerCount ?? this.viewerCount,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      isFeatured: isFeatured ?? this.isFeatured,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'channelName': channelName,
        'rtmpServerUrl': rtmpServerUrl,
        'streamKey': streamKey,
        'platform': platform.name,
        'hostId': hostId,
        'hostName': hostName,
        'hostAvatar': hostAvatar,
        'status': status.name,
        'viewerCount': viewerCount,
        'startedAt': startedAt?.toIso8601String(),
        'endedAt': endedAt?.toIso8601String(),
        'isFeatured': isFeatured,
        'thumbnailUrl': thumbnailUrl,
      };

  factory StreamModel.fromJson(Map<String, dynamic> json) => StreamModel(
        id: json['id'] as String,
        title: json['title'] as String,
        description: (json['description'] as String?) ?? '',
        channelName: json['channelName'] as String,
        rtmpServerUrl: (json['rtmpServerUrl'] as String?) ?? '',
        streamKey: (json['streamKey'] as String?) ?? '',
        platform: StreamPlatform.values.firstWhere(
          (p) => p.name == json['platform'],
          orElse: () => StreamPlatform.custom,
        ),
        hostId: json['hostId'] as String,
        hostName: json['hostName'] as String,
        hostAvatar: (json['hostAvatar'] as String?) ?? '',
        status: StreamStatus.values.firstWhere(
          (s) => s.name == json['status'],
          orElse: () => StreamStatus.offline,
        ),
        viewerCount: (json['viewerCount'] as int?) ?? 0,
        startedAt: json['startedAt'] != null
            ? DateTime.parse(json['startedAt'] as String)
            : null,
        endedAt: json['endedAt'] != null
            ? DateTime.parse(json['endedAt'] as String)
            : null,
        isFeatured: (json['isFeatured'] as bool?) ?? false,
        thumbnailUrl: (json['thumbnailUrl'] as String?) ?? '',
      );

  @override
  List<Object?> get props => [id, channelName, status, viewerCount];
}
