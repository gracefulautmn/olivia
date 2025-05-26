// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:supabase_flutter/supabase_flutter.dart' as _i454;

import 'core/network/network_info.dart' as _i75;
import 'features/auth/data/datasources/auth_remote_datasource.dart' as _i588;
import 'features/auth/data/datasources/auth_remote_datasource_impl.dart'
    as _i47;
import 'features/auth/domain/repositories/auth_repository.dart' as _i1015;
import 'features/auth/domain/repositories/auth_repository_impl.dart' as _i549;
import 'features/auth/domain/usecases/login_user.dart' as _i1073;
import 'features/auth/presentation/cubit_or_bloc/auth_cubit.dart' as _i997;

// initializes the registration of main-scope dependencies inside of GetIt
_i174.GetIt $initGetIt(
  _i174.GetIt getIt, {
  String? environment,
  _i526.EnvironmentFilter? environmentFilter,
}) {
  final gh = _i526.GetItHelper(getIt, environment, environmentFilter);
  gh.lazySingleton<_i75.NetworkInfo>(
    () => _i75.NetworkInfoImpl(gh<InvalidType>()),
  );
  gh.lazySingleton<_i588.AuthRemoteDataSource>(
    () => _i47.AuthRemoteDataSourceImpl(gh<_i454.SupabaseClient>()),
  );
  gh.lazySingleton<_i1015.AuthRepository>(
    () => _i549.AuthRepositoryImpl(
      remoteDataSource: gh<_i588.AuthRemoteDataSource>(),
      networkInfo: gh<_i75.NetworkInfo>(),
    ),
  );
  gh.factory<_i997.AuthCubit>(
    () => _i997.AuthCubit(supabaseClient: gh<_i454.SupabaseClient>()),
  );
  gh.lazySingleton<_i1073.LoginUser>(
    () => _i1073.LoginUser(gh<_i1015.AuthRepository>()),
  );
  return getIt;
}
