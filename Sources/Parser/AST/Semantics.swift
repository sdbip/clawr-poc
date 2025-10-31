public enum Semantics: String {
    case immutable = "let"
    case isolated  = "mut"
    case shared    = "ref"
}
