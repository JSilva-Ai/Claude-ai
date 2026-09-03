import 'in_memory_loop_repository.dart';
import 'loop_repository_contract.dart';

void main() {
  runLoopRepositoryContractTests(
    label: 'in-memory',
    createRepository: InMemoryLoopRepository.new,
  );
}
