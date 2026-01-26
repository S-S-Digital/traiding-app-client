enum Status {
  initial,
  loading,
  loaded,
  failure,
  submit,
  success,
  offline,
  logout,
}

extension StatusX on Status {
  bool get isBuildable => this != Status.failure && this != Status.success && this != Status.logout;
  bool get isLoading => this == Status.loading;
  bool get isInitial => this == Status.initial;
  bool get isSubmit => this == Status.submit;
}

