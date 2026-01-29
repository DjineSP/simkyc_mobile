import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'sim_activation_repository.dart';

class SimRepository extends SimActivationRepository {}

final simRepositoryProvider = Provider<SimRepository>((ref) => SimRepository());
