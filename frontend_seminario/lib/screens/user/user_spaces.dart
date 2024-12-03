import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend_seminario/services/api/user_api_service.dart';
import 'package:intl/intl.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:frontend_seminario/services/api/consortium_api_service.dart';
import 'package:frontend_seminario/services/api/spaces_api_service.dart';
import 'package:frontend_seminario/services/api/reservations_api_service.dart';
import 'package:frontend_seminario/theme/theme.dart';
import 'package:frontend_seminario/components/base_scaffold.dart';
import 'package:frontend_seminario/services/storage_service.dart';

class UserSpacesPage extends StatefulWidget {
  const UserSpacesPage({Key? key}) : super(key: key);

  @override
  State<UserSpacesPage> createState() => _UserSpacesPageState();
}

class _UserSpacesPageState extends State<UserSpacesPage> {
  final StorageService storageService = StorageService();

  List<dynamic> spaces = [];
  List<dynamic> consortiums = [];
  int? selectedConsortiumId;
  int? currentUserId;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchConsortiums();
  }

  Future<void> _fetchUserData() async {
    final user = await storageService.getUserData();
    if (user != null) {
      setState(() {
        currentUserId = user['ID'];
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al obtener el usuario actual')),
      );
    }
  }

  void _navigateToReservations() {
    _openReservationsModal();
  }

  Future<void> _fetchConsortiums() async {
    final response = await ConsortiumApiService.getAllConsortiums();
    if (response.statusCode == 200) {
      setState(() {
        consortiums = jsonDecode(response.body);
        if (consortiums.isNotEmpty) {
          selectedConsortiumId = consortiums[0]['ID'];
          _fetchSpacesByConsortium(selectedConsortiumId!);
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al obtener consorcios')),
      );
    }
  }

  Future<void> _fetchSpacesByConsortium(int consortiumId) async {
    final response = await SpacesApiService.getSpacesByConsortium(consortiumId);
    if (response.statusCode == 200) {
      setState(() {
        spaces = jsonDecode(response.body);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al obtener espacios')),
      );
    }
  }

  void _openAddSpaceModal() {
    String? name;
    String? operationalStartTime;
    String? operationalEndTime;
    String status = 'active';
    int? consortiumId = selectedConsortiumId;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Agregar Espacio', style: AppTheme.titleMedium),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  style: AppTheme.bodyMedium,
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                    labelStyle: AppTheme.textSmall,
                    filled: true,
                    fillColor: AppTheme.lightBackground,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.primaryColor),
                    ),
                  ),
                  onChanged: (value) {
                    name = value;
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  style: AppTheme.bodyMedium,
                  decoration: const InputDecoration(
                    labelText: 'Hora de Inicio Operativo (HH:mm)',
                    labelStyle: AppTheme.textSmall,
                    hintText: 'Ejemplo: 08:00',
                    filled: true,
                    fillColor: AppTheme.lightBackground,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.primaryColor),
                    ),
                  ),
                  onChanged: (value) {
                    operationalStartTime = value;
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  style: AppTheme.bodyMedium,
                  decoration: const InputDecoration(
                    labelText: 'Hora de Fin Operativo (HH:mm)',
                    labelStyle: AppTheme.textSmall,
                    hintText: 'Ejemplo: 20:00',
                    filled: true,
                    fillColor: AppTheme.lightBackground,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.primaryColor),
                    ),
                  ),
                  onChanged: (value) {
                    operationalEndTime = value;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: status,
                  decoration: const InputDecoration(
                    labelText: 'Estado',
                    labelStyle: AppTheme.textSmall,
                    filled: true,
                    fillColor: AppTheme.lightBackground,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.primaryColor),
                    ),
                  ),
                  style: AppTheme.bodyMedium,
                  items: ['active', 'inactive'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value == 'active' ? 'Activo' : 'Inactivo',
                        style: AppTheme.bodyMedium,
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    status = newValue!;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar', style: AppTheme.textSmall),
            ),
            ElevatedButton(
              onPressed: () async {
                if (name == null ||
                    name!.isEmpty ||
                    operationalStartTime == null ||
                    operationalStartTime!.isEmpty ||
                    operationalEndTime == null ||
                    operationalEndTime!.isEmpty ||
                    consortiumId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Por favor, complete todos los campos')),
                  );
                  return;
                }
                Map<String, dynamic> spaceData = {
                  'name': name,
                  'consortium_id': consortiumId,
                  'operational_start_time': operationalStartTime,
                  'operational_end_time': operationalEndTime,
                  'status': status,
                };
                final response = await SpacesApiService.createSpace(spaceData);
                if (response.statusCode == 200 || response.statusCode == 201) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Espacio creado con éxito')),
                  );
                  _fetchSpacesByConsortium(consortiumId);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Error al crear el espacio')),
                  );
                }
              },
              child: const Text('Agregar', style: AppTheme.textSmall),
            ),
          ],
        );
      },
    );
  }

  void _editSpace(Map<String, dynamic> space) {
    String? name = space['name'];
    String? operationalStartTime = space['operational_start_time'];
    String? operationalEndTime = space['operational_end_time'];
    String status = space['status'];
    int? consortiumId = space['consortium_id'];
    TextEditingController nameController = TextEditingController(text: name);
    TextEditingController startTimeController =
        TextEditingController(text: operationalStartTime);
    TextEditingController endTimeController =
        TextEditingController(text: operationalEndTime);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Editar Espacio', style: AppTheme.titleMedium),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  style: AppTheme.bodyMedium,
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                    labelStyle: AppTheme.textSmall,
                    filled: true,
                    fillColor: AppTheme.lightBackground,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.primaryColor),
                    ),
                  ),
                  onChanged: (value) {
                    name = value;
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: startTimeController,
                  style: AppTheme.bodyMedium,
                  decoration: const InputDecoration(
                    labelText: 'Hora de Inicio Operativo (HH:mm)',
                    labelStyle: AppTheme.textSmall,
                    hintText: 'Ejemplo: 08:00',
                    filled: true,
                    fillColor: AppTheme.lightBackground,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.primaryColor),
                    ),
                  ),
                  onChanged: (value) {
                    operationalStartTime = value;
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: endTimeController,
                  style: AppTheme.bodyMedium,
                  decoration: const InputDecoration(
                    labelText: 'Hora de Fin Operativo (HH:mm)',
                    labelStyle: AppTheme.textSmall,
                    hintText: 'Ejemplo: 20:00',
                    filled: true,
                    fillColor: AppTheme.lightBackground,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.primaryColor),
                    ),
                  ),
                  onChanged: (value) {
                    operationalEndTime = value;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: status,
                  decoration: const InputDecoration(
                    labelText: 'Estado',
                    labelStyle: AppTheme.textSmall,
                    filled: true,
                    fillColor: AppTheme.lightBackground,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.primaryColor),
                    ),
                  ),
                  style: AppTheme.bodyMedium,
                  items: ['active', 'inactive'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value == 'active' ? 'Activo' : 'Inactivo',
                        style: AppTheme.bodyMedium,
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    status = newValue!;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar', style: AppTheme.textSmall),
            ),
            ElevatedButton(
              onPressed: () async {
                if (name == null ||
                    name!.isEmpty ||
                    operationalStartTime == null ||
                    operationalStartTime!.isEmpty ||
                    operationalEndTime == null ||
                    operationalEndTime!.isEmpty ||
                    consortiumId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Por favor, complete todos los campos')),
                  );
                  return;
                }
                Map<String, dynamic> spaceData = {
                  'name': name,
                  'operational_start_time': operationalStartTime,
                  'operational_end_time': operationalEndTime,
                  'status': status,
                };
                final response =
                    await SpacesApiService.updateSpace(space['ID'], spaceData);
                if (response.statusCode == 200) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Espacio actualizado con éxito')),
                  );
                  _fetchSpacesByConsortium(selectedConsortiumId!);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Error al actualizar el espacio')),
                  );
                }
              },
              child: const Text('Guardar', style: AppTheme.textSmall),
            ),
          ],
        );
      },
    );
  }

  void _deleteSpace(int spaceId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title:
              const Text('Confirmar eliminación', style: AppTheme.titleMedium),
          content: const Text(
            '¿Está seguro de que desea eliminar este espacio?',
            style: AppTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar', style: AppTheme.textSmall),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Eliminar', style: AppTheme.textSmall),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      final response = await SpacesApiService.deleteSpace(spaceId);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Espacio eliminado con éxito')),
        );
        _fetchSpacesByConsortium(selectedConsortiumId!);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al eliminar el espacio')),
        );
      }
    }
  }

  // New method to open the reservations modal
