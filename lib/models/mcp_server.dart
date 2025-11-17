/// MCP服务器配置模型
class McpServer {
  final String id;
  final String name;
  final String url;
  final McpProtocol protocol;
  final Map<String, String>? headers;
  final bool enabled;

  McpServer({
    required this.id,
    required this.name,
    required this.url,
    required this.protocol,
    this.headers,
    this.enabled = true,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'url': url,
        'protocol': protocol.name,
        'headers': headers,
        'enabled': enabled,
      };

  factory McpServer.fromJson(Map<String, dynamic> json) => McpServer(
        id: json['id'],
        name: json['name'],
        url: json['url'],
        protocol: McpProtocol.values.firstWhere(
          (e) => e.name == json['protocol'],
          orElse: () => McpProtocol.sse,
        ),
        headers: json['headers'] != null
            ? Map<String, String>.from(json['headers'])
            : null,
        enabled: json['enabled'] ?? true,
      );

  McpServer copyWith({
    String? id,
    String? name,
    String? url,
    McpProtocol? protocol,
    Map<String, String>? headers,
    bool? enabled,
  }) =>
      McpServer(
        id: id ?? this.id,
        name: name ?? this.name,
        url: url ?? this.url,
        protocol: protocol ?? this.protocol,
        headers: headers ?? this.headers,
        enabled: enabled ?? this.enabled,
      );
}

/// MCP协议类型
enum McpProtocol {
  sse, // Server-Sent Events
  https, // HTTPS
}
