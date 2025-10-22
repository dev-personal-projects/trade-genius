sealed class PortfolioResult<T> {
  const PortfolioResult();
}

class PortfolioSuccess<T> extends PortfolioResult<T> {
  final T data;
  const PortfolioSuccess(this.data);
}

class PortfolioFailure<T> extends PortfolioResult<T> {
  final String message;
  const PortfolioFailure(this.message);
}