void _openReservationsModal() {
  int? selectedConsortiumId;
  List<dynamic> reservations = [];
  bool isLoading = false;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Ver Reservas', style: AppTheme.titleMedium),
            content: Container(
              width: double.maxFinite,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.6,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Consortium Selector
                      DropdownButtonFormField<int>(
                        value: selectedConsortiumId,
                        decoration: const InputDecoration(
                          labelText: 'Seleccionar Consorcio',
                          labelStyle: AppTheme.textSmall,
                          filled: true,
                          fillColor: AppTheme.lightBackground,
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: AppTheme.primaryColor),
                          ),
                        ),
                        style: AppTheme.bodyMedium,
                        items: consortiums.map<DropdownMenuItem<int>>((consortium) {
                          return DropdownMenuItem<int>(
                            value: consortium['ID'],
                            child: Text(
                              consortium['name'] ?? 'Sin Nombre',
                              style: AppTheme.bodyMedium,
                            ),
                          );
                        }).toList(),
                        onChanged: (int? newValue) async {
                          setState(() {
                            selectedConsortiumId = newValue;
                            isLoading = true;
                            reservations = []; // Clear previous reservations
                          });
                          // Fetch reservations for the selected consortium
                          final response = await ReservationsApiService.getReservationsByConsortium(selectedConsortiumId!);
                          if (response.statusCode == 200) {
                            List<dynamic> fetchedReservations = jsonDecode(response.body);

                            // Fetch user data for each reservation
                            List<Future<void>> userFutures = [];
                            for (var reservation in fetchedReservations) {
                              Future<void> userFuture = UserApiService.getUserByID(reservation['user_id']).then((userResponse) {
                                if (userResponse.statusCode == 200) {
                                  reservation['User'] = jsonDecode(userResponse.body);
                                } else {
                                  reservation['User'] = {'name': 'Desconocido', 'surname': ''};
                                }
                              });
                              userFutures.add(userFuture);
                            }

                            // Wait for all user data to be fetched
                            await Future.wait(userFutures);

                            setState(() {
                              reservations = fetchedReservations;
                              isLoading = false;
                            });
                          } else {
                            setState(() {
                              isLoading = false;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Error al obtener reservas')),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      if (isLoading)
                        const Center(child: CircularProgressIndicator())
                      else if (reservations.isEmpty && selectedConsortiumId != null)
                        const Text('No hay reservas para este consorcio', style: AppTheme.bodyMedium)
                      else
                        Column(
                          children: reservations.map<Widget>((reservation) {
                            final spaceName = reservation['Space']?['name'] ?? 'Sin Nombre';
                            final consortiumId = reservation['consortium_id'];
                            final consortiumName = consortiums.firstWhere((c) => c['ID'] == consortiumId)['name'] ?? 'Sin Nombre';
                            final reservationDate = reservation['reservation_date'];
                            final startTime = reservation['start_time'];
                            final endTime = reservation['end_time'];
                            final userName = reservation['User']?['name'] ?? '';
                            final userSurname = reservation['User']?['surname'] ?? '';
                            final userFullName = '$userName $userSurname';

                            return ListTile(
                              title: Text('Espacio: $spaceName', style: AppTheme.bodyMedium),
                              subtitle: Text(
                                'Consorcio: $consortiumName\nReservado por: $userFullName\nFecha: $reservationDate\nHora: $startTime - $endTime',
                                style: AppTheme.textSmall,
                              ),
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cerrar', style: AppTheme.textSmall),
              ),
            ],
          );
        },
      );
    },
  );
}

  void _filterSpacesByConsortium(int consortiumId) {
    setState(() {
      selectedConsortiumId = consortiumId;
      _fetchSpacesByConsortium(consortiumId);
    });
  }

  // Method to open the reservation modal
  void _openReservationModal(Map<String, dynamic> space) {
    String? reservationDate;
    String? startTime;
    String? endTime;
    int? spaceId = space['ID'];
    int? consortiumId = selectedConsortiumId;

    // Controllers for date and time pickers
    TextEditingController dateController = TextEditingController();
    TextEditingController startTimeController = TextEditingController();
    TextEditingController endTimeController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Reservar ${space['name']}', style: AppTheme.titleMedium),
          content: SingleChildScrollView(
            child: Column(
              children: [
                // Date Picker for Reservation Date
                TextField(
                  controller: dateController,
                  style: AppTheme.bodyMedium,
                  decoration: const InputDecoration(
                    labelText: 'Fecha de Reserva',
                    labelStyle: AppTheme.textSmall,
                    hintText: 'Seleccionar fecha',
                    filled: true,
                    fillColor: AppTheme.lightBackground,
                    suffixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.primaryColor),
                    ),
                  ),
                  readOnly: true,
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                      locale: const Locale('es', 'ES'),
                      builder: (BuildContext context, Widget? child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: ColorScheme.light(
                              primary: AppTheme.primaryColor,
                              onPrimary: Colors.white,
                              surface: AppTheme.lightBackground,
                              onSurface: Colors.black,
                            ),
                            dialogBackgroundColor: AppTheme.lightBackground,
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (pickedDate != null) {
                      reservationDate =
                          DateFormat('yyyy-MM-dd').format(pickedDate);
                      dateController.text =
                          DateFormat('dd/MM/yyyy').format(pickedDate);
                    }
                  },
                ),
                const SizedBox(height: 16),
                // Time Picker for Start Time
                TextField(
                  controller: startTimeController,
                  style: AppTheme.bodyMedium,
                  decoration: const InputDecoration(
                    labelText: 'Hora de Inicio',
                    labelStyle: AppTheme.textSmall,
                    hintText: 'Seleccionar hora de inicio',
                    filled: true,
                    fillColor: AppTheme.lightBackground,
                    suffixIcon: Icon(Icons.access_time),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.primaryColor),
                    ),
                  ),
                  readOnly: true,
                  onTap: () async {
                    TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                      builder: (BuildContext context, Widget? child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: ColorScheme.light(
                              primary: AppTheme.primaryColor,
                              onPrimary: Colors.white,
                              surface: AppTheme.lightBackground,
                              onSurface: Colors.black,
                            ),
                            timePickerTheme: const TimePickerThemeData(
                              dialBackgroundColor: AppTheme.lightBackground,
                            ),
                            dialogBackgroundColor: AppTheme.lightBackground,
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (pickedTime != null) {
                      // Convert to 24-hour format
                      final now = DateTime.now();
                      final dt = DateTime(now.year, now.month, now.day,
                          pickedTime.hour, pickedTime.minute);
                      startTime = DateFormat('HH:mm').format(dt);
                      startTimeController.text = startTime!;
                    }
                  },
                ),
                const SizedBox(height: 16),
                // Time Picker for End Time
                TextField(
                  controller: endTimeController,
                  style: AppTheme.bodyMedium,
                  decoration: const InputDecoration(
                    labelText: 'Hora de Fin',
                    labelStyle: AppTheme.textSmall,
                    hintText: 'Seleccionar hora de fin',
                    filled: true,
                    fillColor: AppTheme.lightBackground,
                    suffixIcon: Icon(Icons.access_time),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.primaryColor),
                    ),
                  ),
                  readOnly: true,
                  onTap: () async {
                    TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                      builder: (BuildContext context, Widget? child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: ColorScheme.light(
                              primary: AppTheme.primaryColor,
                              onPrimary: Colors.white,
                              surface: AppTheme.lightBackground,
                              onSurface: Colors.black,
                            ),
                            timePickerTheme: const TimePickerThemeData(
                              dialBackgroundColor: AppTheme.lightBackground,
                            ),
                            dialogBackgroundColor: AppTheme.lightBackground,
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (pickedTime != null) {
                      // Convert to 24-hour format
                      final now = DateTime.now();
                      final dt = DateTime(now.year, now.month, now.day,
                          pickedTime.hour, pickedTime.minute);
                      endTime = DateFormat('HH:mm').format(dt);
                      endTimeController.text = endTime!;
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar', style: AppTheme.textSmall),
            ),
            ElevatedButton(
              onPressed: () async {
                if (reservationDate == null ||
                    reservationDate!.isEmpty ||
                    startTime == null ||
                    startTime!.isEmpty ||
                    endTime == null ||
                    endTime!.isEmpty ||
                    spaceId == null ||
                    consortiumId == null ||
                    currentUserId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Por favor, complete todos los campos')),
                  );
                  return;
                }

                // Validate that start time is before end time
                DateTime startDateTime =
                    DateTime.parse('$reservationDate $startTime');
                DateTime endDateTime =
                    DateTime.parse('$reservationDate $endTime');

                if (endDateTime.isBefore(startDateTime) ||
                    endDateTime.isAtSameMomentAs(startDateTime)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'La hora de fin debe ser posterior a la hora de inicio')),
                  );
                  return;
                }

                // Validate that reservation times are within operational hours
                DateTime operationalStart = DateTime.parse(
                    '$reservationDate ${space['operational_start_time']}');
                DateTime operationalEnd = DateTime.parse(
                    '$reservationDate ${space['operational_end_time']}');

                if (startDateTime.isBefore(operationalStart) ||
                    endDateTime.isAfter(operationalEnd)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'La reserva debe estar dentro del horario operativo')),
                  );
                  return;
                }

                Map<String, dynamic> reservationData = {
                  'user_id': currentUserId,
                  'consortium_id': consortiumId,
                  'space_id': spaceId,
                  'reservation_date': reservationDate,
                  'start_time': startTime,
                  'end_time': endTime,
                };

                final response = await ReservationsApiService.createReservation(
                    reservationData);
                if (response.statusCode == 200 || response.statusCode == 201) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Reserva creada con éxito')),
                  );
                  // Optionally, refresh reservations or update UI
                } else if (response.statusCode == 409) {
                  // Conflict, reservation overlaps with existing one
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'El espacio ya está reservado en ese horario')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Error al crear la reserva')),
                  );
                }
              },
              child: const Text('Reservar', style: AppTheme.textSmall),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: 'Espacios Comunes',
      isAdmin: false,
      storageService: storageService,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Consortium Selector
            DropdownButtonFormField<int>(
              value: selectedConsortiumId,
              decoration: const InputDecoration(
                labelText: 'Seleccionar Consorcio',
                labelStyle: AppTheme.textSmall,
                filled: true,
                fillColor: AppTheme.lightBackground,
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.primaryColor),
                ),
              ),
              style: AppTheme.bodyMedium,
              items: consortiums.map<DropdownMenuItem<int>>((consortium) {
                return DropdownMenuItem<int>(
                  value: consortium['ID'],
                  child: Text(
                    consortium['name'] ?? 'Sin Nombre',
                    style: AppTheme.bodyMedium,
                  ),
                );
              }).toList(),
              onChanged: (int? newValue) {
                _filterSpacesByConsortium(newValue!);
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: spaces.isEmpty
                  ? const Center(
                      child: Text(
                        'No hay espacios disponibles',
                        style: AppTheme.bodyMedium,
                      ),
                    )
                  : ListView.builder(
                      itemCount: spaces.length,
                      itemBuilder: (context, index) {
                        final space = spaces[index];
                        String statusDisplay =
                            space['status'] == 'active' ? 'Activo' : 'Inactivo';

                        return Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          margin: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 0),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  space['name'] ?? 'Sin Nombre',
                                  style: AppTheme.titleSmall.copyWith(
                                    color: AppTheme.primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Horario Operativo: ${space['operational_start_time']} - ${space['operational_end_time']}',
                                  style: AppTheme.bodyMedium,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Estado: $statusDisplay',
                                  style: AppTheme.bodyMedium.copyWith(
                                    color: statusDisplay == 'Activo'
                                        ? AppTheme.successColor
                                        : AppTheme.dangerColor,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    return Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      alignment: WrapAlignment.end,
                                      children: [
                                        SizedBox(
                                          width: constraints.maxWidth < 400
                                              ? double.infinity
                                              : (constraints.maxWidth - 24) / 3,
                                        ),
                                        SizedBox(
                                          width: constraints.maxWidth < 400
                                              ? double.infinity
                                              : (constraints.maxWidth - 24) / 3,
                                        ),
                                        SizedBox(
                                          width: constraints.maxWidth < 400
                                              ? double.infinity
                                              : (constraints.maxWidth - 24) / 3,
                                          child: ElevatedButton.icon(
                                            onPressed: () {
                                              _openReservationModal(space);
                                            },
                                            icon: const Icon(Icons.add),
                                            label: const Text('Reservar',
                                                style: AppTheme.textSmall),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  AppTheme.primaryColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _navigateToReservations,
              icon: const Icon(Icons.calendar_today),
              label: const Text('Ver Reservas', style: AppTheme.textSmall),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentColor,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
