import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend_seminario/services/api/consortium_api_service.dart';
import 'package:frontend_seminario/services/api/notifications_api_service.dart';
import 'package:frontend_seminario/services/api/unit_api_service.dart';
import 'package:frontend_seminario/services/api/user_api_service.dart';
import 'package:frontend_seminario/theme/theme.dart';
import 'package:frontend_seminario/components/base_scaffold.dart';
import 'package:frontend_seminario/services/storage_service.dart';

class UserNotificationsPage extends StatefulWidget {
  const UserNotificationsPage({super.key});

  @override
  State<UserNotificationsPage> createState() => _UserNotificationsPageState();
}

class _UserNotificationsPageState extends State<UserNotificationsPage> {
  bool _isLoading = true;
  List<dynamic> _notifications = [];
  bool _showUnread = true;
  final StorageService _storageService = StorageService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }
  
    Future<void> _createNotification(
      Map<String, dynamic> notificationData) async {
    final response =
        await NotificationsApiService.createNotification(notificationData);
    if (mounted) {
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notificación creada con éxito')),
        );
        _loadNotifications();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al crear la notificación')),
        );
      }
    }
  }


Future<void> _loadNotifications() async {
  setState(() {
    _isLoading = true;
  });

  try {
    final user = await _storageService.getUserData();
    if (user != null) {
      final userId = user['ID'];
      const userRole = 'user';
      final userNotificationsResponse =
          await NotificationsApiService.getNotificationsByUser(userId);
      final roleNotificationsResponse =
          await NotificationsApiService.getNotificationsByRole(userRole);
      List<Map<String, dynamic>> userNotifications = [];
      List<Map<String, dynamic>> roleNotifications = [];
      if (userNotificationsResponse.statusCode == 200) {
        var body = jsonDecode(userNotificationsResponse.body);
        if (body is List) {
          userNotifications = List<Map<String, dynamic>>.from(body);
        } else if (body is Map && body['data'] != null) {
          userNotifications = List<Map<String, dynamic>>.from(body['data']);
        }
      }
      if (roleNotificationsResponse.statusCode == 200) {
        var body = jsonDecode(roleNotificationsResponse.body);
        if (body is List) {
          roleNotifications = List<Map<String, dynamic>>.from(body);
        } else if (body is Map && body['data'] != null) {
          roleNotifications = List<Map<String, dynamic>>.from(body['data']);
        }
      }
      final Map<int, Map<String, dynamic>> notificationsMap = {};
      for (var notification in userNotifications) {
        if (notification['ID'] != null) {
          notificationsMap[notification['ID']] = notification;
        }
      }

      for (var notification in roleNotifications) {
        if (notification['ID'] != null) {
          notificationsMap[notification['ID']] = notification;
        }
      }
      final unitsResponse = await UserApiService.getUnitsByUser(userId);
      if (unitsResponse.statusCode == 200) {
        final units = List<Map<String, dynamic>>.from(jsonDecode(unitsResponse.body));
        for (var unit in units) {
          final unitId = unit['ID'];
          if (unitId != null) {
            final unitNotificationsResponse = await NotificationsApiService.getNotificationsByUnit(unitId);
            if (unitNotificationsResponse.statusCode == 200) {
              var body = jsonDecode(unitNotificationsResponse.body);
              if (body is List) {
                final unitNotifications = List<Map<String, dynamic>>.from(body);
                for (var notification in unitNotifications) {
                  if (notification['ID'] != null) {
                    notificationsMap[notification['ID']] = notification;
                  }
                }
              }
            }
            final consortiumResponse = await ConsortiumApiService.getConsortiumByUnit(unitId);
            if (consortiumResponse.statusCode == 200) {
              var body = jsonDecode(consortiumResponse.body);
              if (body != null) {
                if (body is List) {
                  for (var consortium in body) {
                    final consortiumId = consortium['ID'];
                    if (consortiumId != null) {
                      final consortiumNotificationsResponse =
                          await NotificationsApiService.getNotificationsByConsortium(consortiumId);
                      if (consortiumNotificationsResponse.statusCode == 200) {
                        var consortiumBody = jsonDecode(consortiumNotificationsResponse.body);
                        if (consortiumBody is List) {
                          final consortiumNotifications = List<Map<String, dynamic>>.from(consortiumBody);
                          for (var notification in consortiumNotifications) {
                            if (notification['ID'] != null) {
                              notificationsMap[notification['ID']] = notification;
                            }
                          }
                        }
                      }
                    }
                  }
                } else {
                  if (body is Map && body.containsKey('ID')) {
                    final consortiumId = body['ID'];
                    if (consortiumId != null) {
                      final consortiumNotificationsResponse =
                          await NotificationsApiService.getNotificationsByConsortium(consortiumId);
                      if (consortiumNotificationsResponse.statusCode == 200) {
                        var consortiumBody = jsonDecode(consortiumNotificationsResponse.body);
                        if (consortiumBody is List) {
                          final consortiumNotifications = List<Map<String, dynamic>>.from(consortiumBody);
                          for (var notification in consortiumNotifications) {
                            if (notification['ID'] != null) {
                              notificationsMap[notification['ID']] = notification;
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            } 
          }
        }
      }
      final deduplicatedNotifications = notificationsMap.values.toList();
      if (mounted) {
        setState(() {
          _notifications = deduplicatedNotifications;
          _isLoading = false;
        });
      }
    }
  } catch (e) {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading notifications: $e')),
      );
    }
  }
}

  Future<void> _markNotificationAsRead(int notificationId) async {
    final response =
        await NotificationsApiService.markNotificationAsRead(notificationId);
    if (response.statusCode == 200 && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notificación marcada como leída')),
      );
      _loadNotifications();
    } else if(mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al marcar la notificación')),
      );
    }
  }

  List<dynamic> get _filteredNotifications => _notifications
      .where((notification) =>
          notification['is_read'] == !_showUnread)
      .toList();
void _showCreateNotificationModal() {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController messageController = TextEditingController();
  int? selectedConsortiumId;
  int? selectedUnitId;
  int? targetUserId;
  String? targetUserRole;

  List<dynamic> consortiums = [];
  List<dynamic> units = [];
  List<dynamic> users = [];
  List<String> roles = ['admin', 'user'];

  void loadConsortiums(StateSetter setModalState) async {
    try {
      final response = await ConsortiumApiService.getAllConsortiums();
      if (response.statusCode == 200) {
        final fetchedConsortiums = jsonDecode(response.body);
        setModalState(() {
          consortiums = fetchedConsortiums;
        });
      }
    } catch (e) {
      setModalState(() {
        consortiums = [];
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading consortiums: $e')),
        );
      }
    }
  }

  void loadUnitsByConsortium(
      int consortiumId, StateSetter setModalState) async {
    try {
      final response =
          await UnitApiService.getUnitsByConsortium(consortiumId);
      if (response.statusCode == 200) {
        final fetchedUnits = jsonDecode(response.body);
        setModalState(() {
          units = fetchedUnits;
        });
      }
    } catch (e) {
      setModalState(() {
        units = [];
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading units: $e')),
        );
      }
    }
  }

  void loadUsers(StateSetter setModalState) async {
    try {
      final response = await UserApiService.getActiveUsers();
      if (response.statusCode == 200) {
        final fetchedUsers = jsonDecode(response.body);
        setModalState(() {
          users = fetchedUsers;
        });
      }
    } catch (e) {
      setModalState(() {
        users = [];
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading users: $e')),
        );
      }
    }
  }

  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
          if (consortiums.isEmpty) {
            loadConsortiums(setModalState);
          }
          if (users.isEmpty) {
            loadUsers(setModalState);
          }
          return AlertDialog(
            backgroundColor: AppTheme.lightBackground,
            title: Text(
              'Crear Notificación',
              style:
                  AppTheme.titleMedium.copyWith(color: AppTheme.primaryColor),
            ),
            content: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: titleController,
                      style: AppTheme.textMedium,
                      decoration: const InputDecoration(
                        labelText: 'Título',
                        labelStyle: AppTheme.textSmall,
                        filled: true,
                        fillColor: AppTheme.lightBackground,
                        border: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: AppTheme.primaryColor),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, ingrese un título';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: messageController,
                      style: AppTheme.textMedium,
                      decoration: const InputDecoration(
                        labelText: 'Mensaje',
                        labelStyle: AppTheme.textSmall,
                        filled: true,
                        fillColor: AppTheme.lightBackground,
                        border: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: AppTheme.primaryColor),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, ingrese un mensaje';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        labelText: 'Seleccione un Consorcio (Opcional)',
                        labelStyle: AppTheme.textSmall,
                        filled: true,
                        fillColor: AppTheme.lightBackground,
                        border: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: AppTheme.primaryColor),
                        ),
                      ),
                      value: selectedConsortiumId,
                      items: consortiums
                          .map<DropdownMenuItem<int>>((consortium) {
                        return DropdownMenuItem<int>(
                          value: consortium['ID'],
                          child: Text(consortium['name'],
                              style: AppTheme.textSmall),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setModalState(() {
                          selectedConsortiumId = value;
                          selectedUnitId = null;
                          if (value != null) {
                            loadUnitsByConsortium(value, setModalState);
                          } else {
                            units = [];
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        labelText: 'Seleccione una Propiedad',
                        labelStyle: AppTheme.textSmall,
                        filled: true,
                        fillColor: AppTheme.lightBackground,
                        border: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: AppTheme.primaryColor),
                        ),
                      ),
                      value: selectedUnitId,
                      items: units.map<DropdownMenuItem<int>>((unit) {
                        return DropdownMenuItem<int>(
                          value: unit['ID'],
                          child: Text(unit['name'],
                              style: AppTheme.textSmall),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setModalState(() {
                          selectedUnitId = value;
                          selectedConsortiumId = null;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        labelText: 'Seleccione un Usuario (Opcional)',
                        labelStyle: AppTheme.textSmall,
                        filled: true,
                        fillColor: AppTheme.lightBackground,
                        border: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: AppTheme.primaryColor),
                        ),
                      ),
                      value: targetUserId,
                      items: users.map<DropdownMenuItem<int>>((user) {
                        return DropdownMenuItem<int>(
                          value: user['ID'],
                          child: Text('${user['name']} ${user['surname']}',
                              style: AppTheme.textSmall),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setModalState(() {
                          targetUserId = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Tipo de Usuario (Opcional)',
                        labelStyle: AppTheme.textSmall,
                        filled: true,
                        fillColor: AppTheme.lightBackground,
                        border: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: AppTheme.primaryColor),
                        ),
                      ),
                      value: targetUserRole,
                      items: roles.map<DropdownMenuItem<String>>((role) {
                        return DropdownMenuItem<String>(
                          value: role,
                          child: Text(role, style: AppTheme.textSmall),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setModalState(() {
                          targetUserRole = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                child: Text(
                  'Cancelar',
                  style: AppTheme.textSmall
                      .copyWith(color: AppTheme.dangerColor),
                ),
              ),
              TextButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final user = await _storageService.getUserData();

                    if (user != null) {
                      final notificationData = {
                        'title': titleController.text,
                        'message': messageController.text,
                        'sender_user_id': user['ID'],
                        'target_consortium_id': selectedConsortiumId,
                        'target_unit_id': selectedUnitId,
                        'target_user_id': targetUserId,
                        'target_role': targetUserRole,
                      };
                      await _createNotification(notificationData);
                      if (dialogContext.mounted) {
                        Navigator.pop(dialogContext);
                      }
                    } else {
                      if (dialogContext.mounted) {
                        ScaffoldMessenger.of(dialogContext).showSnackBar(
                          const SnackBar(
                            content:
                                Text('Error al obtener el usuario actual'),
                          ),
                        );
                      }
                    }
                  }
                },
                child: Text(
                  'Crear',
                  style: AppTheme.textSmall
                      .copyWith(color: AppTheme.successColor),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}

 

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: 'Notificaciones de Usuario',
      storageService: _storageService,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                                    ElevatedButton.icon(
                    onPressed: _showCreateNotificationModal,
                    icon: const Icon(Icons.add),
                    label: const Text('Crear Notificación'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _showUnread
                            ? 'Notificaciones No Leídas'
                            : 'Notificaciones Leídas',
                        style: AppTheme.titleMedium
                            .copyWith(color: AppTheme.primaryColor),
                      ),
                      Switch(
                        value: _showUnread,
                        onChanged: (value) {
                          setState(() {
                            _showUnread = value;
                          });
                        },
                        activeColor: AppTheme.primaryColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _filteredNotifications.isEmpty
                        ? const Center(
                            child: Text(
                              'No hay notificaciones disponibles',
                              style: AppTheme.textMedium,
                            ),
                          )
                        : ListView.builder(
                            itemCount: _filteredNotifications.length,
                            itemBuilder: (context, index) {
                              final notification =
                                  _filteredNotifications[index];
                              return Card(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: ListTile(
                                  title: Text(
                                    notification['title'],
                                    style: AppTheme.textMedium,
                                  ),
                                  subtitle: Text(
                                    notification['message'],
                                    style: AppTheme.textSmall,
                                  ),
                                  trailing: _showUnread
                                      ? IconButton(
                                          icon: const Icon(
                                            Icons.check,
                                            color: AppTheme.successColor,
                                          ),
                                          onPressed: () {
                                            _markNotificationAsRead(
                                                notification['ID']);
                                          },
                                        )
                                      : null,
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
      ), isAdmin: false,
    );
  }
}
