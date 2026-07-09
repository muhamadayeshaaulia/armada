import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// Import semua layer dari fitur Auth
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/logout_usecase.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/domain/usecases/register_usecase.dart';
import 'features/auth/domain/usecases/get_current_user_usecase.dart';
// Import semua layer dari fitur Staff
import 'features/staff/data/datasources/staff_remote_data_source.dart';
import 'features/staff/data/repositories/staff_repository_impl.dart';
import 'features/staff/domain/repositories/staff_repository.dart';
import 'features/staff/domain/usecases/get_admins_usecase.dart';
import 'features/staff/domain/usecases/get_doctors_usecase.dart';
import 'features/staff/domain/usecases/update_staff_usecase.dart';
import 'features/staff/domain/usecases/delete_staff_usecase.dart';
import 'features/staff/domain/usecases/add_staff_usecase.dart';
import 'features/staff/presentation/bloc/staff_bloc.dart';

// Import Patient
import 'features/patient/data/datasources/patient_remote_data_source.dart';
import 'features/patient/data/repositories/patient_repository_impl.dart';
import 'features/patient/domain/repositories/patient_repository.dart';
import 'features/patient/presentation/bloc/patient_bloc.dart';

// Import Medicine
import 'features/medicine/data/datasources/medicine_remote_data_source.dart';
import 'features/medicine/data/repositories/medicine_repository_impl.dart';
import 'features/medicine/domain/repositories/medicine_repository.dart';
import 'features/medicine/presentation/bloc/medicine_bloc.dart';

// Import Rekam Medis
import 'features/rekam_medis/data/datasources/rekam_medis_remote_data_source.dart';
import 'features/rekam_medis/data/repositories/rekam_medis_repository_impl.dart';
import 'features/rekam_medis/domain/repositories/rekam_medis_repository.dart';
import 'features/rekam_medis/presentation/bloc/rekam_medis_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! FITUR: AUTH
  // Bloc
  sl.registerFactory(
    () => AuthBloc(
      registerUseCase: sl(),
      loginUseCase: sl(),
      logoutUseCase: sl(),
      getCurrentUserUseCase: sl(),
    ),
  );

  // UseCases
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  // Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl
    (firebaseAuth: sl(),
    supabaseClient: sl()),
  );

  //! FITUR: STAFF
  // Bloc
  sl.registerFactory(
    () => StaffBloc(
      getAdminsUseCase: sl(),
      getDoctorsUseCase: sl(),
      updateStaffUseCase: sl(),
      deleteStaffUseCase: sl(),
    ),
  );

  // UseCases
  sl.registerLazySingleton(() => GetAdminsUseCase(sl()));
  sl.registerLazySingleton(() => GetDoctorsUseCase(sl()));
  sl.registerLazySingleton(() => UpdateStaffUseCase(sl()));
  sl.registerLazySingleton(() => DeleteStaffUseCase(sl()));
  sl.registerLazySingleton(() => AddStaffUseCase(sl()));

  // Repository
  sl.registerLazySingleton<StaffRepository>(
    () => StaffRepositoryImpl(remoteDataSource: sl()),
  );

  // Data Sources
  sl.registerLazySingleton<StaffRemoteDataSource>(
    () => StaffRemoteDataSourceImpl(supabaseClient: sl()),
  );

  //! FITUR: PATIENT
  sl.registerFactory(() => PatientBloc(repository: sl()));
  sl.registerLazySingleton<PatientRepository>(() => PatientRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<PatientRemoteDataSource>(() => PatientRemoteDataSourceImpl(supabaseClient: sl()));

  //! FITUR: MEDICINE
  sl.registerFactory(() => MedicineBloc(repository: sl()));
  sl.registerLazySingleton<MedicineRepository>(() => MedicineRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<MedicineRemoteDataSource>(() => MedicineRemoteDataSourceImpl(supabaseClient: sl()));

  //! FITUR: REKAM MEDIS
  sl.registerFactory(() => RekamMedisBloc(repository: sl()));
  sl.registerLazySingleton<RekamMedisRepository>(() => RekamMedisRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<RekamMedisRemoteDataSource>(() => RekamMedisRemoteDataSourceImpl(supabaseClient: sl()));

  //! EXTERNAL
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);
}